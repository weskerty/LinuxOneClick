# Selecione 🌎 Idioma 🇧🇷 Idioma
[![en](https://img.shields.io/badge/English-en-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es-419.md)

# 🐧 Linux em um clique
Instale Linux do Windows facilmente
Sem riscos, mantendo o Windows com todos os seus arquivos.
>[!NOTA]
> Somente para Windows de 64 bits instalado em UEFI

# Basta baixar [ThisFile⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/InstallLinux.bat?viasf=1)
Em seguida, execute-o como Administrador.
O script irá baixar o Linux Mint e instalá-lo.

Se o método anterior não funcionar, [TryThis⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/LinuxInstall.ps1?viasf=1)

# Vídeo de demonstração:
https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0

O vídeo está acelerado, isso vai demorar muito mais...

Se isso não funcionar para você, você pode instalá-lo manualmente.
Baixe [elArchivoPrincipal↗️](https://sourceforge.net/projects/linuxoneclick/files/LOClicK.zip/download) com um gerenciador de download como JDownloader, descompacte-o manualmente em C:/ e execute o Installer.bat conforme mostrado em [ Este vídeo↗️](https://www.youtube.com/watch?v=Y1K3TLja434).


# 💢Correções de bugs;

## Erro do instalador;
[Use a alternativa do PowerShell⬇️](https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/LinuxInstall.ps1?viasf=1)

[Use a alternativa do PowerShell nº 2 ⬇️](https://sitsa.dl.sourceforge.net/project/linuxoneclick/LinuxInstallAlternativa.ps1?viasf=1) Isso é mais lento, pode levar até 2 horas para fazer o download.

## Erro de política de execução do PowerShell;
![imagem](https://github.com/user-attachments/assets/1920e51d-2600-4341-9934-805f7050e9e7)

Se aparecer, basta pressionar a tecla `O` e depois `ENTER` e o Script será executado. (a chave de confirmação varia de acordo com o idioma.)


##2
![imagem](https://github.com/user-attachments/assets/60d9ea10-d944-4bed-90f3-bdf435bec5fa)

Você terá que abrir o PowerShell manualmente e executar este comando, onde o que vem depois de `-File` é a localização do arquivo do instalador (InstallLinuxMint.ps1)
```
powershell -ExecutionPolicy Bypass -Arquivo F:\Downloads\LinuxMint\InstallLinuxMint.ps1
```

# 🌌 Alterar tema rEFInd;
 Baixe um [CatalogTheme↗️](https://refind-themes-collection.netlify.app/)

E mova-o para a pasta `C:\LinuxMint\refind\themes`

![imagem](https://github.com/user-attachments/assets/86d591ac-8071-406a-9069-8d2d8d8fc327)

Abra `refind.confg` com um editor de texto e modifique a última linha com o nome da pasta do seu novo tema.

![imagem](https://github.com/user-attachments/assets/efd309fc-7ac4-4990-a39c-4b44d460bb22)

Em seguida execute o Install.bat que está na pasta LinuxMint

![imagem](https://github.com/user-attachments/assets/0d5865f4-faf6-4a66-897d-eaf4c4c4b1e1)

### Pronto, novo tópico.

# 🥶 Não gosto de Linux Mint, posso usar outro?
Sim. Para isso você terá que baixar seu Linux ideal e executá-lo no VirtualBox configurando LinuxMint.vtoy como Disco de Armazenamento.

## 🛂 Passos a Seguir;
### Downloads necessários;
Baixe [VirtualBox↗️](https://www.virtualbox.org/wiki/Downloads) e instale-o. Baixe o ISO da sua distro.

## 💽Ajuste o VirtualBox;
Insira a nova máquina

![imagem](https://github.com/user-attachments/assets/8cfe0337-2f92-4e9a-9059-a70f0e3929ba)

Ajuste o nome e o arquivo ISO do seu Linux que será usado Ignorando a instalação autônoma e a seguir.

![imagem](https://github.com/user-attachments/assets/9444832a-22e0-4ca8-b8c7-59123e7edf86)

Defina "Ativar EFI"

![imagem](https://github.com/user-attachments/assets/e01e764c-4e5f-4add-ada7-e54861325a8e)

Selecione LinuxMint.vtoy como disco de armazenamento

![imagem](https://github.com/user-attachments/assets/8db49d24-f9df-4a5d-8d49-c3eef4a07502)
![imagem](https://github.com/user-attachments/assets/f89af4ec-c031-4132-9030-50a084c4b988)

Encerre e inicie o sistema

![imagem](https://github.com/user-attachments/assets/bf4f98b0-5aa1-4895-be64-6057e17febfe)

Instale sua Distro normalmente...


Uma vez instalado você deve baixar [ThisFile↗️](https://github.com/ventoy/vtoyboot/releases) em seu Virtual Linux, descompacte-o e execute `vtoyboot.sh`

Depois disso, você pode reiniciar seu PC real e usá-lo com desempenho máximo.

# 🤨 O que o Script faz?
Baixe um ZIP contendo;
[rEFIndx64](https://www.rodsbooks.com/refind/), [vdiskchain](https://github.com/ventoy/vdiskchain) e um VDI de 35 GB.

Descompacte o ZIP na unidade C:/

Copie a pasta rEFInd para EFI/EFI

Defina o Bootloader como rEFIndx64.efi

No VDI isso foi feito;
* Instalação OEM Linux

Alterações na Instalação;
* Executando [vtoyBoot](https://github.com/ventoy/vtoyboot)
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Tempo limite 3 e mitigações = desativado.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); adicionado relatime, nodiratime, noatime.

Você pode ajustar esses detalhes em seus respectivos arquivos.
