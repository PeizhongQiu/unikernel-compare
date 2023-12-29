#!/bin/bash
WORKDIR=$(cd "$(dirname "$0")";pwd)

echo "$WORKDIR"

echo "Running linux user..."

echo "Running linux user helloworld..."
cd $WORKDIR
gcc hello.c -o hello
strip hello
HELLO_SIZE=`du --block-size=1 hello | tail -n 1 | awk '{ print $1 }'`
rm hello

echo ${HELLO_SIZE}  > $WORKDIR/../results/linuxuser-hello.csv

echo "Running linux user nginx..."
CONTAINER=nginx-tmp
docker pull nginx:1.15.6-alpine
docker run --privileged --name=$CONTAINER -dt nginx:1.15.6-alpine
docker exec -it $CONTAINER apk add binutils
docker exec -it $CONTAINER apk add coreutils
docker exec -it $CONTAINER strip /usr/sbin/nginx
NGINX_SIZE=`(docker exec -it $CONTAINER du --block-size=1 /usr/sbin/nginx) | \
			tail -n 1 | awk '{ print $1 }'`
docker container stop $CONTAINER
docker rm -f $CONTAINER
echo ${NGINX_SIZE}  > $WORKDIR/../results/linuxuser-nginx.csv

echo "Running linux user redis..."
CONTAINER=redis-tmp
docker pull redis:7.0.11-alpine
docker run --privileged --name=$CONTAINER -dt redis:7.0.11-alpine
docker exec -it $CONTAINER apk add binutils
docker exec -it $CONTAINER apk add coreutils
docker exec -it $CONTAINER cp /usr/local/bin/redis-server /usr/local/bin/tmp-redis
docker exec -it $CONTAINER strip /usr/local/bin/tmp-redis
REDIS_SIZE=`(docker exec -it $CONTAINER du --block-size=1 \
			/usr/local/bin/tmp-redis) | \
			tail -n 1 | awk '{ print $1 }'`
docker container stop $CONTAINER
docker rm -f $CONTAINER
echo ${REDIS_SIZE}  > $WORKDIR/../results/linuxuser-redis.csv

echo "Running linux user sqlite..."
CONTAINER=sqlite-tmp
cd $WORKDIR/sqlite-amalgamation-3400100
gcc shell.c sqlite3.c -lpthread -ldl -lm -o sqlite3
strip sqlite3
SQLITE_SIZE=`du --block-size=1 sqlite3 | tail -n 1 | awk '{ print $1 }'`
rm sqlite3

echo ${SQLITE_SIZE}  > $WORKDIR/../results/linuxuser-sqlite.csv