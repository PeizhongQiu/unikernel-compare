#!/bin/sh

kernel="workdir/build/unikraft-sqlite_qemu-x86_64"
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

# Create CPIO archive to be used as the initrd.
old="$PWD"
cd "$rootfs"
find -depth -print | tac | bsdcpio -o --format newc > "$old"/rootfs.cpio
cd "$old"

qemu-system-x86_64 \
    -kernel "$kernel" \
    -nographic \
    -m 64M \
    -append "$cmd" \
    -initrd "$PWD"/rootfs.cpio \
    -cpu max
