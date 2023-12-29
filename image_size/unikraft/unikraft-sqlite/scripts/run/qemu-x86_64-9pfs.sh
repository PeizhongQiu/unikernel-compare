#!/bin/sh

kernel="workdir/build/sqlite_qemu-x86_64"
cmd=""

if test $# -eq 1; then
    kernel="$1"
fi

rootfs="./rootfs"
test -d "$rootfs" || mkdir "$rootfs"

# Clean up any previous instances.
sudo pkill -f qemu-system
sudo pkill -f firecracker
sudo kraft stop --all
sudo kraft rm --all

qemu-system-x86_64 \
    -kernel "$kernel" \
    -nographic \
    -m 64M \
    -append "$cmd" \
    -fsdev local,id=myid,path="$rootfs",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs1,disable-modern=on,disable-legacy=off \
    -cpu max
