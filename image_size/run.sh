#!/bin/bash

WORKDIR=$(cd "$(dirname "$0")";pwd)

echo "$WORKDIR"

cd $WORKDIR

mkdir -p results

# echo "Running unikraft..."
# ./unikraft/imgsize.sh

echo "Running linux user..."
./linux-user/imgsize.sh