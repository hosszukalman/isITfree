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
