# 参考: https://github.com/vlang/docker
FROM ubuntu:24.04

# Set the PATH
ENV PATH /opt/vlang:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /opt/vlang && ln -s /opt/vlang/v /usr/bin/v

# Install V build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl-dev libsqlite3-dev git build-essential make

# Install V
WORKDIR /opt/vlang
RUN git clone --depth 1 https://github.com/vlang/v /opt/vlang && make && v -version
