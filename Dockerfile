# Ubuntu 16.04
# see https://github.com/phusion/baseimage-docker#using
FROM phusion/baseimage:0.9.19

MAINTAINER Henry Thasler <docker@thasler.org>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# build path
ENV BPATH /usr/src

# install dependencies
RUN apt-get update \
        && apt-get install -y \
              git \
              wget \
              curl \
              libmapnik3.0 \
              libmapnik-dev \
              mapnik-utils \
              python-mapnik \
              apt-utils \
              ca-certificates
                              
# Verify Mapnik install
RUN python -c 'import mapnik'
# install mod_tile & renderd
ENV MODTILE_SOURCE https://github.com/openstreetmap/mod_tile.git

RUN apt-get install -y \
              autoconf \
              apache2 \
              apache2-dev

RUN /bin/bash -c 'cd $BPATH \
        && git clone --depth 1 $MODTILE_SOURCE \
        && cd mod_tile \
        && ./autogen.sh \
        && ./configure \
        && make \
        && make install \
        && make install-mod_tile \
        && ldconfig'
        
# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*