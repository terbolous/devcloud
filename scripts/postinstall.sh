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
  apt-get --no-install-recommends -q -y --force-yes install git vim tcpdump ebtables iptables openssl openssh-server openjdk-6-jdk genisoimage python-pip nfs-kernel-server

  # mysql with root password=password
  echo 'mysql-server-<version> mysql-server/root_password password password' | debconf-set-selections 
  echo 'mysql-server-<version> mysql-server/root_password_again password password' | debconf-set-selections
  apt-get --no-install-recommends -q -y --force-yes install mysql-server

  # xen and xcp
  echo 'xcp-networkd xcp-xapi/networking_type select bridge' | debconf-set-selections
  apt-get --no-install-recommends -q -y --force-yes install xcp-networkd
  apt-get --no-install-recommends -q -y --force-yes install linux-headers-3.2.0-4-686-pae xen-hypervisor-4.1-i386 xcp-xapi xcp-xe xcp-guest-templates xcp-vncterm xen-tools blktap-utils blktap-dkms qemu-keymaps qemu-utils

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
fix_locale
fix_grub

fin=$(date +%s)
t=$((fin-begin))

echo "DevCloud baked in $t seconds"
