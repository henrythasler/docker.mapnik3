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
              python \
              zlib1g-dev \
              clang \
              make \
              pkg-config \
              apt-utils
              
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

        
# install python bindings        
# install setuptools
RUN apt-get install -y --no-install-recommends \
              wget \
        && wget https://bootstrap.pypa.io/ez_setup.py -O - | python    
        
# get egg-file and install
RUN cd $BPATH \
        && wget https://pypi.python.org/packages/7b/96/12930cefa3048a79ea74c24fdf32def0820335da23a8c4d00ccc5d41e21b/mapnik-0.1-py2.7-linux-x86_64.egg#md5=6c376914c4e72d603a6510c5bd39ee2f  
        && easy_install mapnik-0.1-py2.7-linux-x86_64.egg
        
# install some more dependencies
#RUN apt-get install -y --no-install-recommends \
#              wget \
#              libboost-dev libboost-thread-dev libboost-system-dev libboost-python \
#        && wget https://bootstrap.pypa.io/ez_setup.py -O - | python    

# install python bindings
#RUN cd $BPATH \
#        && git clone https://github.com/mapnik/python-mapnik.git \
#        && cd $BPATH/python-mapnik \
#        && python setup.py install

        
# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*