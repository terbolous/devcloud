#!/bin/bash

echo "******************************"
echo `ls /root`
echo "******************************"

mkdir /tmp/vbox
VER=$(cat /root/.vbox_version)
mount -o loop /root/VBoxGuestAdditions_$VER.iso /tmp/vbox
sh /tmp/vbox/VBoxLinuxAdditions.run
umount /tmp/vbox
rmdir /tmp/vbox
rm /root/*.iso
