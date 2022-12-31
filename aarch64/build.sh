#!/system/bin/sh
echo "clean!!"
./clean.sh
echo "cleanned"
./apk -X http://mirrors4.bfsu.edu.cn/alpine/edge/main -X http://mirrors4.bfsu.edu.cn/alpine/edge/community -U --allow-untrusted -p rootfs --initdb add --no-cache alpine-base coreutils bash bash-completion shadow patchelf

cd rootfs

echo 'https://mirrors4.bfsu.edu.cn/alpine/edge/main' > etc/apk/repositories
echo 'https://mirrors4.bfsu.edu.cn/alpine/edge/community' >> etc/apk/repositories
cp /etc/resolv.conf etc/resolv.conf

mount -o bind /dev dev
mount -o bind /dev/pts dev/pts
mount -t proc none proc
mount -o bind /sys sys

env -i /system/bin/chroot . /usr/bin/env -i PATH=/sbin:/usr/sbin:/bin:/usr/bin TMPDIR=/tmp USER=root HOME=/root chsh -s /bin/bash
cp ../build_inside.sh tmp/build.sh
chmod +x tmp/build.sh
env -i /system/bin/chroot . /usr/bin/env -i PATH=/sbin:/usr/sbin:/bin:/usr/bin TMPDIR=/tmp USER=root HOME=/root bash /tmp/build.sh

cp -avf root/appstatic/appstatic ..
cp -avf etc/ssl/certs/ca-certificates.crt ..

umount dev/pts dev proc sys
find dev proc sys

cd ..
