#!/bin/bash
_root=$(dirname ${BASH_SOURCE})
_root=$(cd ${_root}/../> /dev/null 2>&1 && pwd)


function build_kernel() {
  tag=$1
  kernel_ver=$2
  mkdir -p ${_root}/build/kernel/
  cd ${_root}/build/kernel/
  git clone --depth 1 https://github.com/mwittgen/linux-xlnx-slac -b ${tag} ${tag}
  cd ${tag}
  echo Building kernel version ${kernel_ver}, tag ${tag}
  make distclean
  make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- rcezcu102_defconfig
  sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" .config
  make ARCH=arm64 LOCALVERSION=-slac-arm64 CROSS_COMPILE=aarch64-linux-gnu- bindeb-pkg -j$(nproc)

  make distclean
  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zynqrce_defconfig
  sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" .config
  make ARCH=arm LOCALVERSION=-slac-armhf CROSS_COMPILE=arm-linux-gnueabihf- bindeb-pkg -j$(nproc)
}

build_kernel "slac-v2022.1" "5.15.0-slac"
build_kernel "slac-v2018.3" "4.14.0-slac"

