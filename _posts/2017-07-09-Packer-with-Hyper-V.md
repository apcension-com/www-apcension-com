---
title: Packer with Hyper-V
header:
  teaser: /assets/images/unsplash-image-gallery-6-th.png
permalink: /Packer/
---
### PACKER

HashiCorp has been an amazingly disruptive force in the DevOps world - for the better. They bring a focused vision for automation tools that transcend cloud and baremetal infrastructure. One such tool that I’ve used for a few years now is Packer. Whether you are leveraging an ephemeral stack on the cloud or streamlining internal virtual machines, Packer provides a wonderful foundation to build upon.

A recent client project had a use case for automating a CentOS 7 image destined for Hyper-V via Window 10. I’ve somehow managed to avoid Hyper-V for a while now, so I’ll leverage this opportunity to share some learnings and pitfalls using Packer with Windows 10.

For more background on Packer and how to use it, head over to their Docs - plenty of examples to get your going. I’ve also put some samples from this article out in git repo.

### HYPER-V SETUP

Not all versions of Windows can leverage Hyper-V, we’ll be using a Windows 10 Pro install for this guide. As the networking stack between a linux VM and windows Hyper-V can be a little ‘fun’, I create an Internal virtual Switch before kicking off Packer. This switch is also setup as a virtual NAT so the linux guest can get out to the network and download assets. The Packer Builder for Hyper-V will default to looking for an External switch and will create one if none are found. This can be cumbersome to get fully fleshed out depending on your setup, so experiment with your guest VM to see which works best and meets requirements.

Enable Hyper-V, if available for your Windows 10 rev. Run the following via a Powershell console, as administrator:

Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
In a Powershell console, run the following as an administrator: setupVirtualSwitch.ps1

<<INSERT IMAGES>>

### PACKER BASICS

I’m going to review using a CentOS 7.3 1611 ISO, other distro’s may behave slightly differently. Go grab an ISO you’re interested in using and place it into your project directory.

Let’s create a json file which will be the primary set of configurations we pass into Packer: packer.json. If you are starting on a fresh project, it’s always a good idea to review the basic example from the associated builder docs along with reviewing all the available options.

<<INSERT IMAGE>>

### KICKSTART

Next the kickstart file. This will let Anaconda perform an unattended installation upon boot. As noted above, we’re having Packer mount the kickstart via a virtual Floppy Drive as the guest tools are not yet installed on the guest OS, network connectivity between Hyper-V and the guest won’t work… yet.

There are a number of things I won’t dive into in this Kickstart, but please comment below if there are questions. We’re basically performing a very minimal install, adding a packer user and giving them full Sudo which will not prompt for a password. Packer will then use this account to perform further bootstrapping once CentOS7 is installed and SSH is accessible.

<<INSERT IMAGE>>

Let’s give this a quick validation and then attempt to build it (make sure packer.exe is your Path):

<<INSERT IMAGE>>

A bunch of things are happening in quick succession. Packer is creating a VHDX for the image, setting image settings, mounting up the virtual Floppy and DVD to the Hyper-V guest and booting the guest. Once the VM boots the CentOS installer via the ISO/DVD, it virtually types the boot_command to bypass the CentOS Anaconda graphical install and performs an unattended Kickstart installation.

On the cmd window which you launched Packer, it will eventually get to a point where it’s waiting to connect via SSH to the underlying VM. This will take some time until the guest OS installation is complete and the post-installation begins (which we’re setting up our sudo privs for the packer user and installing a yum package: hyperv-daemons). This package is important as it enables communication between the guest VM <-> HyperV. Once the install is complete and post-installation has run, the GuestVM will automatically reboot. If everything worked correctly, Packer will eventually connect and move on to any additional provisioner steps to perform, which we’ll add next.

At this point, the VM will turn off / shutdown and packer will export it to a local folder in your project space.
