## 🌎 Selecciona Idioma; 
[![en](https://img.shields.io/badge/English-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es.md)

## 🐧 Linux a un Clic
Instalar Linux desde Windows Facilmente
Sin Riesgos, Manteniendo Windows con Todos tus Archivos.
## 💾 Simplemente Descarga e Instala [Este Archivo ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinuxVDI.exe?viasf=1) 
Relajate Hasta que Termine el Proceso. Puedes hacer otras cosas Mientras se instala, como Navegar por Internet.

## 📹 Video Demostrativo: 
https://github.com/user-attachments/assets/f729b276-0923-41c1-9bd5-7d44e5524a82
>[!NOTE]
> El video esta acelerado, esto tardara dependiendo de tu PC.<br>
> Se Requiere 35GB de Espacio Libre. <br>
> Al abrir el Exe la ventana del explorador se quedara colgada hasta que termine de copiarse si tienes activado el Control Cuentas de Usuario. Paciencia. <br>
> 🔓 Se Requiere SecureBoot Deshabilitado. En caso de tenerlo habilitado el programa se instalara pero al Reiniciar Iniciara Windows Normalmente.
## [🔓 Guia de como Deshabilitar SecureBoot ↗️](Guides/SecureBoot/SecureBoot.md)

## 🤨 ¿Que le hace esto a mi PC?
El Executable descomprime Todo esto en C:/MiLinux/ <br>
En caso de Detectarse UEFI Instala [rEFIndx64](https://www.rodsbooks.com/refind/) <br>
En caso de Detectase BIOS Instala [Grub2Win](https://sourceforge.net/projects/grub2win/) <br>
Se agrega modulos como [vdiskchain y ipxe](https://github.com/ventoy/vdiskchain) que son Necesarios para el Arranque VDI <br>
Se agrega un VDI de 25GB en C:/MiLinux/MiLinux.vtoy. Este es el Disco Linux. <br>
Se establece rEFInd o Grub2 como Gestor de Arranque. <br>

## 🙋💖 Grupos de Ayuda Linux 🤗
#### Español;
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/LinuxGroups/) 	 
[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?logo=whatsapp&logoColor=fff&style=flat)](https://chat.whatsapp.com/BsBW4RbEVpj8KO22AN2KDB) 	 
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=fat&logo=telegram&logoColor=white)](https://t.me/addlist/pbpqO72i6x44MmQx)	
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/XYYvqUF3pG)
#### PortuguêsBR; 
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/brlinux/) 	 
#### English; 
[![Facebook](https://img.shields.io/badge/Facebook-blue?logo=facebook&logoColor=fff&style=flat)](https://www.facebook.com/groups/GNUAndLinux/) 	 
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.com/invite/D4ETYhq)

## 🌄Cambiar Imagen de Arranque;

<details>
<summary>Pasos a Seguir; ⬇️</summary>
<video src=""/> <br>
</details>

## 💢 ¿Errores? [Informalo Aqui ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

## 🗑️ Desinstalacion;
<details>
<summary>Pasos a Seguir; ⬇️</summary>
Simplemente vaya a C:/MiLinux/uninstall.exe para Desinstalarlo como se ve en este Video; <br>
<video src=""/> <br>
Asi de Facil.
</details>

## 💿 Aumentar Tamaño de Almacenamiento Linux VHD;
<details>
<summary>Pasos a Seguir; ⬇️</summary>
Ir al archivo llamado "AddStorage.bat" que se encuentra en C:/MiLinux/ y Ejecutarlo como Administrador. <br>
Luego escribir la Cantidad que te Gustaria en GB. Debe ser el Tamaño Total. Actualmente es 25GB, si quieres 5GB mas entonces Escribes 30. Agregara 5GB mas para que tenga 30GB. <br>
Una vez completado el Proceso, Reinicia a Linux y abre el Programa Discos, Clic derecho sobre el Disco EXT4 y Reajustar Tamaño. Luego mueve la barra para abarcar la Totalidad de la memoria. Aceptar y Listo. <br>
Video Demostrativo;
<video src=""/> <br>
</details>


## 🐧 MiLinux 
En el VHD se Realizo;
* Instalacion OEM de Linux Mint
* Ejecucion de [vtoyBoot](https://github.com/ventoy/vtoyboot) <br>
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Agregado; VTOY_LINUX_REMOUNT=1  mitigations=off. <br>
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); Agregado; relatime, nodiratime, noatime. <br>
Puedes Reajustar estos detalles en sus Respectivos Archivos. <br>
En caso de molestarte mitigations solo borralo. sudo nano /etc/default/grub y borra mitigations=off, guardalo y luego actualiza grub con sudo update-grub

## 🖥️ Esto funciona en;  <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] WindowsXP 32 y 64Bits (Oficial) - VirtualBox
- [x] WindowsVista 32 y 64Bits - VirtualBox
- [x] Windows7 32 y 64Bits - VirtualBox
- [x] Windows10 32 y 64Bits - GigabyteA320M
- [x] Windows11 23H3 64 Bits - VirtualBox

>[!NOTE]
> Aunque se instala en Windows de 32Bits, el Procesador debe ser Compatible con 64Bits para Iniciar LinuxMint. <br>
> El Script usa la Particion C:/. Si esta no esta Disponible no sucedera nada. <br>

> [!WARNING]
> La instalacion Dañara el Boot de WindowsXP en caso de que no sea WXP Oficial. <br>
> En Caso de que Windows no vuelva a iniciar, Pulse el [Boton BootMenu ↗️](Guides/BootMenu/BootMenu.md) al Instante que Inicia su PC. Luego Elija WindowsBootLoader<br>
> Alternativamente Puede usar un [Disco de Reparacion ↗️](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/237-winpe-11-10-8-sergei-strelec-x86x64native-x86-20240711-english-version.html) para Iniciar Windows. <br>

## 😐 ¿No Te Gusta Linux Mint? Instala otra Distribucion;
<details>
<summary>Pasos a Seguir; ⬇️</summary>
Puedes cambiar la Instalacion del VHD con VirtualBox y Seguir la Instalacion Correspondiente desde Ahi. <br>
Descarga e Instala VirtualBox en Windows https://www.virtualbox.org/wiki/Downloads <br>
Abre VirtualBox, Clic en Nueva Maquina, Ajusta el Nombre y la Ubicacion de la ISO (medio de instalacion). Luego Ajusta los Recursos que usara VirtualBox. DEBES MARCAR HABILITAR EFI. Luego Seleccionas "Usar Disco Existente" y Seleccionas el Icono de Carpeta para Buscar la Ubicacion de MiLinux.vhd.vtoy, lo seleccionas y Siguiente. Inicia la Maquina Virtual y Instala tu Distro como de Costumbre.
Aqui un Ejemplo en Video; 
<video src=""/> <br>
</details>


## [💽 Guia de Como Instalar LinuxMint Directamente ↗️](Guides/LinuxInstall/LinuxInstall.md)

## 💗 Se Uso [NSISMod](https://sourceforge.net/projects/nsisbi/files/nsisbi3.04.1/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain](https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/), [![GHBadges](https://img.shields.io/badge/Badges-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/alexandresanlim/Badges4-README.md-Profile/blob/master/README.md)

## 📝 Todos Son Libres de Editar este Mejunje de Scripts 

<details>
<summary>Antiguo</summary>
Esto era hermoso, hasta podias elegir que Distro Instalar. Pero lamentablemente no funcionaba con W7 e inferiores, nisiquiera con curl por errores de certificado.

<video src="https://github.com/user-attachments/assets/a98d0f3e-bd70-4b2a-86cc-33724ea62dc0">

</details>
