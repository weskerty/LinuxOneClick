# 🌎 Selecciona Idioma; 
[![en](https://img.shields.io/badge/English-en-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es-419.md)

# 🐧 Linux a un Clic
Instalar Linux desde Windows Facilmente
Sin Riesgos, Manteniendo Windows con Todos tus Archivos.

# 💾 Simplemente Descarga e Instala [Este Archivo ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1)  

>[!NOTE]
> 🔓 Se Requiere SecureBoot Deshabilitado. En caso de tenerlo habilitado el programa se instalara pero al Reiniciar Iniciara Windows Normalmente.
# [🔓 Guia de como Deshabilitar SecureBoot ↗️](Guias/SecureBoot.md)

# Video Demostrativo: 

El video esta acelerado, esto tardara dependiendo de tu PC.

# 🤨 ¿Que le hace esto a mi PC?
El Executable descomprime Todo esto en C:/MiLinux/ <br>
En caso de Detectarse UEFI Instala [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
En caso de Detectase BIOS Instala [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Se agrega modulos como [vdiskchain y ipxe](https://github.com/ventoy/vdiskchain) que son Necesarios para el Arranque VDI <br>
Se agrega un VDI de 25GB en C:/MiLinux/MiLinux.vtoy. Este es el Disco Linux. <br>
Se establece rEFInd o Grub2 como Gestor de Arranque. <br>

# 🐧 MiLinux 
En la VDI se Realizo;
* Instalacion OEM de Linux Mint
  
Cambios en la Instalacion;
* Ejecucion de [vtoyBoot](https://github.com/ventoy/vtoyboot)
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Tiempo de espera 1s y mitigations=off.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); agregado relatime, nodiratime, noatime.
Puedes Reajustar estos detalles en sus Respectivos Archivos.
En caso de molestarte mitigations solo borralo. sudo nano /etc/default/grub y borra mitigations=off, guardalo y luego actualiza grub con sudo update-grub

# [🌄Instalacion de Temas de Inicio ↗️](Guias/Temas.md)

# 💢 ¿Errores? [Informalo Aqui ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

# 🗑️ Desinstalacion;
Simplemente vaya a C:/MiLinux/uninstall.exe para Desinstalarlo.

# 🖥️ Esto funciona en;  <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] Windows XP SP3 32 y 64Bits (Oficial) - VirtualBox
- [x] Windows Vista 32 y 64Bits - VirtualBox
- [x] Windows7 SP1 32 y 64Bits - VirtualBox
- [x] Windows10 22H2 32 y 64Bits - GigabyteA320M
- [?] Windows11 23H3 64 Bits 

>[!NOTE]
> Aunque se instala en Windows de 32Bits, el Procesador debe ser Compatible con 64Bits para Iniciar LinuxMint. <br>
> El Script usa la Particion C:/. Si esta no esta Disponible Fallara. <br>

> [!WARNING]
> La instalacion Dañara el Boot de WindowsXP en caso de que no sea WXP Oficial.
> En Caso de que el Sistema no vuelva a iniciar, Pulse el [Boton BootMenu ↗️](Guias/BootMenu.md) al Instante que Inicia su PC. Luego Elija WindowsBootLoader<br>
> Alternativamente Puede usar un [Disco de Reparacion ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86-20240711-english-version.html) para Iniciar Windows o Recuperar tus Archivos.
# [💽 Guia de Como Instalar LinuxMint Directamente ↗️](Guias/LinuxInstall.md)

# 💗 Se Uso [NSIS](https://nsis.sourceforge.io/Main_Page), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain](https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/)

# 📝 Todos Son Libres de Editar este Mejunje de Scripts 

