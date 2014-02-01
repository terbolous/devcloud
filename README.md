devcloud
========

This is a Packer and Vagrant build environment created from devcloud2

### Creating the Virtualbox image and Vagrant box

Check out this project, either using git or download as a zip file:

 - ```git clone https://github.com/snowch/devcloud.git```
 - ```wget https://github.com/snowch/devcloud/archive/master.zip && unzip master.zip```

To build the Vagrant box, make sure [packer](http://www.packer.io/) is installed and on your path, then cd into the new folder and run:

```packer build -force -var "headless=true" template.json```

If you have bash installed, you can use the script ```packer_build.sh``` to save some typing.

If packer finishes successfully, you should have:

```
output-virtualbox-iso/
├── packer-virtualbox-iso-disk1.vmdk
└── packer-virtualbox-iso.ovf
```

### Running with Virtualbox

After building with packer, you can import the file ```packer-virtualbox-iso.ovf``` into Virtualbox and run it.

### Running with Vagrant

After building with packer, make sure you have installed [Vagrant](http://www.vagrantup.com/), then from the project folder, run:

```vagrant up```

### Issues

Please report any issues using the github issue tracker for this project.

### Feedback

Any questions, please contact me: chsnow123 at gmail.com 
