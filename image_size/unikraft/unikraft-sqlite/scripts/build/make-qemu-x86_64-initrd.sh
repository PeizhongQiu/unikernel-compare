#!/bin/sh

make distclean
UK_DEFCONFIG=$(pwd)/defconfigs/qemu-x86_64-initrd-$1 make defconfig
make prepare
make -j $(nproc)
