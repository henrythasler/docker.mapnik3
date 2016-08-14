# Ubuntu 16.04
FROM phusion/baseimage:0.9.19

MAINTAINER Henry Thasler <docker@thasler.org>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# build path
ENV BPATH /usr/src

# define the desired versions
ENV MAPNIK_VERSION v3.0.11

# path to download location
ENV MAPNIK_SOURCE https://github.com/mapnik/mapnik.git

# prepare for install
RUN apt-get update

# install dependencies
RUN apt-get install -y --no-install-recommends \
              git \
              python \
              zlib1g-dev \
              clang \
              make \
              pkg-config
              
# download sources and prepare for build
RUN cd $BPATH \
        && git clone --depth 10 --branch $MAPNIK_VERSION $MAPNIK_SOURCE \
        && cd mapnik \
        && git submodule update --init
        
# build and install mapnik
RUN cd $BPATH \
        && cd mapnik \
        && source bootstrap.sh \
        && ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
        && make \
        && make install

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*