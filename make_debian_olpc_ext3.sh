#!/bin/bash

set -e
set -x
set -o pipefail

# --- tunables:

export DEBROOT="${HOME}/debian_olpc/debroot"

# --- main:

cd "${DEBROOT}/../"

dd if=/dev/zero of=ext3.fs bs=1M count=511
mkfs.ext3 ext3.fs

mount -o loop ext3.fs /mnt
cp -a "${DEBROOT}"/* /mnt/
umount /mnt

echo "ext3.fs ready."
