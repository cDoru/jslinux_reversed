#!/bin/sh

echo "JSLinux started, initializing..."

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export HOME=/root
export TERM=vt100
mount -n -t proc /proc /proc
mount -n -t sysfs /sys /sys
mount -n -t devpts devpts /dev/pts
mount -n -t tmpfs /tmp /tmp
mkdir -p "/tmp/root"
ip link set up dev lo

main() { while :; do setsid sh -c "exec bash 3<>/dev/ttyS0 0<&3 1>&3 2>&3 3>&-"; done; }

. /dev/clipboard

main "$@"
