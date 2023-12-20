#!/bin/bash

test ! -d "workdir" && echo "Cloning unikraft..." || true
test ! -d "workdir/unikraft" && git clone -b RELEASE-0.15.0 https://github.com/unikraft/unikraft workdir/unikraft || true
