#!/bin/bash

set -e
set -x
set -o pipefail

# based on http://pastebin.com/raw.php?i=EktdMcjk

# --- tunables:

export DEBROOT="${HOME}/debian_olpc/debroot"

export http_proxy="http://localhost:3142"

#export MIRROR="http://http.us.debian.org"
export MIRROR="http://debian.mirrors.pair.com"

# --- functions:

function has_stamp {
    mkdir -p "${DEBROOT}/tmp/stamps"
    touch "${DEBROOT}/tmp/stamps/${1}"
}

function needs_stamp {
    [ ! -e "${DEBROOT}/tmp/stamps/${1}" ]
    return $?
}

function installed {
    which $1 >/dev/null
    return $?
}

# --- main:

if ! installed debootstrap
then
    apt-get install debootstrap
fi

if [ ! -e "${DEBROOT}" ]
then
    rm -f /tmp/stamps/*
fi

mkdir -p "${DEBROOT}/tmp/stamps"

mkdir -p "${DEBROOT}/bin"
cp -a make_debian_olpc_chroot.sh "${DEBROOT}/bin/"

mkdir -p "${DEBROOT}/var/cache"
cp -a cache/kernel-3.10.0_xo1-20130716.1755.olpc.c06da27.i686.rpm "${DEBROOT}/var/cache/"
cp -a cache/usb8388-5.110.22.p22.bin "${DEBROOT}/var/cache/"

cd "${DEBROOT}"

if needs_stamp debootstrap
then
    debootstrap --arch i386 jessie . "${MIRROR}/debian/"
    has_stamp debootstrap
fi

cp -a /etc/resolv.conf etc/resolv.conf

mkdir -p dev proc sys tmp
mount -o bind /dev dev
mount -o bind /proc proc
mount -o bind /sys sys
mount -o bind /tmp tmp

set +e
chroot "${DEBROOT}" make_debian_olpc_chroot.sh
CHROOT_STATUS=$?
set -e

umount "${DEBROOT}/tmp"
umount "${DEBROOT}/sys"
umount "${DEBROOT}/proc"
umount "${DEBROOT}/dev"

if [ $CHROOT_STATUS -ne 0 ]
then
    echo "make_debian_olpc_chroot.sh failed."
    exit $CHROOT_STATUS
fi

rm -rf "${DEBROOT}/tmp/stamps"

echo "make_debian_olpc.sh done."

