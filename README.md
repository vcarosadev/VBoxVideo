# VirtualBox Video Driver for NEXTSTEP 3.3 and Rhapsody Developer Release 2

The code provided here can be distributed according to GNU Public License v3 (GPLv3), see the full license [here](/COPYING).

## Overview

VBoxVideo is a video driver for **Oracle VirtualBox** virtual machines with **NEXTSTEP 3.3** or **Rhapsody Developer Release 2** operating systems.

The driver has been tested on VirtualBox Version 5 on a Windows 7 host and VirtualBox Version 6 on a Windows 10 host with both NEXTSTEP 3.3 and Rhapsody Developer Release 2.

## Building the driver

The driver has been built in NEXTSTEP 3.3 using the Driver Kit version 4.5.

In _Project Builder_ open the file [`PB.project`](/PB.project) in the root folder, click on _Builder_ and then on _Build_. Please note that there is also a [`PB.project`](/VBoxVideo_reloc.tproj/PB.project) file in the `VBoxVideo_reloc.tproj` folder, it's a subproject and is automatically loaded by the main project.

After a successful build in the main project folder there will be the built driver: a folder named `VBoxVideo.config`.

In the `build` folder of the repository there is also the archive file [`VBoxVideo.config.tar`](/build/VBoxVideo.config.tar) which contains the driver already built.

## Installing the driver

The following paragraphs will guide you in the process of installing the VBoxVideo driver in NEXTSTEP 3.3 and Rhapsody Developer Release 2 on VirtualBox.

While the driver is the same for both the operating systems, they use a different and incompatible file system so in the `build` folder you will find a floppy image for each OS.

Please note that every time you change the video mode (i.e. the resolution or the color depth) a restart of the operating system is required.

### NEXTSTEP 3.3 - Existing installation

In an existing installation follow these steps:

1. Mount in the virtual machine floppy the disk image file [`NEXTSTEP_VBoxVideoDriver.img`](/build/NEXTSTEP_VBoxVideoDriver.img) you can find in the `build` folder
2. In _Workspace Manager_ menu select _Disk_ -> _Check for Disk_
3. Double click on the Floppy named _VBoxVideo_, you can find the driver at the following path: `private\Drivers\i386`
4. Copy the folder `VBoxVideo.config` from the floppy disk to the `me` folder
5. Double click on `VBoxVideo.config` in the `me` folder, the _Configure_ App will open and a message will inform you of the correct installation
6. Click on the _Monitor_ icon on top and delete the currently installed driver by clicking the _Remove_ button. This will avoid warnings on conflicting resources
9. Click on the _Add_ button, the _Configure_ App should suggest the installation of the _VirtualBox Video Adapter_ driver, click _Add_
10. You can select the preferred video mode by clicking the _Select..._ button, the default video mode is 1024x768 with 16M colors
11. Once completed, click _Done_ then _Save_. Close the _Configure_ App by selecting _Quit_ in the _Configure_ menu
12. Remove the image from the virtual floppy by selecting _Disk_ -> _Eject_ in the _Workspace Manager_ menu. Unmount the image from the virtual floppy
13. Restart the operating system

### NEXTSTEP 3.3 - Operating System Setup

During the operating system setup follow these steps:

1. After selecting the drivers for the CD-ROM and the Hard Drive mount in the virtual machine floppy the disk image file [`NEXTSTEP_VBoxVideoDriver.img`](/build/NEXTSTEP_VBoxVideoDriver.img) you can find in the `build` folder
2. Enter 2 to load additional drivers from a disk, enter 1 to install the _Virtual Box Video Adapter_ driver
3. Enter 1 to continue the setup process
4. During the installation you will be prompted two times to insert the disk image [`NEXTSTEP_VBoxVideoDriver.img`](/build/NEXTSTEP_VBoxVideoDriver.img)

### Rhapsody Developer Release 2 - Existing installation

In an existing installation follow these steps:

