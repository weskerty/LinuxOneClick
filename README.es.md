## 🌎 Selecciona Idioma; 
[![en](https://img.shields.io/badge/English-red.svg)](README.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](README.pt-br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](README.es.md)

## 🐧 Linux a un Clic
Instalar Linux desde Windows Facilmente
Sin Riesgos, Manteniendo Windows con Todos tus Archivos.
## 💾 Simplemente Descarga e Instala [Este Archivo ⬇️](https://master.dl.sourceforge.net/project/linuxoneclick/MiLinux.exe?viasf=1) 
Relajate Hasta que Termine el Proceso. Puedes hacer otras cosas Mientras se instala, como Navegar por Internet.

## 📹 Video Demostrativo: 
https://github.com/user-attachments/assets/f729b276-0923-41c1-9bd5-7d44e5524a82
>[!NOTE]
> ⏩ El video esta acelerado, esto tardara dependiendo de tu PC.<br>
> 💽 Se Requiere 35GB de Espacio Libre. <br>
> 🔓 Se Requiere SecureBoot Deshabilitado. En caso de tenerlo habilitado el programa se instalara pero al Reiniciar Iniciara Windows Normalmente.
## 🔓 ¿Como Deshabilitar SecureBoot?
<details>
<summary>Pasos a Seguir; ⬇️</summary>
<h2> 🔏 ¿Que es SecureBoot? </h2>
SecureBoot es un Sistema de Seguridad la cual evita que programas no certificados puedan arrancar con el Sistema. <br>
Lamentablemente este Script Requiere tener SecureBoot Desactivado ya que no esta firmado por Microsoft

### 👨‍💻 Desactivar SecureBoot desde BIOS;
Para Desactivar SecureBoot con este metodo Deberas Reiniciar la PC, y cuando enciende Deberas Pulsar la Tecla `Setup` que aparece en Pantalla. Suele ser `F2` `F12` o `DEL` <br>
Luego Buscar a traves de las flechas del teclado la Seccion `Sistema\System`, `Inicio\Boot`, `Seguridad` y en un Sub Menu debe aparecer SecureBoot, ajustarlo a apagado, guardar y reiniciar. <br>
Esto varia por PC, Aqui hay algunos Ejemplos; <br>
[![Dell](https://img.shields.io/badge/dell-007DB8?style=for-the-badge&logo=dell&logoColor=white)](https://www.dell.com/support/contents/es-mx/videos/videoplayer/how-to-enable-secure-boot/6333794882112?lwp=rt) [![Asus](https://img.shields.io/badge/Asus-black?style=for-the-badge&logo=asus&logoColor=white)](https://www.youtube.com/watch?v=8nxl-ZzjapA)   [![Acer](https://img.shields.io/badge/acer-83B81A?style=for-the-badge&logo=acer&logoColor=white)](https://www.youtube.com/watch?v=fziNzTmiwPE)   [![HP](https://img.shields.io/badge/hp-0096D6?style=for-the-badge&logo=hp&logoColor=white)](https://www.youtube.com/watch?v=mh5mDCw5L4M)   [![Lenovo](https://img.shields.io/badge/lenovo-E2231A?style=for-the-badge&logo=lenovo&logoColor=white)](https://support.lenovo.com/cl/es/videos/nvid500424-disable-and-enable-secure-boot-in-bios-lenovo-support-quick-tips) [![Samsung](	https://img.shields.io/badge/samsung-1428A0?style=for-the-badge&logo=Samsung&logoColor=white)](https://www.youtube.com/watch?v=4GPmc8QVCQE) [![MSI](https://img.shields.io/badge/MSI-FF0000?style=for-the-badge&logo=msi&logoColor=white)](https://www.youtube.com/watch?v=EypQEavuO_8) [![]()]() [![]()]() 
<details>
<summary>Lenovo ThinkPad</summary> 
Aqui 2 Ejemplos; <br>
Versiones Antiguas;
https://youtu.be/_MeUEWgv8i4?t=146 <br>
Versiones Nuevas <br>
<video src="https://github.com/user-attachments/assets/1517bb59-abd1-43a2-9a51-0ef32ccd21db"/>

</details>
<details>
<summary>HP</summary>
Deberas Reiniciar tu PC y cuando encienda la pantalla pulsar Rapidamente la tecla `ESC` y aparecera este menu <br>
<img src="https://github.com/user-attachments/assets/61ba5f8b-7b1d-4323-94c2-36a757129b33"> <br>
Luego Tendras que Elegir `F10` <br>
Se Abrira un menu gris. Con las Flechitas del teclado Deberas ir a la Seccion "Seguridad del Sistema" y seleccionar "Opciones de Inicio" <br>
<img src="https://github.com/user-attachments/assets/52cbe76b-4613-430e-840c-bf8828a8ebc8"> <br>
Luego `Enter` en SecureBoot y Ajustarlo a Desactivado. <br>
<img src="https://github.com/user-attachments/assets/dc00844f-1067-47c1-afed-32c128222120"> <br>
Ahora Pulsa `F10` o ir hasta la Seccion Guardar y Reiniciar. Reinicia y Todo Listo.
</details>

<details>
<summary>Gigabyte</summary>
Deberas Reiniciar y cuando esta enciende pulsar la tecla `DEL` para mostrar el menu. Luego ir a la Seccion Sistema o BIOS y Seleccionar SecureBoot <br>
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894" width="350" height="240" /> <br>
Luego seleccionar SecureBoot, enter y Disable/OFF. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659" width="350" height="240" /> <br>
Ahora ir a Guardar y Reiniciar.


</details>
</details>

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
[![Discord](https://img.shields.io/badge/DiscordOfficial-87cf3e?style=fat&logo=discord&logoColor=white)](https://discord.gg/mint)
[![Discord2](https://img.shields.io/badge/Discord2-7289DA?style=fat&logo=discord&logoColor=white)](https://discord.gg/linux-for-all-304606245132697600)
[![Reddit](https://img.shields.io/badge/Reddit-FF5722?style=fat&logo=reddit&logoColor=white)](https://www.reddit.com/r/linuxmint/)

## 💢 ¿Errores? [Informalo Aqui ↗️](https://github.com/weskerty/LinuxOneClick/issues/new)

## 🗑️ Desinstalacion;
<details>
<summary>Pasos a Seguir; ⬇️</summary>
Simplemente vaya a C:/MiLinux/uninstall.exe para Desinstalarlo como se ve en este Video; <br>
<video src="https://github.com/user-attachments/assets/fd6e3b13-3232-413f-881e-e8c56e44b71d"/> <br>

Asi de Facil.
</details>

## 💿 Aumentar Tamaño de Almacenamiento Linux VHD;
<details>
<summary>Pasos a Seguir; ⬇️</summary>
Ir al archivo llamado "AddStorage.bat" que se encuentra en C:/MiLinux/ y Ejecutarlo como Administrador. <br>
Luego escribir la Cantidad que te Gustaria en GB. Debe ser el Tamaño Total. Actualmente es 25GB, si quieres 5GB mas entonces Escribes 30. Agregara 5GB mas para que tenga 30GB. <br>
Una vez completado el Proceso, Reinicia a Linux y abre el Programa Discos, Clic derecho sobre el Disco EXT4 y Reajustar Tamaño. Luego mueve la barra para abarcar la Totalidad de la memoria. Aceptar y Listo. <br>
Video Demostrativo;
<video src="https://github.com/user-attachments/assets/09c339b1-b39a-4bf6-be96-2147463ed04b"/> <br>
</details>

# [💟 Mas Informacion Sobre Linux Mint ↗️](https://linuxmint.com.es/)

## 🐧 MiLinux 
En el VHD se Realizo;
* Instalacion OEM de Linux Mint
* Ejecucion de [vtoyBoot](https://github.com/ventoy/vtoyboot) <br>
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Agregado; VTOY_LINUX_REMOUNT=1  mitigations=off. <br>
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); Agregado; relatime, nodiratime, noatime. <br>
Puedes Reajustar estos detalles en sus Respectivos Archivos. <br>
En caso de molestarte mitigations solo borralo. sudo nano /etc/default/grub y borra mitigations=off, guardalo y luego actualiza grub con sudo update-grub

## 🖥️ Esto funciona en;  <img src="https://github.com/user-attachments/assets/8ff47ebe-780f-4d4b-894f-779c0887d844" alt="WorkOnMiPCGG" width="100" height="60"/>

- [x] WindowsXP 32 y 64Bits (Oficial)
- [x] WindowsVista 32 y 64Bits 
- [x] Windows7 32 y 64Bits 
- [x] Windows10 32 y 64Bits 
- [x] Windows11 23H3 64 Bits 

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
</details>

## [🐧 Instala Linux Directamente ↗️](https://youtu.be/2mUI3CMjmMc?t=27) 

## 💗 Se Uso [NSISMod](https://sourceforge.net/projects/nsisbi/files/nsisbi3.04.1/), [7Zip](https://7zip-es.updatestar.com/), [VDiskChain](https://github.com/ventoy/vdiskchain), [Grub2Win](https://sourceforge.net/projects/grub2win/files/), [rEFInd](https://www.rodsbooks.com/refind/), [![GHBadges](https://img.shields.io/badge/Badges-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/alexandresanlim/Badges4-README.md-Profile/blob/master/README.md)

## 📝 Todos Son Libres de Editar este Mejunje de Scripts 
