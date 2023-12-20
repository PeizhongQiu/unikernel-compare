#!/bin/bash
WORKDIR=$(cd "$(dirname "$0")";pwd)

echo "$WORKDIR"

echo "Running unikraft..."

echo "Running unikraft helloworld..."

cd $WORKDIR/unikraft-hello
./scripts/setup.sh
./scripts/build/make-qemu-x86_64.sh
# ./scripts/run/qemu-x86_64.sh

HELLO_SIZE=`du --block-size=1 $WORKDIR/unikraft-hello/workdir/build/helloworld_qemu-x86_64 | tail -n 1 | awk '{ print $1 }'`

echo ${HELLO_SIZE}  > $WORKDIR/../results/unikraft-hello.csv