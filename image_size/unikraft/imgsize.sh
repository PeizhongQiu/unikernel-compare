#!/bin/bash
WORKDIR=$(cd "$(dirname "$0")";pwd)
echo "$WORKDIR"

build() {
    ./scripts/build/make-qemu-x86_64$3.sh $2
    cp $WORKDIR/unikraft-$1/workdir/build/$1_qemu-x86_64 $WORKDIR/image/$1/$1$3-$2
    SIZE=`du --block-size=1 $WORKDIR/image/$1/$1$3-$2 | tail -n 1 | awk '{ print $1 }'`
    echo ${SIZE}  > $WORKDIR/../results/unikraft-$1$3-$2.csv
}

# echo "Running unikraft..."

# echo "Running unikraft helloworld..."

# cd $WORKDIR/unikraft-helloworld
# ./scripts/setup.sh

# build helloworld DEFAULT
# build helloworld DCE
# build helloworld LTO
# build helloworld DCE_LTO

# echo "Running unikraft nginx..."

# cd $WORKDIR/unikraft-nginx
# ./scripts/setup.sh

# build nginx DEFAULT -9pfs
# build nginx DCE -9pfs
# build nginx LTO -9pfs
# build nginx DCE_LTO -9pfs

# build nginx DEFAULT -initrd
# build nginx DCE -initrd
# build nginx LTO -initrd
# build nginx DCE_LTO -initrd

# ## initrd
# ./scripts/build/make-qemu-x86_64-initrd.sh DEFAULT
# cp $WORKDIR/unikraft-nginx/workdir/build/unikraft-nginx_qemu-x86_64 $WORKDIR/image/nginx/nginx-initrd-default
# NGINX_INITRD_SIZE_DEFAULT=`du --block-size=1 $WORKDIR/image/nginx/nginx-initrd-default | tail -n 1 | awk '{ print $1 }'`
# echo ${NGINX_INITRD_SIZE_DEFAULT}  > $WORKDIR/../results/unikraft-nginx-initrd-default.csv
echo "Running unikraft redis..."

cd $WORKDIR/unikraft-redis
./scripts/setup.sh

# build redis DEFAULT -9pfs
# build redis DCE -9pfs
# build redis LTO -9pfs
# build redis DCE_LTO -9pfs

# build redis DEFAULT -initrd
# build redis DCE -initrd
# build redis LTO -initrd
# build redis DCE_LTO -initrd

echo "Running unikraft sqlite..."

cd $WORKDIR/unikraft-sqlite
./scripts/setup.sh

build sqlite DEFAULT -9pfs
build sqlite DCE -9pfs
build sqlite LTO -9pfs
build sqlite DCE_LTO -9pfs

build sqlite DEFAULT -initrd
build sqlite DCE -initrd
build sqlite LTO -initrd
build sqlite DCE_LTO -initrd