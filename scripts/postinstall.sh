# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -x

install_packages() {
  DEBIAN_FRONTEND=noninteractive
  DEBIAN_PRIORITY=critical

  # utlities
  apt-get --no-install-recommends -q -y --force-yes install python bzip2 sed gawk diffutils grep gzip less tar telnet wget zip unzip sudo

  # dev tools, ssh, nfs
  apt-get --no-install-recommends -q -y --force-yes install git vim tcpdump ebtables iptables openssl openssh-server openjdk-7-jdk genisoimage python-pip nfs-kernel-server

  # mysql with root password=password
  echo 'mysql-server-<version> mysql-server/root_password password password' | debconf-set-selections 
  echo 'mysql-server-<version> mysql-server/root_password_again password password' | debconf-set-selections
  apt-get --no-install-recommends -q -y --force-yes install mysql-server

  # xen and xcp
  echo 'xcp-networkd xcp-xapi/networking_type select bridge' | debconf-set-selections
  apt-get --no-install-recommends -q -y --force-yes install xcp-networkd
  apt-get --no-install-recommends -q -y --force-yes install linux-headers-3.2.0-4-686-pae xen-hypervisor-4.1-i386 xcp-xapi xcp-xe xcp-guest-templates xcp-vncterm xen-tools blktap-utils blktap-dkms qemu-keymaps qemu-utils

  pip install mysql-connector-python
}


fix_mysql_password() {
  mysql -u root --password=password \
        -e "SET PASSWORD FOR root@localhost=PASSWORD('');"
}

setup_xen_and_xapi() {
  echo "bridge" > /etc/xcp/network.conf
  update-rc.d xendomains disable
  echo TOOLSTACK=xapi > /etc/default/xen
  sed -i 's/GRUB_DEFAULT=.\+/GRUB_DEFAULT="Xen 4.1-i386"/' /etc/default/grub
  sed -i 's/GRUB_CMDLINE_LINUX=.\+/GRUB_CMDLINE_LINUX="apparmor=0"\nGRUB_CMDLINE_XEN="dom0_mem=400M,max:500M dom0_max_vcpus=1"/' /etc/default/grub
  update-grub
  sed -i 's/VNCTERM_LISTEN=.\+/VNCTERM_LISTEN="-v 0.0.0.0:1"/' /usr/lib/xcp/lib/vncterm-wrapper
  cat > /usr/lib/xcp/plugins/echo << EOF
!/usr/bin/env python

# Simple XenAPI plugin
import XenAPIPlugin, time

def main(session, args):
    if args.has_key("sleep"):
        secs = int(args["sleep"])
        time.sleep(secs)
    return "args were: %s" % (repr(args))

if __name__ == "__main__":
    XenAPIPlugin.dispatch({"main": main})
EOF

  chmod -R 777 /usr/lib/xcp
  mkdir -p /root/.ssh
  ssh-keygen -A -q
}


fix_locale() {
  cat << EOF >> /etc/default/locale
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF
  cat << EOF >> /etc/locale.gen 
en_US.UTF-8 UTF-8
EOF

  locale-gen en_US.UTF-8
}

fix_grub() {
  # fix grub - see https://xen-orchestra.com/cant-find-hypervisor-information-in-sysfs/
  dpkg-divert --divert /etc/grub.d/08_linux_xen --rename /etc/grub.d/20_linux_xen
  update-grub
}


begin=$(date +%s)

install_packages
fix_mysql_password
setup_xen_and_xapi
fix_locale
fix_grub

fin=$(date +%s)
t=$((fin-begin))

echo "DevCloud baked in $t seconds"
