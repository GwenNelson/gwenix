#!/bin/bash

echo "Downloading binutils..."

wget https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.gz

sleep 2

echo "Extracting binutils..."

tar zxvf binutils-2.37.tar.gz >/dev/null

sleep 2

echo "Building binutils, this may take a while..."

pushd binutils-2.37
mkdir build-pdp11-aout
pushd build-pdp11-aout
../configure --target=pdp11-aout --prefix=${PWD}/../../bin &> build.log
make && make install &>>build.log
popd
popd

sleep 2

echo "Downloading gcc..."

wget https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz

sleep 2

echo "Extracting gcc..."

tar zxvf gcc-11.2.0.tar.gz >/dev/null

sleep 2

echo "Downloading dependencies..."
pushd gcc-11.2.0
contrib/download_prerequisites

sleep 2

echo "Building gcc..."

mkdir build-pdp11-aout
pushd build-pdp11-aout
../configure --target=pdp11-aout --prefix=${PWD}/../../bin --enable-languages=c --disable-libstdc++-v3 --disable-libssp --disable-libgfortran --disable-libobjc &>>build.log
make && make install &>>build.log
popd
popd

echo "All done!"

