# Build on top of latest ruby-slim container
FROM ruby:slim

MAINTAINER Team Charlie <csd@abdn.ac.uk>

# Set up proxy settings
ARG http_proxy
ARG https_proxy
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy

# Set up proxy for the debian package manager
RUN echo 'Acquire::http::Proxy "'$http_proxy'";' > /etc/apt/apt.conf

#######################
# Install dependencies
#######################
ENV LANG C.UTF-8

RUN apt-get update -qy
RUN apt-get upgrade -y
RUN apt-get update -qy
RUN apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for a JS runtime
RUN apt-get install -y nodejs

# For ffi-1.9.18 gem
RUN apt-get install -y curl

# For image conversion
RUN apt-get install -y imagemagick

# Create the server direcotory in the container
RUN mkdir -p /lacr-search
WORKDIR /lacr-search

# Add source files in the container
ADD src/Gemfile /lacr-search/Gemfile
ADD src/Gemfile.lock /lacr-search/Gemfile.lock

# Install requered gems
RUN bundle install


# Disable the proxy settings.
# Otherwise ruby will try to connect to the other containers
# via this proxy.
RUN echo '' > /etc/apt/apt.conf
ENV http_proxy=''
ENV https_proxy=''
