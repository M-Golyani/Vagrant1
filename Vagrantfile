# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

 config.vm.synced_folder ".", "/vagrant", disabled: true

 (1..2).each do |i|


  config.vm.define "nfs#{i}" do |nfs|
   nfs.vm.network "private_network", ip: "10.1.2.#{i+24}"
   nfs.vm.hostname = "nfs#{i}.deposit-solutions.local"
   nfs.vm.box = "ubuntu/bionic64"
   nfs.vm.provider "virtualbox" do |v|
    v.name = "vg_nfs#{i}"
    if not File.exist?("nfs#{i}.disk2.vmdk")
     v.customize [ "createmedium", "disk", "--filename", "nfs#{i}.disk2.vmdk", "--size", 1024 ]
    end
    if not File.exist?("nfs#{i}.raid1.vmdk")
     v.customize [ "createmedium", "disk", "--filename", "nfs#{i}.raid1.vmdk", "--size", 1024 ]
    end
    if not File.exist?("nfs#{i}.raid2.vmdk")
     v.customize [ "createmedium", "disk", "--filename", "nfs#{i}.raid2.vmdk", "--size", 1024 ]
    end
    if not File.exist?("nfs#{i}.raid3.vmdk")
     v.customize [ "createmedium", "disk", "--filename", "nfs#{i}.raid3.vmdk", "--size", 1024 ]
    end
    v.customize [ "storageattach", "vg_nfs#{i}", "--storagectl", "SCSI", "--port", "2", "--device", "0", "--type", "hdd", "--medium", "nfs#{i}.disk2.vmdk" ]
    v.customize [ "storageattach", "vg_nfs#{i}", "--storagectl", "SCSI", "--port", "3", "--device", "0", "--type", "hdd", "--medium", "nfs#{i}.raid1.vmdk" ]
    v.customize [ "storageattach", "vg_nfs#{i}", "--storagectl", "SCSI", "--port", "4", "--device", "0", "--type", "hdd", "--medium", "nfs#{i}.raid2.vmdk" ]
    v.customize [ "storageattach", "vg_nfs#{i}", "--storagectl", "SCSI", "--port", "5", "--device", "0", "--type", "hdd", "--medium", "nfs#{i}.raid3.vmdk" ]
   end
  end


#### PROVISIONING ON MACHINES ####


# Setup RAID:
  config.vm.provision "Setting up RAID array", type: "shell", inline: "mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sdc /dev/sdd /dev/sde /dev/sdf"


# Install needed packages:
  config.vm.provision "Installing Packages", type: "shell", path: "./configs/pkgInst.sh" , env: {"DEBIAN_FRONTEND" => "noninteractive"}


# Do partitioning on raid disk
#
  config.vm.provision "Creating partitions", type: "shell", inline: 'echo -e "n\n\n\n\n\nw\n" | fdisk /dev/md0'


# Copy config files into the machines
#
#

# Create /etc/hosts:
#


  config.vm.provision "Creating /etc/hosts", type: "shell", path: "./configs/create_etc_hosts.sh", args: "nfs#{i}"

#  config.vm.provision "Uploading /etc/hosts", type: "file", source: "./configs/etc-hosts", destination: "./etc/hosts"
#  config.vm.provision "Copying /etc/hosts", type: "shell", inline: "cp -f ./etc/hosts /etc/hosts"


# Copy drbd configs:
#
  config.vm.provision "Uploading drbd's global_common.conf", type: "file", source: "./configs/drbd-global_common.conf", destination: "./etc/drbd.d/global_common.conf"
  config.vm.provision "Uploading drbd's config", type: "file", source: "./configs/drbd-redundant1.res", destination: "./etc/drbd.d/redundant1.res"
  config.vm.provision "Uploading drbd service file for systemd", type: "file", source: "./configs/etc-systemd-drbd", destination: "./etc/systemd/system/runbrbd.service"
  config.vm.provision "Uploading run script for drbd", type: "file", source: "./configs/opt-runbr.sh", destination: "./opt/runbrbd.sh"


  config.vm.provision "Copying drbd's global_common", type: "shell", inline: "cp -f ./etc/drbd.d/global_common.conf /etc/drbd.d/global_common.conf"
  config.vm.provision "Copying drbd's config", type: "shell", inline: "cp -f ./etc/drbd.d/redundant1.res /etc/drbd.d/redundant1.res"
  config.vm.provision "Copying drbd's systemd file", type: "shell", inline: "cp -f ./etc/systemd/system/runbrbd.service /etc/systemd/system/runbrbd.service"
  config.vm.provision "Copying drbd's run script in /opt", type: "shell", inline: "cp -f ./opt/runbrbd.sh /opt/runbrbd.sh"



  
  config.vm.provision "Setting permissions for drbd's run script", type: "shell", inline: "chmod 755 /opt/runbrbd.sh"

# Add drbd module to /etc/modules (to be loaded on boot)
#
  config.vm.provision "Adding drbd module to /etc/modules", type: "shell", inline: 'echo "drbd" >> /etc/modules'

# Load the module into the kernel:
#
  config.vm.provision "Running modprobe drbd", type: "shell", inline: "modprobe drbd"

# Start the drbd service:
#
  config.vm.provision "Creating resource for drbd", type: "shell", inline: "drbdadm create-md r0"
  config.vm.provision "Bringing up the drbd resource", type: "shell", inline: "drbdadm up r0"
  config.vm.provision "Switching to primary state for drbd", type: "shell", inline: "drbdadm primary r0 --force"

# Format the drbd partition:
#
  config.vm.provision "Creating ext4 filesystem on drbd device", type: "shell", inline: "mkfs.ext4 -F /dev/drbd0"

# Create the /srv/data directory and set fstab:
#
  config.vm.provision "Creating /srv/data directory", type: "shell", inline: "mkdir -p /srv/data"
  config.vm.provision "Adjusting /etc/fstab", type: "shell", inline: 'echo "/dev/drbd0              /srv/data        ext4   defaults        0 0" >> /etc/fstab'

# Set /etc/exports:
#
  config.vm.provision "Setting /etc/exports", type: "shell", inline: 'echo "/srv/data       *(ro,sync,no_subtree_check)" >> /etc/exports'

# Copy keepalived config files:
#
  config.vm.provision "Uploading keelalived config file", type: "file", source: "./configs/etc-kplv-kplv.cnf", destination: "./etc/keepalived/keepalived.conf"
  config.vm.provision "Uploading keepalived notify script", type: "file", source: "./configs/etc-kplv-notif.sh", destination: "./etc/keepalived/notif1.sh"

  config.vm.provision "Copying keepalived config file", type: "shell", inline: "cp -f ./etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf"
  config.vm.provision "Copying keepalived notify script", type: "shell", inline: "cp -f ./etc/keepalived/notif1.sh /etc/keepalived/notif1.sh"

  config.vm.provision "Setting notify script permissions.", type: "shell", inline: "chmod 755 /etc/keepalived/notif1.sh"


# Setup systemd
#
  config.vm.provision "Reload systemd configurations", type: "shell", inline: "systemctl daemon-reload"
  config.vm.provision "Enabling keepalived", type: "shell", inline: "systemctl enable keepalived"
  config.vm.provision "Enabling NFS", type: "shell", inline: "systemctl enable nfs-kernel-server"

 end


end
