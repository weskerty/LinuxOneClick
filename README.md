# 🐧 Linux in one Click
Install Linux from Windows Easily
Without Risks, Keeping Windows with All Your Files.
>[!NOTE]
> Only for 64Bit Windows installed in UEFI

# Simply Download [ThisFile⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/InstallLinux.bat?viasf=1)
Then run it as Administrator.
The script will download Linux Mint and install it.

If the Previous Method does not work, [TryThis⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/LinuxInstall.ps1?viasf=1)

# Demonstration Video:
https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0

The video is accelerated, this will take much longer...

If that doesn't work for you, you can install it manually.
Download [elArchivoPrincipal↗️](https://sourceforge.net/projects/linuxoneclick/files/LOClicK.zip/download) with a download manager like JDownloader, Unzip it manually in C:/ and run the Installer.bat as shown in [ThisVideo↗️](https://www.youtube.com/watch?v=Y1K3TLja434).


# 💢Bug Fixes;

## Installer error;
[Use PowerShell Alternative⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/LinuxInstall.ps1?viasf=1)

[Use PowerShell Alternative #2 ⬇️](https://sitsa.dl.sourceforge.net/project/linuxoneclick/LinuxInstallAlternativa.ps1?viasf=1) This is slower, it can take up to 2H to Download.

## PowerShell Execution Policy Error;
![image](https://github.com/user-attachments/assets/1920e51d-2600-4341-9934-805f7050e9e7)

If this appears, simply press the `O` key and then `ENTER` and the Script will be executed. (the confirmation key varies by language.)


## 2
![image](https://github.com/user-attachments/assets/60d9ea10-d944-4bed-90f3-bdf435bec5fa)

You must open PowerShell manually and run this command, where what comes after `-File` is the location of the installer file (InstallLinuxMint.ps1)
```
powershell -ExecutionPolicy Bypass -File F:\Downloads\LinuxMint\InstallLinuxMint.ps1
```

# 🌌 Change rEFInd theme;
 Download a [CatalogTheme↗️](https://refind-themes-collection.netlify.app/)

And Move it to the Folder `C:\LinuxMint\refind\themes`

![image](https://github.com/user-attachments/assets/86d591ac-8071-406a-9069-8d2d8d8fc327)

Open `refind.confg` with a text editor and modify the last line with the folder name of your new theme.

![image](https://github.com/user-attachments/assets/efd309fc-7ac4-4990-a39c-4b44d460bb22)

Then run the Install.bat which is in the LinuxMint folder

![image](https://github.com/user-attachments/assets/0d5865f4-faf6-4a66-897d-eaf4c4c4b1e1)

### Ready, New topic.

# 🥶 I don't like Linux Mint, can I use another one?
Yeah. For that you will have to download your ideal Linux and run it in VirtualBox setting LinuxMint.vtoy as Storage Disk.

## 🛂 Steps to Follow;
### Downloads Required;
Download [VirtualBox↗️](https://www.virtualbox.org/wiki/Downloads) and install it. Download the ISO of your Distro.

## 💽 Adjust VirtualBox;
Enter New machine

![image](https://github.com/user-attachments/assets/8cfe0337-2f92-4e9a-9059-a70f0e3929ba)

Adjust the Name and ISO File of your Linux that will be used Skipping Unattended Installation and Next.

![image](https://github.com/user-attachments/assets/9444832a-22e0-4ca8-b8c7-59123e7edf86)

Set "Enable EFI"

![image](https://github.com/user-attachments/assets/e01e764c-4e5f-4add-ada7-e54861325a8e)

Select LinuxMint.vtoy as Storage Disk

![image](https://github.com/user-attachments/assets/8db49d24-f9df-4a5d-8d49-c3eef4a07502)
![image](https://github.com/user-attachments/assets/f89af4ec-c031-4132-9030-50a084c4b988)

Terminate and Start the System

![image](https://github.com/user-attachments/assets/bf4f98b0-5aa1-4895-be64-6057e17febfe)

Install your Distro as usual...


Once installed you must Download [ThisFile↗️](https://github.com/ventoy/vtoyboot/releases) on your Virtual Linux, unzip it and run `vtoyboot.sh`

After this you can Restart your real PC and use it at maximum performance.

# 🤨 What does the Script do?
Download a ZIP containing;
[rEFIndx64](https://www.rodsbooks.com/refind/), [vdiskchain](https://github.com/ventoy/vdiskchain) and a 35GB VDI.

Unzip the ZIP in the C:/ nightclub

Copy rEFInd folder to EFI/EFI

Set the bootloader to rEFIndx64.efi

In the VDI it was done;
*OEM Linux installation

Installation Changes;
* Running [vtoyBoot](https://github.com/ventoy/vtoyboot)
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Timeout 3 and mitigations=off.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); added relatime, nodiratime, noatime.

You can reset these details in their Respective Files.
