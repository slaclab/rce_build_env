#!/bin/bash
_root=$(dirname ${BASH_SOURCE})
_root=$(cd ${_root}/> /dev/null 2>&1 && pwd)

source ${_root}/../configs/kernel.conf

GIT_REPO=https://github.com/slaclab/aes-stream-drivers
GIT_TAG=fix_kernel_v5


_topdir=${_root}/../build_drivers

mkdir -p ${_topdir}/arm64/buildroot/lib/modules/${kernel_ver}-arm64/

cd ${_topdir}/arm64/
git clone -b ${GIT_TAG} ${GIT_REPO}

for driver in rce_memmap rce_stream
do
  echo $driver
  cd ${_topdir}/arm64/aes-stream-drivers/${driver}/driver
  make KDIR=/usr/src/linux-headers-${kernel_ver}-arm64 ARCH=arm64 COMP=aarch64-linux-gnu-
done
cp $(find ${_topdir}/arm64/aes-stream-drivers/ -name "*.ko") ${_topdir}/arm64/buildroot/lib/modules/${kernel_ver}-arm64/
fpm -C ${_topdir}/arm64/buildroot --prefix /  \
	-s dir -t deb  --name rce_drivers \
	--license agpl3 --version 15.3.0-5.15 \
	--architecture arm64 \
	--depends linux-image-5.15.0-slac-arm64 \
	--description "SLAC RCE kernel drivers" \
	--maintainer "Matthias Wittgen (wittgen@slac.stanford.edu" \
	.=/

mkdir -p ${_topdir}/arm/buildroot/lib/modules/${kernel_ver}-armhf/
cd ${_topdir}/arm/
git clone -b ${GIT_TAG} ${GIT_REPO}

for driver in rce_memmap rce_stream
do
  cd ${_topdir}/arm/aes-stream-drivers/${driver}/driver
  make KDIR=/usr/src/linux-headers-${kernel_ver}-armhf ARCH=arm COMP=arm-linux-gnueabihf-
done
cp $(find ${_topdir}/arm/aes-stream-drivers/ -name "*.ko") ${_topdir}/arm/buildroot/lib/modules/${kernel_ver}-armhf/
fpm -C ${_topdir}/arm/buildroot --prefix /  \
        -s dir -t deb  --name rce_drivers \
        --license agpl3 --version 15.3.0-5.15 \
        --architecture armhf \
        --depends linux-image-5.15.0-slac-armhf \
        --description "SLAC RCE kernel drivers" \
        --maintainer "Matthias Wittgen (wittgen@slac.stanford.edu" \
        .=/




