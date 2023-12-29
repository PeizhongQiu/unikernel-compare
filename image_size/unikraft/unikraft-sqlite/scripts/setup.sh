#!/bin/bash

test ! -d "workdir" && echo "Cloning repositories..." || true
test ! -d "workdir/unikraft" && git clone -b RELEASE-0.15.0 https://github.com/unikraft/unikraft workdir/unikraft || true
test ! -d "workdir/libs/sqlite" && git clone -b RELEASE-0.15.0 https://github.com/unikraft/lib-sqlite workdir/libs/sqlite || true
test ! -d "workdir/libs/musl" && git clone -b RELEASE-0.15.0 https://github.com/unikraft/lib-musl workdir/libs/musl || true
