# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "devcloud"
  config.vm.box_url = "./packer_virtualbox-iso_virtualbox.box"

  config.vm.provider "virtualbox" do |v|
#    v.gui = true
  end

end