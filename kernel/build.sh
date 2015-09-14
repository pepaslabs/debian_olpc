#!/bin/bash

set -e
set -o pipefail
set -x

# see http://wiki.laptop.org/go/Kernel_Building
# see dtbaker.net/random-linux-posts/how-to-build-a-custom-linux-kernel-module-for-olpc/ 
# see https://wiki.debian.org/howto_debian_olpc

for package in git build-essential libncurses5-dev:i386 lzop
do
    if dpkg --get-selections | awk '{print $1}' | grep "^${package}$"
    then
        continue
    else
        echo "Error: $package is not installed." >&2
        exit 1
    fi
done

if [ ! -e olpc-kernel ]
then
    if [ -e cache/olpc-kernel.tar.gz ]
    then
        cat cache/olpc-kernel.tar.gz | nice gunzip | tar x
    else
        git clone git://dev.laptop.org/olpc-kernel
    fi
fi

cd olpc-kernel
nice git checkout olpc-3.10

make clean distclean
#make xo_1_defconfig
cp ../config .config
make menuconfig
cp .config ../config

nice make
nice make bzImage
nice make modules

RESULTSDIR="results_`date +%Y%m%d_%H%M%S`"
mkdir -p ../$RESULTSDIR

cp -a arch/x86/boot/bzImage ../$RESULTSDIR/

mkdir -p ../$RESULTSDIR/lib/modules
INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../$RESULTSDIR make modules_install

cp -a ../config ../$RESULTSDIR/

echo "done."
echo "results in $RESULTSDIR"