1. Mount in the virtual machine floppy the disk image file [`Rhapsody_VBoxVideoDriver.img`](/build/Rhapsody_VBoxVideoDriver.img) you can find in the `build` folder
2. In _Workspace Manager_ menu select _Tools_ -> _Check for Disk_
3. Double click on the Floppy named _VBoxVideo_, you can find the driver at the following path: `private\Drivers\i386`
3. Copy the folder `VBoxVideo.config` from the floppy disk to the user folder
4. Double click on `VBoxVideo.config` in the user folder, the _Configure_ App will open
5. If you are logged in as a normal user Rhapsody will ask for the root user credentials, enter the credential and click _Login_
6. The _Configure_ App will show a message once the driver is successfully installed, click _OK_
7. The _Configure_ App will suggest to use the newly added driver, to avoid conflict with the existing video driver click _Cancel_
8. Delete the currently installed video driver by clicking the _Remove_ button
9. Click on the _Add_ button, the _Configure_ App should suggest the installation of the _VirtualBox Video Adapter_ driver, click _Add_
10. You can select the preferred video mode by clicking the _Select..._ button, the default video mode is 1024x768 with 16M colors
11. Once completed, click _Done_ then _Save_. Close the _Configure_ App by clicking on _Quit_
12. Remove the image from the virtual floppy by selecting _Tools_ -> _Eject_ in the _Workspace Manager_ menu.  Unmount the image from the virtual floppy
13. Restart the operating system

### Rhapsody Developer Release 2 - Operating System Setup

During the operating system setup follow these steps:

1. After selecting the drivers for the CD-ROM and the Hard Drive mount in the virtual machine floppy the disk image file [`Rhapsody_VBoxVideoDriver.img`](/build/Rhapsody_VBoxVideoDriver.img) you can find in the `build` folder
2. Enter 2 to load additional drivers from a disk, enter 1 to install the _Virtual Box Video Adapter_ driver
3. Enter 1 to continue the setup process
4. During the installation you will be prompted two times to insert the disk image [`Rhapsody_VBoxVideoDriver.img`](/build/Rhapsody_VBoxVideoDriver.img)

## Supported Video Modes

This table shows the video modes supported by the VBoxVideo driver (default in __bold__):

| Resolution | Bits per Pixel | Number of Colors|
|:----------:|:---:|:-----:|
| 640 x 480 | 16 (1 bit unused)| 32K |
| 800 x 600 | 16 (1 bit unused)| 32K |
| 1024 x 768 | 16 (1 bit unused)| 32K |
| 1152 x 864 | 16 (1 bit unused)| 32K |
| 1200 x 1024 | 16 (1 bit unused)| 32K |
| 1600 x 1200 | 16 (1 bit unused)| 32K |
| 640 x 480 | 32 (8 bits unused)| 16M |
| 800 x 600 | 32 (8 bits unused)| 16M |
| __1024 x 768__ |  __32__ __(8 bits unused)__| __16M__ |
| 1152 x 864 | 32 (8 bits unused)| 16M |
| 1200 x 1024 | 32 (8 bits unused)| 16M |
| 1600 x 1200 | 32 (8 bits unused)| 16M |

## Known Issues

Sometimes there is a failure when calling an OS function that should update the memory ranges used by the video adapter (this happens in both NEXTSTEP and Rhapsody). As a result of this failure it's impossible to map the correct range into the OS memory space.

For VirtualBox version 5 and 6 this isn't a blocking issue because the video frame buffer always starts at the fixed address `0xE0000000`. If in future releases of VirtualBox the frame buffer is dynamically set during the virtual machine startup the driver may not work anymore if the OS call fails.

## Acknowledgments

I would like to thank you the following people:

* Jason at "[Stuff Jason Does](http://stuffjasondoes.com/)" for [this tutorial](http://stuffjasondoes.com/2018/07/25/installing-nextstep-os-openstep-on-virtualbox-in-2018/) on how to install OpenStep. This project started after playing with the OS installations
* neozeed at "[Virtually Fun](https://virtuallyfun.com/wordpress/)" for the various articles on NEXTSTEP, Rhapsody, Darwin and OpenStep
* David Crosby (crosby@atomicobject.com) and Bill Bereza (bereza@atomicobject.com) and their project [VMwareFB_OpenStep](https://github.com/atomicobject/VMWareFB_OpenStep), a video driver for VMWare. Their work has been a great source of tips on how to write a driver for OPENSTEP/NEXTSTEP
* the people at "[NeXT Computers](http://www.nextcomputers.org/)" that made available a lot of files and documentation about the NeXT Computer and the related Operating Systems
* the people at "[WinWorld](https://winworldpc.com/home)" a treasure chest of ancient software including Rhapsody Developer Release 2 for Intel
