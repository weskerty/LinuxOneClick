# 🐧 Linux a un Clic
Instalar Linux desde Windows Facilmente
Sin Riesgos y sin Perder Archivos
Simplemente Descarga [EsteArchivo↗️](InstalarLinuxMint.ps1) y luego ejecutalo como Administrador.
El script descargara Linux Mint y lo instalara.
>[!NOTE]
> Solo para Windows de 64Bits instalados en UEFI

# Video Demostrativo: 

https://github.com/user-attachments/assets/d706560e-978a-4205-85c5-bc424dc9f056

El video esta acelerado, esto tardara mucho mas. A mi me tardo 1H30M
En Caso de que no tengas paciencia y no quieras esperar Tanto... Puedes Descargar [elArchivoPrincipal↗️](https://sourceforge.net/projects/linuxoneclick/files/LOClicK.zip/download) con algun gestor de descarga como JDownloader, Descomprimirlo manualmente en C:/ y ejecutar el Instalador.bat como se Muestra en [EsteVideo↗️](https://www.youtube.com/watch?v=Y1K3TLja434).

# 🌌 Cambiar tema de rEFInd;
## Descarga un [TemaDelCatalogo↗️](https://refind-themes-collection.netlify.app/) 

## Ve a la carpeta LinuxMint ubicada en C:/ y muevelo a la carpeta refind/themes/

![image](https://github.com/user-attachments/assets/86d591ac-8071-406a-9069-8d2d8d8fc327)

## Abre 'refind.confg' con un editor de texto y modifica la ultima linea con el nombre de la carpeta de tu nuevo tema.

![image](https://github.com/user-attachments/assets/efd309fc-7ac4-4990-a39c-4b44d460bb22)


## luego ejecuta el Instalar.bat que esta en la carpeta LinuxMint

![image](https://github.com/user-attachments/assets/0d5865f4-faf6-4a66-897d-eaf4c4c4b1e1)

## Listo, Nuevo tema.

# 🥶 No me gusta Linux Mint, Puedo usar Otro?
Si. Para eso tendras que descargar tu Linux ideal y ejecutarlo en VirtualBox ajustando LinuxMint.vtoy como Disco de Almacenamiento.

## 🛂 Pasos a Seguir;
### Descargas Necesarias;
Descargar [VirtualBox↗️](https://www.virtualbox.org/wiki/Downloads) e Instalarlo 
Descargar otra Distro 

## 💽 Ajustar VirtualBox;
### Entrar en Nueva maquina 
![image](https://github.com/user-attachments/assets/8cfe0337-2f92-4e9a-9059-a70f0e3929ba)

### Ajustar el Nombre y el Archivo ISO de tu Linux que sera usado Omitiendo la Instalacion Desatendida y Siguiente.
![image](https://github.com/user-attachments/assets/9444832a-22e0-4ca8-b8c7-59123e7edf86)

### Ajusta "Activar EFI" 
![image](https://github.com/user-attachments/assets/e01e764c-4e5f-4add-ada7-e54861325a8e)

# Selecciona LinuxMint.vtoy como Disco de Almacenamiento
![image](https://github.com/user-attachments/assets/8db49d24-f9df-4a5d-8d49-c3eef4a07502)
![image](https://github.com/user-attachments/assets/f89af4ec-c031-4132-9030-50a084c4b988)

### Termina e Inicia el Sistema 
![image](https://github.com/user-attachments/assets/bf4f98b0-5aa1-4895-be64-6057e17febfe)

### Instala tu Distro como de Costumbre...


### Una vez Instalado deberas Descargar [EsteArchivo↗️](https://github.com/ventoy/vtoyboot/releases) en tu Linux Virtual, descomprimirlo y ejecutar ``vtoyboot.sh``

### Luego de esto ya puedes Reiniciar tu PC real y usarlo a maximo rendimiento.

# 🤨 ¿Que hace el Script?
Descarga un ZIP que contiene;
[rEFIndx64](https://www.rodsbooks.com/refind/), [vdiskchain](https://github.com/ventoy/vdiskchain) y un VDI 35GB.

Descomprime el ZIP en el disco C:/

Copia la carpeta rEFInd a EFI/EFI

Ajusta el Cargador de arranque a rEFIndx64.efi

En la VDI se Realizo;
* Instalacion OEM de LinuxMint
* Ejecucion de [vtoyBoot](https://github.com/ventoy/vtoyboot)
  
Cambios en;
* [GRUB](https://es.wikipedia.org/wiki/GNU_GRUB); Tiempo de espera 3 y mitigations=off.
* [FSTAB](https://es.wikipedia.org/wiki/Fstab); agregado relatime, nodiratime, noatime.


