#!/bin/bash

set -e
set -x
set -o pipefail


# hrmm... this isn't booting correctly...
# for now, I'll have to continue using cfdisk on a physical sd card.

# --- tunables:

export DEBROOT="${HOME}/debian_olpc/debroot"

# --- main:

cd "${DEBROOT}/../"

dd if=/dev/zero of=sd_card.img bs=1M count=512

sfdisk sd_card.img << EOF
;
EOF

sfdisk --activate=1 sd_card.img

# this isn't working
#LODEV=`losetup -f`
#losetup -f --show -P sd_card.img
#dd if=ext3.fs of=${LODEV}p1 bs=1M
#losetup -d ${LODEV}

dd if=ext3.fs of=sd_card.img bs=512 skip=1

echo "sd_card.img ready."
