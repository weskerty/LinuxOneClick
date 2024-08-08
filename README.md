# 🌎 Select Language;
[![en](https://img.shields.io/badge/English-en-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es-419.md)

# 🐧 Linux in one Click
Install Linux from Windows Easily
Without Risks, Keeping Windows with All Your Files.

# 💾 Simply Download and Install [This File ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1)

>[!NOTE]
> 🔓 SecureBoot Disabled Required. If you have it enabled, the program will be installed but when you restart, Windows will start normally.
# [🔓 Guide on how to Disable SecureBoot ↗️](Guides/SecureBoot.md)

# Demonstration Video:
>[!NOTE]
> The video is accelerated, this will take time depending on your PC.<br>
> When you open the Exe, the explorer window will hang until it finishes copying if you have activated User Account Control


# 🤨 What does this do to my PC?
The Executable decompresses all this in C:/MiLinux/ <br>
If UEFI is detected, install [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
In case of BIOS Detect, Install [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Added modules like [vdiskchain and ipxe](https://github.com/ventoy/vdiskchain) that are necessary for VDI Boot <br>
A 25GB VDI is added to C:/MiLinux/MiLinux.vtoy. This is the Linux Disk. <br>
Set rEFInd or Grub2 as Boot Manager. <br>

# 🐧 MyLinux
In the VDI it was done;
* OEM installation of Linux Mint

Changes in the Installation;
* Running [vtoyBoot](https://github.com/ventoy/vtoyboot)
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Timeout 1s and mitigations=off.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); added relatime, nodiratime, noatime.
You can Adjust these details in their Respective Files.
If mitigations bother you, just delete it. sudo nano /etc/default/grub and delete mitigations=off, save it and then update grub with sudo update-grub

# [🌄Home Theme Installation ↗️](Guides/Themes.md)

# 💢 Bugs? [Report it Here ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

# 🗑️ Uninstallation;
Just go to C:/MyLinux/uninstall.exe to Uninstall it.

# 🖥️ This works on; <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] Windows XP SP3 32 and 64Bits (Official) - VirtualBox
- [x] Windows Vista 32 and 64Bits - VirtualBox
- [x] Windows7 SP1 32 and 64Bits - VirtualBox
- [x] Windows10 22H2 32 and 64Bits - GigabyteA320M
- [?] Windows11 23H3 64 Bit

>[!NOTE]
> Although installed on 32Bit Windows, the Processor must be 64Bit Compatible to Start LinuxMint. <br>
> The Script uses Partition C:/. If it is not available it will fail. <br>

> [!WARNING]
> The installation will damage the WindowsXP Boot if it is not Official WXP.
> In case the System does not start again, Press the [BootMenu Button ↗️](Guides/BootMenu.md) as soon as your PC starts. Then Choose WindowsBootLoader<br>
> Alternatively you can use a [Repair Disk ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86- 20240711-english-version.html) to Start Windows or Recover your Files.
# [💽 Guide on How to Install LinuxMint Directly ↗️](Guides/LinuxInstall.md)

# 💗 Used [NSIS Mod](https://sourceforge.net/projects/nsisbi/files/nsisbi3.04.1/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain] (https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/ )

# 📝 Everyone is Free to Edit this Concoction of Scripts

Old Video in Script mode.
https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0
This was beautiful, unfortunately it didn't work with W7 and below, not even with curl due to certificate errors.
