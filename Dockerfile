#
# isITfree Dockerfile
#
# https://github.com/hosszukalman/isITfree
#

# Pull base image.
FROM dockerfile/ubuntu

# Define tool versions.
ENV MONGODB_VERSION 2.6.7
ENV GO_VERSION 1.4.2
ENV NGINX_VERSION 1.6.2-5+trusty0
ENV NPM_VERISON 2.7.3

ENV GOROOT /goroot
ENV GOPATH /gopath

ENV WORKDIR /workdir

VOLUME /data

# Executables to run.
ENTRYPOINT ["/usr/bin/supervisord"]

# Expose http port.
EXPOSE 80

# Expose samba ports.
# Note that the samba services are not installed by default.
EXPOSE 137
EXPOSE 138
EXPOSE 139
EXPOSE 445

# Expose default port for MongoDB.
# Make sure this port is not mapped to a port on the host machine when running the
# container in production.
EXPOSE 27017

# Set up default locale to UTF-8.
# This is a good practice in any case, but it is required for ruby/compass specifically:
# https://github.com/csswizardry/inuit.css/issues/270#issuecomment-56056606
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Add some directories to the PATH.
RUN echo 'export PATH=$PATH:/usr/local/sbin/:/usr/sbin/:/sbin' >> /root/.bashrc
ENV DEBIAN_FRONTEND noninteractive

# Add Go binaries to the path.
ENV PATH $GOROOT/bin:$PATH

# Add required ppa's.
RUN \
  add-apt-repository -y ppa:git-core/ppa && \
  add-apt-repository -y ppa:nginx/stable && \
  curl -sL https://deb.nodesource.com/setup | sudo bash -

# Add mongodb repo.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list

  # Upgrade and install packages.
RUN \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    bzr \
    git \
    make \
    mongodb-org-mongos=$MONGODB_VERSION \
    mongodb-org-server=$MONGODB_VERSION \
    mongodb-org-shell=$MONGODB_VERSION \
    mongodb-org-tools=$MONGODB_VERSION \
    mongodb-org=$MONGODB_VERSION \
    nginx \
    nodejs \
    ruby-dev \
    supervisor &&\
  apt-get clean -y

# Install a recent version of npm because of https://github.com/npm/npm/issues/6309
RUN npm install -g npm@$NPM_VERISON

# Add configuration files.
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD config/nginx/sites-available/default /etc/nginx/sites-available/default
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/.bashrc /root/.bashrc
ADD config/samba/smb.conf /etc/samba/smb.conf
ADD config/timezone /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Install compass.
run \
  gem install --no-rdoc --no-ri compass

# Install Go.
RUN \
  mkdir -p $GOROOT && \
  curl -s https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar xzf - -C $GOROOT --strip-components=1

# Add go scripts.
ADD ./workdir $WORKDIR
RUN mkdir -p $GOPATH/src/github.com/hosszukalman/isITfree

# Link the back-end to the GOPATH.
RUN ln -s $WORKDIR/back-end $GOPATH/src/github.com/hosszukalman/isITfree/back-end

# Build back-end
RUN \
  cd $GOPATH/src/github.com/hosszukalman/isITfree/back-end && \
  go get github.com/tools/godep && \
  $GOPATH/bin/godep restore && \
  go build

# Install Bower and Grunt.
RUN \
  npm install --global bower && \
  npm install --global grunt-cli

# Link front-end to the webroot.
RUN rm -rf /var/www/html
RUN ln -s $WORKDIR/front-end/src /var/www/html

# Build front-end.
RUN cd $WORKDIR/front-end && \
  npm install && \
  bower install && \
  ./node_modules/.bin/gulp
