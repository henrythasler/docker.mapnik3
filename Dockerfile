# Ubuntu 16.04
# see https://github.com/phusion/baseimage-docker#using
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
              wget \
              curl \
              python \
              zlib1g-dev \
              clang \
              make \
              pkg-config \
              apt-utils \
              ca-certificates
              
# download sources and prepare for build
# see https://github.com/mapnik/mapnik/blob/master/INSTALL.md for build details
RUN cd $BPATH \
        && git clone --depth 1 --branch $MAPNIK_VERSION $MAPNIK_SOURCE \
        && cd $BPATH/mapnik \
        && git submodule update --init
        
# build+install mapnik, create a separate bash instance to persist exported variables 
# turn off cairo-support, since it won't compile due to some header issues
# see https://github.com/mapnik/mapnik/wiki/MapnikRenderers for details about MapnikRenderers
RUN /bin/bash -c 'cd $BPATH/mapnik \
        && source bootstrap.sh \
        && ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CAIRO=False \
        && make \
        && make install'
        
# clean up mapnik source        
RUN cd $BPATH \
        && rm -r mapnik
        
# install setuptools
# and python bindings from egg-file
RUN cd $BPATH \
        && wget https://bootstrap.pypa.io/ez_setup.py -O - | python \
        && wget https://pypi.python.org/packages/7b/96/12930cefa3048a79ea74c24fdf32def0820335da23a8c4d00ccc5d41e21b/mapnik-0.1-py2.7-linux-x86_64.egg#md5=6c376914c4e72d603a6510c5bd39ee2f \
        && easy_install mapnik-0.1-py2.7-linux-x86_64.egg
        
# Verify Mapnik install
RUN python -c 'import mapnik'
                        
# install mod_tile & renderd
ENV MODTILE_SOURCE https://github.com/openstreetmap/mod_tile.git
#  https://github.com/springmeyer/mod_tile

RUN apt-get install -y apache2 apache2-dev

RUN apt-get install -y autoconf

# dependencies for mod_tile & renderd
RUN apt-get install -y \
              libtool \
#              libboost-all-dev \
              libharfbuzz-dev \
              libpng-dev \
              libproj-dev \
              libtiff-dev \
              libfreetype6-dev \
              libwebp-dev
              
RUN apt-get install -y libboost-dev

RUN apt-get install -y libmapnik-dev

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