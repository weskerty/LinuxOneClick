# 🌎 Selecione o idioma;
[![en](https://img.shields.io/badge/English-en-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es-419.md)

# 🐧 Linux em um clique
Instale Linux do Windows facilmente
Sem riscos, mantendo o Windows com todos os seus arquivos.

# 💾 Basta baixar e instalar [este arquivo ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1)

>[!NOTA]
> 🔓 SecureBoot desativado obrigatório. Se estiver habilitado, o programa será instalado, mas ao reiniciar o Windows iniciará normalmente.
# [🔓 Guia sobre como desativar o SecureBoot ↗️](Guides/SecureBoot.md)

# Vídeo de demonstração:
https://github.com/user-attachments/assets/f729b276-0923-41c1-9bd5-7d44e5524a82
>[!NOTA]
> O vídeo é acelerado, isso levará algum tempo dependendo do seu PC.<br>
> Ao abrir o Exe, a janela do explorer irá travar até terminar a cópia se você tiver o Controle de Conta de Usuário ativado. Paciência.

# 🤨 O que isso faz no meu PC?
O Executável descompacta tudo isso em C:/MiLinux/ <br>
Se UEFI for detectado, instale [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
No caso de detecção de BIOS, instale [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Adicionados módulos como [vdiskchain e ipxe](https://github.com/ventoy/vdiskchain) que são necessários para inicialização VDI <br>
Um VDI de 25 GB é adicionado a C:/MiLinux/MiLinux.vtoy. Este é o disco Linux. <br>
Defina rEFInd ou Grub2 como gerenciador de inicialização. <br>

# 🐧MeuLinux
No VDI isso foi feito;
* Instalação OEM do Linux Mint

Alterações na Instalação;
* Executando [vtoyBoot](https://github.com/ventoy/vtoyboot)
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Tempo limite 1s e mitigações = desativado.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); adicionado relatime, nodiratime, noatime.
Você pode ajustar esses detalhes em seus respectivos arquivos.
Se as mitigações incomodam você, basta excluí-lo. sudo nano /etc/default/grub e exclua mitigations=off, salve-o e atualize o grub com sudo update-grub

# [🌄Instalação do tema inicial ↗️](Guides/Themes.md)

#💢Insetos? [Relate aqui ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

# 🗑️Desinstalação;
Basta ir para C:/MyLinux/uninstall.exe para desinstalá-lo.

# 🖥️ Isso funciona; <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] Windows XP SP3 32 e 64Bits (oficial) - VirtualBox
- [x] Windows Vista 32 e 64 bits - VirtualBox
- [x] Windows7 SP1 32 e 64 bits - VirtualBox
- [x] Windows10 22H2 32 e 64 bits - GigabyteA320M
- [?] Windows11 23H3 64 bits

>[!NOTA]
> Embora instalado no Windows de 32 bits, o processador deve ser compatível com 64 bits para iniciar o LinuxMint. <br>
> O Script usa Partição C:/. Se não estiver disponível, falhará. <br>

> [!AVISO]
> A instalação danificará o Boot do WindowsXP se não for WXP Oficial. <br>
> Caso o sistema não reinicie, pressione o [botão BootMenu ↗️](Guides/BootMenu.md) assim que o PC iniciar. Em seguida, escolha WindowsBootLoader<br>
> Alternativamente, você pode usar um [Disco de Reparo ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86- 20240711-english-version.html) para iniciar o Windows ou recuperar seus arquivos. <br>
# [💽 Guia sobre como instalar o LinuxMint diretamente ↗️](Guides/LinuxInstall.md)

# 💗 Usado [Mod NSIS](https://sourceforge.net/projects/nsisbi/files/nsisbi3.04.1/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain] ( https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/ )

# 📝 Todos são livres para editar esta mistura de scripts

Vídeo antigo em modo Script.
https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0
Ficou lindo, infelizmente não funcionou com W7 e inferiores, nem mesmo com curl devido a erros de certificado.
