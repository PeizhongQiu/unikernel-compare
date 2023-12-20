#!/bin/sh

kernel="workdir/build/helloworld_qemu-x86_64"
cmd=""

if test $# -eq 1; then
    kernel="$1"
fi

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
    -cpu max
