---
layout: post
title: Windows 10 Install Fun
published: true
date: 2017-07-16 19:00:01
author: Greg Richardson
twitter: apcension
published: true
tags: windows10 install raid
---

## Install Error

While there are all kinds of disk related installation issues ([1](https://blogs.technet.microsoft.com/asiasupp/2012/03/06/error-we-couldnt-create-a-new-partition-or-locate-an-existing-one-for-more-information-see-the-setup-log-files-when-you-try-to-install-windows-8-cp/), [2](http://windowsreport.com/we-couldnt-create-a-new-partition/), [3](http://robertgreiner.com/2015/08/windows-10-couldnt-create-a-new-partition/)) folks have run into with Windows 8 and Windows 10 over the years, I came across an especially annoying one I thought would make a good article.  This one is a tad different than the generic USB thumb-drive problem folks have had, but in the end, was related to being able to install to the 'primary disk'.

_Gotta love generic errors like this:_

`Error: "We couldn't create a new partition or locate an existing one`

After creating a USB thumb-drive from an ISO on another machine, I went about re-installing windows10 onto the primary Disk 0,
leaving Disk 1 for CentOS6 and a third for their dataset.  Each time I removed the partition, formated and attempt to continue on,
the wonderful installer would fail with the above error.  Fun.

# A little history on this Machine.

Little known to me at the time (clients machine, not one I had dealt with the original setup), this server previously had a dual-boot with windows8 and CentOS6, but had mistakenly been completely wiped w/ an updated CentOS7, still on Disk1.

Back to getting the box refreshed w/ Windows10, I eventually found the issue w/ the RAID configuration (after fiddling w/ `diskpart` and the BIOS for way too long).  Turns out that w/ the previous dual-boot, since centos and grub were on the second disk (Disk 1), the RAID controller was configured to point at Disk 1 as the primary.  This then continued to work fine when someone had refresh the system with only CentOS7, again, on the second Disk, ignoring the windows disk / installation completely.  When I went in and attempted to install a fresh windows 10 on the first disk, windows complained since the RAID controller was only set for Disk 1, not the windows target of Disk 0.

This server uses an LSI MegaRaid setup and has a web BIOS.  Here are a few images illustrating the setting and where to find it.  Once this setting was changed back to Disk 0, the installer finally continued on.  Once I go back and fix grub for a new dual boot, this setting will have to be adjusted back to Disk 1 (since grub exists on the linux disk).

# RAID Web Bios

Really not a fan of GUI tools like this (or the 'web' bios nomenclature), but the LSI  tool does make viewing all the details about your RAID setup
rather straight forward.  Here's a glimpse on how this machine is setup.  We're going to dive into the `Virtual Drives` menu option in the subsequent images.
![alt text](/images/raid3.jpg "Web Bios Default View")

Here's how I find the virtual drive setup.  The _Boot Drive_ was set to Disk 1, pointing to linux / grub to handle the now defunct dual boot.
![alt text](/images/raid1.jpg "Boot Drive pointing to old linux partition")

It was a simple change in the end, just set the _Boot Drive_ to 0, for Drive 0.
![alt text](/images/raid2.jpg "Boot Drive set to Disk 0")

# Back to the install

After the next boot and install attempt, Windows 10 finally proceeded on without fail.  It was rather seemless and couldn't help to think how a more useful message could've saved a few unnecessary hours searching and poking around a bit randomly.
