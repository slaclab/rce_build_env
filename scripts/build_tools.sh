#!/bin/bash
_root=$(dirname ${BASH_SOURCE})
_root=$(cd ${_root}/../> /dev/null 2>&1 && pwd)

GIT_TAG=b2.4.2
ver=$(echo $GIT_TAG | sed 's/b//g')

function build_tools_host {
   _topdir=${_root}/build/tools/host
   rcearch=i86-linux-64-opt
   mkdir -p ${_topdir}
   cd ${_topdir}
   fpm -s python -t rpm --python-package-name-prefix=python3 --python-bin=python3 --version=3.10.7 pyparted
   git clone -b ${GIT_TAG} https://github.com/slaclab/rce-gen3-sw-lib.git
   cd  ${_topdir}/rce-gen3-sw-lib
   CC=/usr/bin/gcc CXX=/usr/bin/g++ make ${rcearch} CROSS_COMPILE=/usr/bin/ PTH_ROOT=/usr
   mkdir buildroot
   cp -r build/${rcearch}/bin buildroot/
   cp -r build/${rcearch}/lib buildroot/
   cp -r ${_root}/python buildroot/
   cp  ${_root}/bin/* buildroot/bin/
   rm -f $(find buildroot/ -name "*.pyc")
   rm -rf $(find buildroot/ -type dir -name "__pycache__")
   
   fpm -C ${_topdir}/rce-gen3-sw-lib/buildroot --prefix /opt/rce/tools/  \
        -s dir -t rpm  --name rcetools \
        --license agpl3 --version ${ver} \
        --architecture x86_64 \
        --depends freeipmi --depends pth \
        --depends parted \
        --depends python3 \
        --depends python3-parted \
        --description "SLAC RCE Command Line Tools" \
        --maintainer "Matthias Wittgen (wittgen@slac.stanford.edu" \
        .=/

}

build_tools_host
