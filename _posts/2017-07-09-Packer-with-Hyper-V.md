---
title: Packer with Hyper-V
comments: true
header:
  overlay_image: /assets/images/unsplash-image-gallery-6-th.png
  overlay_filter: 0.5
  show_overlay_excerpt: false
  teaser: /assets/images/unsplash-image-gallery-6-th.png
permalink: /articles/Packer/
---
### PACKER

HashiCorp has been an amazingly disruptive force in the DevOps world - for the better. They bring a focused vision for automation tools that transcend cloud and baremetal infrastructure. One such tool that I’ve used for a few years now is Packer. Whether you are leveraging an ephemeral stack on the cloud or streamlining internal virtual machines, Packer provides a wonderful foundation to build upon.

A recent client project had a use case for automating a CentOS 7 image destined for Hyper-V via Window 10. I’ve somehow managed to avoid Hyper-V for a while now, so I’ll leverage this opportunity to share some learnings and pitfalls using Packer with Windows 10.

For more background on Packer and how to use it, head over to their Docs - plenty of examples to get your going. I’ve also put some samples from this article out in git repo.

### HYPER-V SETUP

Not all versions of Windows can leverage Hyper-V, we’ll be using a Windows 10 Pro install for this guide. As the networking stack between a linux VM and windows Hyper-V can be a little ‘fun’, I create an Internal virtual Switch before kicking off Packer. This switch is also setup as a virtual NAT so the linux guest can get out to the network and download assets. The Packer Builder for Hyper-V will default to looking for an External switch and will create one if none are found. This can be cumbersome to get fully fleshed out depending on your setup, so experiment with your guest VM to see which works best and meets requirements.

Enable Hyper-V, if available for your Windows 10 rev. Run the following via a Powershell console, as administrator:

    Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All


In a Powershell console, run the following as an administrator: *setupVirtualSwitch.ps1*

    # the name of our internal vSwitch.  This needs to match what we configure below in the packer.json
    $VS = "internal_vSwitch"

    # create the virtual swithc
    New-VMSwitch -SwitchName $VS -SwitchType Internal

    # get the interface index and then set the IP / netmask
    $IF_INDEX = (Get-NetAdapter -Name "vEthernet ($VS)").ifIndex
    New-NetIPAddress -IPAddress 192.168.10.1  -PrefixLength 24 -InterfaceIndex $IF_INDEX

    # now that the interface is configured, let's add a virtual NAT.
    # this is what allows our guest VM, also configured on the 192.168.10.0/24 net to route out and download packages.
    New-NetNat -Name "internal_vNAT" -InternalIPInterfaceAddressPrefix 192.168.10.0/24

### PACKER BASICS

I’m going to review using a CentOS 7.3 1611 ISO, other distro’s may behave slightly differently. Go grab an ISO you’re interested in using and place it into your project directory.

Let’s create a json file which will be the primary set of configurations we pass into Packer: ```packer.json```. If you are starting on a fresh project, it’s always a good idea to review the basic example from the associated builder docs along with reviewing all the available options.

*packer.json*

    {
      "builders": [
        {
          "vm_name": "packer-demo",
          "type": "hyperv-iso",
          "boot_command": [
            "<tab> text inst.ks=hd:fd0:/ks.cfg <enter><wait>"
          ],
          "generation": 1,
          "floppy_files": ["ks.cfg"],
          "enable_secure_boot": false,
          "boot_wait": "10s",
          "disk_size": 25360,
          "ram_size": 2048,
          "cpu": 2,
          "iso_url": "CentOS-7-x86_64-Minimal-1611.iso",
          "iso_checksum_type": "sha256",
          "iso_checksum": "27bd866242ee058b7a5754e83d8ee8403e216b93d130d800852a96f41c34d86a",
          "ssh_username": "packer",
          "ssh_password": "packer",
          "ssh_port": 22,
          "communicator": "ssh",
          "ssh_timeout": "15m",
          "switch_name": "internal_vSwitch",
          "shutdown_command": "echo 'packer'|sudo -S /sbin/halt -h -p"
        }
      ]
    }

### KICKSTART

