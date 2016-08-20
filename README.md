# docker.mapnik3
mapnik 3 container


# how to build
sudo docker build -t="img-mapnik3:0.2" .

# how to run
* sudo docker run -ti --rm img-mapnik3:0.2 /sbin/my_init -- bash -l

# how to git
git clone https://github.com/henrythasler/docker.mapnik3.git
cd docker.mapnik3
git remote add mapnik3 https://github.com/henrythasler/docker.mapnik3
// do something
git add .
git commit -a
git push mapnik3 master

# references
https://github.com/der-stefan/OpenTopoMap/blob/master/mapnik/HOWTO_Server_16.04
https://www.linuxbabe.com/linux-server/openstreetmap-tile-server-ubuntu-16-04
https://github.com/MapFig/opentileserver
https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/