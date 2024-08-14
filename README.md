## 🌎 Select Language;
[![en](https://img.shields.io/badge/English-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es.md)

## 🐧 Linux in one Click
Install Linux from Windows Easily
Without Risks, Keeping Windows with All Your Files.
## 💾 Simply Download and Install [This File ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1)
Relax Until the Process Finishes. You can do other things while it installs, like surf the Internet.

## 📹 Demonstrative Video:
https://github.com/user-attachments/assets/f729b276-0923-41c1-9bd5-7d44e5524a82
>[!NOTE]
> The video is accelerated, this will take time depending on your PC.<br>
> 35GB of Free Space Required. <br>
> When you open the Exe, the explorer window will hang until it finishes copying if you have User Account Control activated. Patience. <br>
> 🔓 SecureBoot Disabled Required. If you have it enabled, the program will be installed but when you restart, Windows will start normally.
## [🔓 Guide on how to Disable SecureBoot ↗️](Guides/SecureBoot/SecureBoot.md)

## 🤨 What does this do to my PC?
The Executable decompresses all this in C:/MiLinux/ <br>
If UEFI is detected, install [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
In case of BIOS Detect, Install [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Added modules like [vdiskchain and ipxe](https://github.com/ventoy/vdiskchain) that are necessary for VDI Boot <br>
A 25GB VDI is added to C:/MiLinux/MiLinux.vtoy. This is the Linux Disk. <br>
Set rEFInd or Grub2 as Boot Manager. <br>

## 🙋💖 Linux Help Groups 🤗
#### Spanish;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/LinuxGroups/)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?logo=whatsapp&logoColor=fff&style=flat)](https://chat.whatsapp.com/BsBW4RbEVpj8KO22AN2KDB)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=fat&logo=telegram&logoColor=white)](https://t.me/addlist/pbpqO72i6x44MmQx)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/XYYvqUF3pG)
#### PortuguêsBR;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/brlinux/)
#### English;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/GNUAndLinux/)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/D4ETYhq)

## [🌄Home Themes Installation ↗️](Guides/Themes/Themes.md)

## 💢 Bugs? [Report it Here ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

## 🗑️ Uninstallation;
Just go to C:/MyLinux/uninstall.exe to Uninstall it.

## [💿 Increase Linux VDI Storage Size ↗️](Guides/VDI/VDI.md)

## 🐧 MyLinux
In the VDI it was done;
* OEM installation of Linux Mint
* Running [vtoyBoot](https://github.com/ventoy/vtoyboot) <br>
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Aggregate; VTOY_LINUX_REMOUNT=1 mitigations=off. <br>
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); Aggregate; relatime, nodiratime, noatime. <br>
You can Adjust these details in their Respective Files. <br>
If mitigations bother you, just delete it. sudo nano /etc/default/grub and delete mitigations=off, save it and then update grub with sudo update-grub

## 🖥️ This works on; <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] WindowsXP 32 and 64Bits (Official) - VirtualBox
- [x] WindowsVista 32 and 64Bits - VirtualBox
- [x] Windows7 32 and 64Bits - VirtualBox
- [x] Windows10 32 and 64Bits - GigabyteA320M
- [x] Windows11 23H3 64 Bit - VirtualBox

>[!NOTE]
> Although installed on 32Bit Windows, the Processor must be 64Bit Compatible to Start LinuxMint. <br>
> The Script uses Partition C:/. If it is not available nothing will happen. <br>

> [!WARNING]
> The installation will damage the WindowsXP Boot if it is not Official WXP. <br>
> In case Windows does not start again, press the [BootMenu Button ↗️](Guides/BootMenu/BootMenu.md) as soon as your PC starts. Then Choose WindowsBootLoader<br>
> Alternatively you can use a [Repair Disk ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86-20240711-english-version.html) to Start Windows. <br>

## [💽 Guide on How to Install LinuxMint Directly ↗️](Guides/LinuxInstall/LinuxInstall.md)

## 💗 Used [NSISMod](https://sourceforge.net/projects/nsisbi/files/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain](https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/), [![GHBadges](https://img.shields.io/badge/Badges-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/alexandresanlim/Badges4-README.md-Profile/blob/master/README.md)

## 📝 Everyone is Free to Edit this Concoction of Scripts

<details>
<summary>Old</summary>
This was beautiful, you could even choose which Distro to install. But unfortunately it did not work with W7 and below, not even with curl due to certificate errors.

<video src="https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0">

</details>
