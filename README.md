### LinuxOneClick Installer

Instala Linux Mint desde Windows y deja **Secure Boot activado**.
No usa rEFInd, Grub2Win ni vdiskchain como el [viejo instalador](https://github.com/weskerty/LinuxOneClick/tree/OLD-EFI%2BGRUB-NoEFI) solo UEFI.

# [Descargar Aqui ⬇️](https://github.com/weskerty/LinuxOneClick/releases/download/Test/LinuxOneClick-Mint.exe)


### Qué hace el instalador

1. **Chequeos, sin modificar nada**: UEFI, Secure Boot y si la `db` confía en la CA que firmó el shim,
   BitLocker, que la imagen tenga etiqueta, que `EFI\ubuntu` no exista en la ESP, espacio.
2. Achica la unidad elegida y crea la partición Linux justo detrás (offset explícito).
3. Copia la partición en streaming, verifica el superbloque y borra el último MiB para no dejar firmas viejas.
4. Copia `EFI\ubuntu` a la ESP del sistema, escribe un `grub.cfg` que busca la raíz **por etiqueta**
   y deja el marcador `linuxoneclick.txt` (con `por_defecto=linux|windows`).
5. `bcdedit /copy {bootmgr}` crea una entrada de firmware real y apunta su `path` al shim.
   Usa `bootsequence` para el próximo arranque y `displayorder` para el orden del BIOS.
6. Agrega un acceso directo "Reiniciar en …" (bootsequence + reinicio) y lo registra en Aplicaciones.

Si algo falla después del paso 2, deshace todo automáticamente.
El estado queda en `HKLM\SOFTWARE\LinuxOneClick\EFI` (GUID de la partición, tipo y UUID del sistema de archivos).

### Arranque predeterminado y BitLocker

Con Windows primero, a Linux se entra con el acceso directo del escritorio o el menú de arranque del BIOS.


**Para darle más espacio a Linux**: volver a ejecutar el `.exe` → opción 3 (achica la unidad que está justo
antes de Linux), o achicar C: a mano desde Administración de discos, y reiniciar en Linux.

### Si ya está instalado

1. **Reinstalar**: descarga y verifica el paquete, y recién después borra la instalación actual (entrada de
   arranque, `EFI\<dir>`, todas las particiones del btrfs) y escribe la imagen en **una sola partición** que ocupa
   el mismo lugar, más el espacio sin asignar pegado antes. No achica C:. Si las particiones de Linux no
   están juntas o el lugar no alcanza para la versión nueva, no toca nada y lo avisa.
2. **Desinstalar**: lo mismo que desde Configuración > Aplicaciones (ver abajo).
3. **Darle más espacio a Linux** (solo btrfs): achica la unidad NTFS que está justo antes de Linux, dejando
   `-MargenLibreGB` libres. El espacio queda sin asignar pegado a Linux y el servicio lo suma en el próximo arranque.
   Achicar Linux para devolverle espacio a Windows no está: hay que reinstalar o desinstalar.

### Desinstalar

Borra la entrada de arranque, `EFI\ubuntu` (solo si tiene el marcador), **TODAS** las particiones del btrfs y devuelve el espacio a la unidad
NTFS que está justo antes de Linux (normalmente C:), incluido el espacio sin asignar que haya en el medio.
Si antes de Linux no hay una unidad de Windows, el espacio queda sin asignar. Lo avisa antes de confirmar.

### Rendimiento y seguridad

La imagen trae `mitigations=off` (desactiva las protecciones contra Spectre/Meltdown y similares: hasta ~50 %
más rendimiento en CPUs viejas, a cambio de menos aislamiento entre procesos) y `pcie_aspm=off`. Se cambian en `/etc/default/grub` + `sudo update-grub`.

### Preparar Tu Version 

Instalación: VM con **EFI**, disco **VHD fijo**, podria funcionar con cualquier distrubucion. Si no te importa SecureBoot tambien funciona directo con ArchLinux.


### BTRFS
Existe un driver para Windows, podria vincularse carpeta de USER<>LinuxHome. Pero hoy no se hace, peudes hacerlo manualmente instalando el driver [desde Aqui](https://github.com/maharmstone/btrfs). Tambien se podria hacer un instalador directo a btrfs sin VHD, pero esto es solo una idea.

Esta Revision esta hecha por IA, corrigio la aberracion que era [mi viejo script](https://github.com/weskerty/LinuxOneClick/tree/OLD-EFI%2BGRUB-NoEFI). Aunque lo probe y funciona, antes de usarlo deberias aprender a como entrar en la BIOS para corregir la entrada y saber tu clave BitLocker.
