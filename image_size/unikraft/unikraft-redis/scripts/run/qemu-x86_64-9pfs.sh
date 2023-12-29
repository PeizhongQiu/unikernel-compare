#!/bin/sh

kernel="workdir/build/redis_qemu-x86_64"
cmd="/redis.conf"

if test $# -eq 1; then
    kernel="$1"
fi

rootfs="rootfs/"
test -d "$rootfs" || mkdir "$rootfs"

# Clean up any previous instances.
sudo pkill -f qemu-system
sudo pkill -f firecracker
sudo kraft stop --all
sudo kraft rm --all

# Remove previously created network interfaces.
sudo ip link set dev tap0 down 2> /dev/null
sudo ip link del dev tap0 2> /dev/null
sudo ip link set dev virbr0 down 2> /dev/null
sudo ip link del dev virbr0 2> /dev/null

# Create bridge interface for QEMU networking.
sudo ip link add dev virbr0 type bridge
sudo ip address add 172.44.0.1/24 dev virbr0
sudo ip link set dev virbr0 up

sudo qemu-system-x86_64 \
    -kernel "$kernel" \
    -nographic \
    -m 256M \
    -netdev bridge,id=en0,br=virbr0 -device virtio-net-pci,netdev=en0 \
    -append "netdev.ipv4_addr=172.44.0.2 netdev.ipv4_gw_addr=172.44.0.1 netdev.ipv4_subnet_mask=255.255.255.0 -- $cmd" \
    -fsdev local,id=myid,path="$rootfs",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs1,disable-modern=on,disable-legacy=off \
    -cpu max
