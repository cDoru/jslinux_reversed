#!/bin/bash

set -e -u

openwrt_root='../../openwrt/build_dir/target-i386_uClibc-0.9.33.2/root-x86'
openwrt_root='/home/mmarkk/src/deboo/squeeze'

rm -f hda.img
fallocate --length=90M hda.img
mkfs -F -q -t ext2 hda.img
ddd=outimage
mkdir -p $ddd

echo 'root:qwe' | sudo chroot "$openwrt_root" chpasswd
sudo unshare -m -- bash -c "
set -x -e -u
mount -n -o loop hda.img -t ext2 $ddd
tar -C $openwrt_root \
    --exclude='./var/cache*' \
    --exclude='./usr/share/locale*' \
    --exclude='./usr/share/zoneinfo*' \
    --exclude='./usr/share/doc*' \
    --exclude='./usr/share/man*' \
    --exclude='./usr/share/info*' \
    --exclude='./var/lib/apt*' \
    -c . | tar -C $ddd -x

rm -f $ddd/sbin/init;
cp -f init.sh $ddd/sbin/init

rm -rf $ddd/root
ln -s /tmp/root $ddd/root

rm -rf $ddd/var/run
ln -s /tmp     $ddd/var/run

:>| $ddd/etc/resolv.conf
rm -f $ddd/etc/mtab
ln -s /proc/mounts $ddd/etc/mtab
mknod $ddd/dev/ppp c 108 0
mknod $ddd/dev/clipboard c 10 231
mknod $ddd/dev/ttyS0 c 4 64
mknod $ddd/dev/ttyS1 c 4 65
mknod $ddd/dev/ttyS2 c 4 66
mknod $ddd/dev/ttyS3 c 4 67
echo -e '#!/bin/sh\necho \$* > /dev/clipboard\n' > $ddd/bin/answer
chmod a+x $ddd/bin/answer
df -h $ddd/
"
rm -rf $ddd
make splitted
