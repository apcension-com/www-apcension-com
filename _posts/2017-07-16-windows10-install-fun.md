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

Stumbled across an annoying little issue the other morning performing a reload of Windows 10 on to an existing Lab setup for a client.  This machine has had a number of OS configurations over the past 9 mo and is used for computation analysis (and why they aren't using VM's).  

I immediately ran into an issue with a disk / partition error.  Quick Stack Overflow / Google searches were all pointing at random things with a general theme: [1](https://blogs.technet.microsoft.com/asiasupp/2012/03/06/error-we-couldnt-create-a-new-partition-or-locate-an-existing-one-for-more-information-see-the-setup-log-files-when-you-try-to-install-windows-8-cp/){:target="_blank"}, [2](http://windowsreport.com/we-couldnt-create-a-new-partition/){:target="_blank"}, [3](http://robertgreiner.com/2015/08/windows-10-couldnt-create-a-new-partition/){:target="_blank"}.

After researching the issue for more details, one thing was for certain, folks have run into some pretty weird installation problems with Windows over the years.  The problem I ran into ended up being a tad different than most of the posts above ellude to, but similar enough for the error the installer provided:

`Error: "We couldn't create a new partition or locate an existing one`

I used [Rufus](https://rufus.akeo.ie/){:target="_blank"} to create a bootable USB thumb-drive from an ISO the client had (no DVD drives on these servers). I went about attempting to install windows10 onto the primary Disk 0, leaving Disk 1 for CentOS and a third dis for their vast dataset.  I tried a number of methods to clean up Disk 0, create a fresh partition, make sure it's active, etc; but each time the wonderful installer would fail with the above error.  Fun.

# A little history on this Machine.

Little known to me at the time (clients machine, not one I had dealt with the original setup), this server previously had a dual-boot with windows8 and CentOS6, but had mistakenly been completely wiped w/ an updated CentOS7, still on Disk1.

Back to getting the box refreshed with Windows10, I eventually found the issue w/ the RAID configuration (after fiddling w/ `diskpart` and the BIOS for way too long).  Turns out that with the previous dual-boot, as CentOS and grub were on the second disk (Disk 1), the RAID controller was configured to point at virtual Drive as the primary containing the MBR.  During their previous accidental refresh when CentOS7 was loaded directly to Disk 1, things coincidentally continued to work fine being that the OS was still loaded onto Disk 1.  When I went in and attempted to install a fresh windows 10 on the first disk, windows complained since the RAID controller was only still set for Disk 1, not the windows target of Disk 0.

# RAID Web Bios

This server uses an LSI MegaRaid setup and has a web BIOS (read: ugly, basic UI).  Since I'm not that familiar w/ the LSI CLI, I booted into the GUI and poked around.  Once I discovered the RAID card was setup for a MBR on the wrong virtual drive (changing it to point at Disk 0), the installer finally gracefully continued on.

Really not a fan of GUI tools like this (or the 'web' bios nomenclature), but the LSI tool does make viewing all the details about your RAID setup
rather straight forward.  Here's a glimpse on how this machine is setup.  We're going to dive into the `Virtual Drives` menu option in the subsequent images.
![alt text](/images/raid3.jpg "Web Bios Default View")

Here's how I find the virtual drive setup.  The _Boot Drive_ was set to Disk 1, pointing to linux / grub to handle the now defunct dual boot.
![alt text](/images/raid1.jpg "Boot Drive pointing to old linux partition")

It was a simple change in the end, just set the _Boot Drive_ to 0, for Drive 0.
![alt text](/images/raid2.jpg "Boot Drive set to Disk 0")

# Back to the install

After the next boot and install attempt, Windows 10 finally proceeded without further errors. w00t.
