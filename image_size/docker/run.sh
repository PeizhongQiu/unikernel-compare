#!/bin/bash

CONTAINER=nginx-tmp
docker pull nginx:alpine
docker run --privileged --name=$CONTAINER -dt nginx:alpine
docker exec -it $CONTAINER apk add binutils
docker exec -it $CONTAINER apk add coreutils
docker exec -it $CONTAINER strip /usr/sbin/nginx
NGINX_SIZE=`(docker exec -it $CONTAINER du --block-size=1 /usr/sbin/nginx) | \
			tail -n 1 | awk '{ print $1 }'`
docker container stop $CONTAINER
docker rm -f $CONTAINER