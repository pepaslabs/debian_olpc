# debian_olpc

Scripts to create a Debian installation on an OLPC XO-1.

# Credits:

These scripts are based on work by Nathan Misner.  Thanks Nathan!

* http://permalink.gmane.org/gmane.linux.laptop.olpc.devel/38005
* http://pastebin.com/EktdMcjk

# Usage:

I run these scripts (as root) on a VM running an i386 Debian Jessie installation.

First, run make_debian_olpc.sh:
```
./make_debian_olpc.sh
```

This will run debootstrap, then chroot into the results and run make_debian_olpc_chroot.sh.  You will be prompted to enter a root password as well as the password for the 'olpc' user.  The output is very verbose, and if all goes well you should see "make_debian_olpc.sh done.".  If you need to make customizations, cd into the "debroot" directory and do so before running the next script.

Note: the above script assumes you will be using this installation on an SD card, not a USB drive.  If you want to make a USB drive image, you'll need to make a few edits (e.g. in /boot/olpc.fth and /etc/fstab). 

Next, the typical procedure would be to partition and format an SD card, and then rsync the results onto the SD card.  Something like so (where the SD card is /dev/sdb):

```
cfdisk /dev/sdb  # (set up a single bootable partition)
mkfs.ext3 /dev/sdb1
mount /dev/sdb1 /mnt
rsync -a debroot/ /mnt/
umount /dev/sdb1
```

At this point, sticking the SD card into your XO-1 and booting should work.

If you wish to distribute your results as an ext3 filesystem image, run make_debian_olpc_ext3.sh.  This will produce a 511MB file named 'ext3.fs'.

I had intended to create another script to create a complete disk image (including partition table), but I haven't figured out how to get it working yet.  The non-working script is called make_debian_olpc_sd_card_img.sh.