Next the kickstart file. This will let Anaconda perform an unattended installation upon boot. As noted above, we’re having Packer mount the kickstart via a virtual Floppy Drive as the guest tools are not yet installed on the guest OS, network connectivity between Hyper-V and the guest won’t work… yet.

There are a number of things I won’t dive into in this Kickstart, but please comment below if there are questions. We’re basically performing a very minimal install, adding a packer user and giving them full Sudo which will not prompt for a password. Packer will then use this account to perform further bootstrapping once CentOS7 is installed and SSH is accessible.

*ks.cfg*

    install
    cdrom
    lang en_US.UTF-8
    keyboard us
    network --hostname centos7-guest --ip=192.168.10.10 --gateway=192.168.10.1 --nameserver=8.8.8.8 --netmask=255.255.255.0  --noipv6 --device=eth0 --onboot=yes --bootproto=static --activate
    unsupported_hardware
    rootpw change_and_encrypt
    # the firewall rules are added via scripts/base.sh
    firewall --enable
    selinux --permissive
    timezone Etc/UTC --utc
    bootloader --driveorder=sda,hda --location=mbr
    text
    skipx
    zerombr
    clearpart --all --initlabel
    part /boot --size=500 --fstype=ext4
    part pv --size=500 --grow
    volgroup os --pesize=4096 pv
    logvol /  --size=1024 --grow --name=root --vgname=os --fstype=ext4
    logvol swap --size=4096 --name=swap --vgname=os
    auth --enableshadow --passalgo=sha512 --kickstart
    firstboot --disabled
    eula --agreed
    services --enabled=NetworkManager,sshd
    reboot --eject
    user --name=packer --plaintext --password assadadd --groups=packer

    %packages --ignoremissing --excludedocs
    @Base

    # firmware we shouldn't need, reduces image size.
    -aic94xx-firmware
    -atmel-firmware
    -b43-openfwwf
    -bfa-firmware
    -ipw2100-firmware
    -ipw2200-firmware
    -ivtv-firmware
    -iwl100-firmware
    -iwl105-firmware
    -iwl135-firmware
    -iwl1000-firmware
    -iwl2000-firmware
    -iwl2030-firmware
    -iwl3160-firmware
    -iwl3945-firmware
    -iwl4965-firmware
    -iwl5000-firmware
    -iwl5150-firmware
    -iwl6000-firmware
    -iwl6000g2a-firmware
    -iwl6000g2b-firmware
    -iwl6050-firmware
    -iwl7260-firmware
    -iwl7265-firmware
    -libertas-usb8388-firmware
    -ql2100-firmware
    -ql2200-firmware
    -ql23xx-firmware
    -ql2400-firmware
    -ql2500-firmware
    -rt61pci-firmware
    -rt73usb-firmware
    -xorg-x11-drv-ati-firmware
    -zd1211-firmware
    %end

    # post-installation.  Keep this minimal as we'll move extra logic
    # into another bash script run via packer.

    %post --log=/root/post.log
    echo "packer        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/packer
    sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

    # necessary for proper hyperV network comms
    yum install -y hyperv-daemons-0-0.29.20160216git.el7.x86_64
    %end

Let’s give this a quick validation and then attempt to build it (make sure packer.exe is your Path):

    packer.exe validate packer.json
    Template validated successfully.


    packer.exe build packer.json
    ...

A bunch of things are happening in quick succession. Packer is creating a VHDX for the image, setting image settings, mounting up the virtual Floppy and DVD to the Hyper-V guest and booting the guest. Once the VM boots the CentOS installer via the ISO/DVD, it virtually types the ```boot_command``` to bypass the CentOS Anaconda graphical install and performs an unattended Kickstart installation.

On the cmd window which you launched Packer, it will eventually get to a point where it’s waiting to connect via SSH to the underlying VM. This will take some time until the guest OS installation is complete and the post-installation begins (which we’re setting up our sudo privs for the packer user and installing a yum package: hyperv-daemons). This package is important as it enables communication between the guest VM <-> HyperV. Once the install is complete and post-installation has run, the GuestVM will automatically reboot. If everything worked correctly, Packer will eventually connect and move on to any additional provisioner steps to perform, which we’ll add next.

At this point, the VM will turn off / shutdown and packer will export it to a local folder in your project space.
