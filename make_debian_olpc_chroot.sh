#!/bin/bash

set -e
set -x
set -o pipefail

# thanks to http://pastebin.com/raw.php?i=EktdMcjk

# --- tunables:

export http_proxy="http://localhost:3142"

#export MIRROR="http://ftp.us.debian.org"
export MIRROR="http://debian.mirrors.pair.com"

# --- functions:

function has_stamp {
    mkdir -p "/tmp/stamps"
    touch "/tmp/stamps/${1}"
}

function needs_stamp {
    [ ! -e "/tmp/stamps/${1}" ]
    return $?
}

# --- main:

cat > /etc/sources.list << EOF
deb ${MIRROR}/debian jessie main contrib non-free
deb-src ${MIRROR}/debian jessie main contrib non-free

deb ${MIRROR}/debian/ jessie-updates main contrib non-free
deb-src ${MIRROR}/debian/ jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
EOF

apt-get update

echo "debian" > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1	localhost
127.0.1.1	debian

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# this prevents daemons from being started from the chroot.
# thanks to http://askubuntu.com/q/74061
# thanks to https://wiki.debian.org/fr/Chroot
cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 101
EOF
chmod a+x /usr/sbin/policy-rc.d

if needs_stamp locales
then
    apt-get -y install locales
    # thanks to http://serverfault.com/a/689947
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    echo 'LANG="en_US.UTF-8"' > /etc/default/locales
    dpkg-reconfigure -f noninteractive locales
    update-locale LANG=en_US.UTF-8
    has_stamp locales
fi

if needs_stamp olpc_pkgs
then
    apt-get -y install wpasupplicant acpid acpi olpc-kbdshim olpc-powerd olpc-xo1-hw
    has_stamp olpc_pkgs
fi

#if needs_stamp x
#then
#    apt-get -y install xserver-xorg lxde
#    has_stamp x
#fi

if needs_stamp kernel
then
    apt-get -y install initramfs-tools rpm2cpio wget

    cd /var/cache
    if [ ! -e /var/cache/kernel-3.10.0_xo1-20130716.1755.olpc.c06da27.i686.rpm ]
    then
        wget http://dev.laptop.org/~kernels/public_rpms/f20-xo1/kernel-3.10.0_xo1-20130716.1755.olpc.c06da27.i686.rpm
    fi

    cd /
    rpm2cpio /var/cache/kernel*.rpm | cpio -idmv

    cd /boot
    mv initrd-3.10.0_xo1-20130716.1755.olpc.c06da27.img initrd.img-3.10.0_xo1-20130716.1755.olpc.c06da27
    update-initramfs -t -c -u -k 3.10.0_xo1-20130716.1755.olpc.c06da27
    ln -s initrd.img-3.10.0_xo1-20130716.1755.olpc.c06da27 initrd.img
    ln -s vmlinuz-3.10.0_xo1-20130716.1755.olpc.c06da27 vmlinuz

    rm -f /var/cache/kernel-3.10.0_xo1-20130716.1755.olpc.c06da27.i686.rpm

    has_stamp kernel
fi

if needs_stamp firmware
then
    
    cd /var/cache
    if [ ! -e /var/cache/usb8388-5.110.22.p22.bin ]
    then
        wget http://dev.laptop.org/pub/firmware/libertas/usb8388-5.110.22.p22.bin
    fi

    mkdir /lib/firmware
    cp -a /var/cache/usb8388-5.110.22.p22.bin /lib/firmware/usb8388.bin
    
    rm -f /var/cache/usb8388-5.110.22.p22.bin

    has_stamp firmware
fi

cat > /boot/olpc.fth << EOF
\ Debian Jessie for XO
visible
" ext:\boot\initrd.img" to ramdisk
" ext:\boot\vmlinuz" to boot-device
" console=tty0 fbcon=font:SUN12x22 root=/dev/mmcblk0p1" to boot-file
boot
EOF

cat > /etc/fstab << EOF
/dev/mmcblk0p1  /         ext4    defaults,noatime,errors=remount-ro  0 0
devpts     /dev/pts  devpts  gid=5,mode=620   0 0
tmpfs      /dev/shm  tmpfs   defaults,size=50m         0 0
proc       /proc     proc    defaults         0 0
sysfs      /sys      sysfs   defaults         0 0
/tmp            /tmp            tmpfs         rw,size=50m 0 0
vartmp          /var/tmp        tmpfs         rw,size=50m 0 0
varlog          /var/log        tmpfs         rw,size=20m 0 0
EOF

echo 'vm.swappiness=5' >> /etc/sysctl.conf

if needs_stamp root_passwd
then
    passwd root
    has_stamp root_passwd
fi

if needs_stamp user
then
    adduser olpc
    has_stamp user
fi

rm -f /usr/sbin/policy-rc.d

echo "make_debian_olpc_chroot.sh done."

