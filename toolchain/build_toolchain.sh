#!/bin/bash

echo "Downloading binutils..."

wget https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz

sleep 2

echo "Extracting binutils..."

tar zxvf binutils-2.37.tar.gz >/dev/null

sleep 2

echo "Building binutils..."

pushd binutils-2.37
mkdir build-pdp11-aout
pushd build-pdp11-aout
../configure --target=pdp11-aout --prefix=${PWD}/../../bin &> build.log
make && make install &>>build.log
popd
popd

