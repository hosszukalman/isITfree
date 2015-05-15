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
