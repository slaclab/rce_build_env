#!/bin/bash
_root=$(dirname ${BASH_SOURCE})
_root=$(cd ${_root}/../> /dev/null 2>&1 && pwd)

function build_drivers {
  GIT_TAG=$1
  kernel_tag=$2
  kernel_ver=$3
  arch=$4
  GIT_REPO=https://github.com/slaclab/aes-stream-drivers
  if [ "${arch}" == "arm64" ]
  then
    comp="aarch64-linux-gnu-"
    kernel_arch="arm64"
  elif [ "${arch}" == "armhf" ]
  then
    comp="arm-linux-gnueabihf-"
    kernel_arch=arm
  else
    echo "Unknown CPU arch ${arch}" && exit 1
  fi

  cd ${_root}

  _topdir=${_root}/build/drivers/${GIT_TAG}


  pkg=$(ls ./build/kernel/linux-headers-${kernel_tag}-${arch}*.deb)
  echo Installing kernel header package ${pkg}

  sudo apt-get -y install ${pkg} || echo "Failed to install kernel headers"

  mkdir -p ${_topdir}/${arch}/buildroot/lib/modules/${kernel_tag}-${arch}/

  cd ${_topdir}/${arch}
  git clone -b ${GIT_TAG} ${GIT_REPO}

  for driver in rce_memmap rce_stream
  do
    echo $driver
    cd ${_topdir}/${arch}/aes-stream-drivers/${driver}/driver
    make KDIR=/usr/src/linux-headers-${kernel_tag}-${arch} ARCH=${kernel_arch} COMP=${comp}
  done
  GIT_TAG=$(echo ${GIT_TAG} | sed 's/v//g')
  cp $(find ${_topdir}/${arch}/aes-stream-drivers/ -name "*.ko") ${_topdir}/${arch}/buildroot/lib/modules/${kernel_tag}-${arch}/
  fpm -C ${_topdir}/${arch}/buildroot --prefix /  \
	-s dir -t deb  --name rce_drivers \
	--license agpl3 --version ${GIT_TAG}-${kernel_ver} \
	--architecture ${arch} \
	--depends linux-image-${kernel_tag}-${arch} \
	--description "SLAC RCE kernel drivers" \
	--maintainer "Matthias Wittgen (wittgen@slac.stanford.edu" \
	.=/

}

build_drivers "5.17.2" "5.15.0-slac" "5.15.0" "arm64"
build_drivers "5.17.2" "5.15.0-slac" "5.15.0" "armhf"

build_drivers "v5.15.0" "4.14.0-slac" "4.14.0" "arm64"
build_drivers "v5.4.0" "4.14.0-slac" "4.14.0" "armhf"



