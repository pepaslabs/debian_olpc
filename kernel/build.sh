#!/bin/bash

set -e
set -o pipefail
set -x

# see http://wiki.laptop.org/go/Kernel_Building
# see dtbaker.net/random-linux-posts/how-to-build-a-custom-linux-kernel-module-for-olpc/ 
# see https://wiki.debian.org/howto_debian_olpc

#apt-get install git build-essential ncurses-dev lzop

if [ -e cache/olpc-kernel.tar.gz ]
then
    cat cache/olpc-kernel.tar.gz | nice gunzip | tar x
else
    git clone git://dev.laptop.org/olpc-kernel
fi

cd olpc-kernel
git checkout olpc-3.10

make clean distclean
#make xo_1_defconfig
cp ../config .config
make menuconfig

nice make
mkdir -p ../results
cp -a vmlinux ../results/

nice make modules
mkdir -p ../results/lib/modules
INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../results make modules_install
