# 🐧 Linux a un Clic
Instalar Linux desde Windows Facilmente
Sin Riesgos y sin Perder Archivos
Simplemente Descarga EsteArchivo↗️ y luego ejecutalo como Administrador.
El script descargara Linux Mint y lo instalara, Tardara dependiendo de tu Velocidad a Internet y demas.
>[!NOTE]
> Solo para Windows de 64Bits instalados en UEFI

# Video Demostrativo: 

# 🌌 Cambiar tema de rEFInd;
Ve a la carpeta LinuxMint ubicada en C:/
Descarga un TemaDelCatalogo↗️ y muevelo a la carpeta refind/themes/

Abre 'refind.confg' con un editor de texto y modifica la ultima linea con el nombre de tu nuevo tema.

luego ejecuta el Instalar.bat que esta en la carpeta LinuxMintby Listo, Nuevo tema.

# 🥶 No me gusta Linux Mint, Puedo usar Otro?
Si. Para eso tendras que descargar tu Linux ideal y ejecutarlo en VirtualBox ajustando LinuxMint.vtoy como Disco de Almacenamiento.

## 🛂 Pasos a Seguir;
### Descargas Necesarias;
Descargar VirtualBox↗️ e Instalarlo 
Descargar otra Distro↗️ (la que gustes)

## 💽 Ajustar VirtualBox;
Entrar en Nueva maquina 

Ajustar el Nombre y el Archivo ISO de tu Linux que sera usado Omitiendo la Instalacion Desatendida y Siguiente.

Ajusta "Activar EFI" 

Selecciona LinuxMint.vtoy como Disco de Almacenamiento

Termina e Inicia el Sistema 

Instala tu Distro como de Costumbre 

Una vez Instalado deberas Descargar EsteArchivo en tu Linux Virtual, descomprimirlo y ejecutar Vento...

Luego de esto ya puedes Reiniciar tu PC real y usarlo a maximo rendimiento.

# 🤨 ¿Que hace el Script?
* Descarga un ZIP que contiene; 
* rEFIndx64, vtoytool y un VDI 35GB.
* Descomprime el ZIP en el disco C:/
* Copia la carpeta rEFInd a EFI/EFI 
* Ajusta el Cargador de arranque a rEFIndx64.efi

En la VDI se Realizo;
* Instalacion OEM de LinuxMint
* Ejecucion de vtoyLinuxBoot
Cambios en;
* GRUB; Tiempo de espera 3 y mitigations=off.
* FSTAB; agregado relatime, nodiratime, noatime.


