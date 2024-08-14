## 🌎 Selecione o idioma;
[![en](https://img.shields.io/badge/English-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es.md)

## 🐧 Linux em um clique
Instale Linux do Windows facilmente
Sem riscos, mantendo o Windows com todos os seus arquivos.
## 💾 Basta baixar e instalar [este arquivo ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1)
Relaxe até que o processo termine. Você pode fazer outras coisas durante a instalação, como navegar na Internet.

## 📹 Vídeo Demonstrativo:
https://github.com/user-attachments/assets/f729b276-0923-41c1-9bd5-7d44e5524a82
>[!NOTE]
> O vídeo é acelerado, isso levará algum tempo dependendo do seu PC.<br>
> São necessários 35 GB de espaço livre. <br>
> Ao abrir o Exe, a janela do explorer irá travar até terminar a cópia se você tiver o Controle de Conta de Usuário ativado. Paciência. <br>
> 🔓 SecureBoot desativado obrigatório. Se estiver habilitado, o programa será instalado, mas ao reiniciar o Windows iniciará normalmente.
## [🔓 Guia sobre como desativar o SecureBoot ↗️](Guides/SecureBoot/SecureBoot.md)

## 🤨 O que isso faz no meu PC?
O Executável descompacta tudo isso em C:/MiLinux/ <br>
Se UEFI for detectado, instale [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
No caso de detecção de BIOS, instale [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Adicionados módulos como [vdiskchain e ipxe](https://github.com/ventoy/vdiskchain) que são necessários para inicialização VDI <br>
Um VDI de 25 GB é adicionado a C:/MiLinux/MiLinux.vtoy. Este é o disco Linux. <br>
Defina rEFInd ou Grub2 como gerenciador de inicialização. <br>

## 🙋💖 Grupos de Ajuda Linux 🤗
#### Espanhol;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/LinuxGroups/)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?logo=whatsapp&logoColor=fff&style=flat)](https://chat.whatsapp.com/BsBW4RbEVpj8KO22AN2KDB)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=fat&logo=telegram&logoColor=white)](https://t.me/addlist/pbpqO72i6x44MmQx)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/XYYvqUF3pG)
#### PortuguêsBR;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/brlinux/)
#### Inglês;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/GNUAndLinux/)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/D4ETYhq)

## [🌄Instalação de temas ↗️](Guides/Themes/Themes.md)

## 💢Error? [Relate aqui ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

## 🗑️ Desinstalação;
Basta ir para C:/MyLinux/uninstall.exe para desinstalá-lo.

## [💿 Aumentar o tamanho do armazenamento VDI do Linux ↗️](Guides/VDI/VDI.md)

## 🐧MeuLinux
No VDI isso foi feito;
* Instalação OEM do Linux Mint
* Executando [vtoyBoot](https://github.com/ventoy/vtoyboot) <br>
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Agregar; VTOY_LINUX_REMOUNT=1 mitigations=off. <br>
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); Agregar; relatime, nodiratime, noatime. <br>
Você pode ajustar esses detalhes em seus respectivos arquivos. <br>
Se as mitigações incomodam você, basta excluí-lo. sudo nano /etc/default/grub e exclua mitigations=off, salve-o e atualize o grub com sudo update-grub

## 🖥️ Isso funciona; <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] WindowsXP 32 e 64Bits (oficial) - VirtualBox
- [x] Windows Vista 32 e 64 bits - VirtualBox
- [x] Windows7 32 e 64 bits - VirtualBox
- [x] Windows10 32 e 64 bits - GigabyteA320M
- [x] Windows11 23H3 64 bits - VirtualBox

>[!NOTE]
> Embora instalado no Windows de 32 bits, o processador deve ser compatível com 64 bits para iniciar o LinuxMint. <br>
> O Script usa Partição C:/. Se não estiver disponível nada acontecerá. <br>

> [!WARNING]
> A instalação danificará o Boot do WindowsXP se não for WXP Oficial. <br>
> Caso o Windows não reinicie, pressione o [BootMenu ↗️](Guides/BootMenu/BootMenu.md) assim que o PC iniciar. Em seguida, escolha WindowsBootLoader<br>
> Alternativamente, você pode usar um [Disco de Reparo ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86-20240711-english-version.html) para iniciar o Windows. <br>

## [💽 Guia sobre como instalar o LinuxMint diretamente ↗️](Guides/LinuxInstall/LinuxInstall.md)

## 💗 Usado [NSISMod](https://sourceforge.net/projects/nsisbi/files/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain](https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files), [rEFInd](https://www.rodsbooks.com/refind/), [![GHBadges](https://img.shields.io/badge/Badges-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/alexandresanlim/Badges4-README.md-Profile/blob/master/README.md)

## 📝 Todos são livres para editar esta mistura de scripts

<details>
<summary>Antiguo</summary>
Ficou lindo, você pode até escolher qual Distro instalar. Mas infelizmente não funcionou com W7 e anteriores, nem mesmo com curl devido a erros de certificado.

<video src="https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0">

</details>

