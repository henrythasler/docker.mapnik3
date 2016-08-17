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
        && cd $BPATH/mapnik \
        && git submodule update --init
        
# prepare some more
#RUN cd $BPATH/mapnik \
#        && RUN /bin/bash -c "source $BPATH/mapnik/bootstrap.sh"
#        && . bootstrap.sh
         
#RUN apt-get install libcairo2 libcairo2-dev python-cairo python-cairo-dev libcairomm-1.0-1v5 libcairomm-1.0-dev 
#RUN apt-get install -y \
#  build-essential libfreetype6 libfreetype6-dev \
#  icu-devtools libicu-dev libharfbuzz-dev \
#  libboost-dev libboost-filesystem-dev \
#  libboost-regex-dev libboost-thread-dev \
#  libboost-system-dev libboost-program-options-dev \
  
# optional dependencies  
#RUN apt-get install -y \
#  libpng-dev libjpeg-dev libtiff-dev libwebp-dev libproj-dev libgdal-dev  
        
#build+install mapnik, 
#create a separate bash instance to persist exported variables 
RUN /bin/bash -c 'cd $BPATH/mapnik \
        && source bootstrap.sh \
        && ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CAIRO=False \
        && make \
        && make install'
        
# clean up mapnik source        
RUN cd $BPATH \
        && rm -r mapnik

# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*