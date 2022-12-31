#!/system/bin/sh
echo "Are you sure?"
./umount.sh
find rootfs/dev rootfs/proc rootfs/sys
read
rm -rf rootfs
find .
echo "bruh"
