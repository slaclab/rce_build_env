#!/bin/bash
base="."
# QEMU static version
qemu_static_ver=v7.0.0-7
# CPU architectures to fetch
archs="aarch64 arm"
echo "#### Install DNF ####"
mkdir -p ${base}/qemu-bins
# fetch qemu stuff
pushd $PWD
cd  ${base}/qemu-bins
if [ ! -e qemu-binfmt-conf.sh ] ; then
    wget https://raw.githubusercontent.com/multiarch/qemu-user-static/v3.0.0/register/qemu-binfmt-conf.sh 
fi

for i in ${archs}
do
    if [ ! -e qemu-${i}-static ] ; then
    wget https://github.com/multiarch/qemu-user-static/releases/download/${qemu_static_ver}/qemu-${i}-static 
    fi
done
chmod +x $(find . -type f )
popd

for i in ${archs}
do
sudo ${base}/qemu-bins/qemu-binfmt-conf.sh --systemd ${i}
done
sudo systemctl enable systemd-binfmt
sudo systemctl restart systemd-binfmt

