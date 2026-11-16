# LinuxOneClick EFI

Instala Linux en una **partición real** desde Windows y deja **Secure Boot activado**.
No usa rEFInd, Grub2Win ni vdiskchain: solo UEFI con la cadena firmada `shim (Microsoft) → grub → kernel`.

## Archivos

| Archivo | Para qué |
|---|---|
| `LinuxOneClick-Mint.nsi` | Lanzador `.exe` (NSISBI). Trae el PS1 y 7za; descarga el paquete. |
| `Instalar-Linux.ps1` | Instalador y desinstalador (`-Desinstalar`). Se autoeleva. Mensajes en inglés y español. |
| `Crear-Paquete.ps1` | Arma el `.7z` a partir del VHD preparado en la VM. Corre en Windows. |
| `linux/linuxoneclick.sh` + `.service` | Van **dentro** de la imagen. Corren en cada arranque de Linux en la PC real. |

## Formato del paquete

```
Mint.7z  (no sólido: -ms=off)
├── paquete.json        {"nombre","imagen","efiDir","loader","prefijoGrub","minimoGB"}
├── EFI\ubuntu\         shimx64.efi, grubx64.efi, mmx64.efi, BOOTX64.CSV
└── Mint.vhd            VHD FIJO (o .img crudo) con GPT y una sola partición Linux (ext4 o btrfs)
```

El instalador **no descomprime la imagen a disco**: `7za e -so` alimenta un pipe y se copia
directo a la partición nueva. Solo se escribe la partición Linux; la ESP del VHD se ignora.
`prefijoGrub` lo detecta `Crear-Paquete.ps1` (`/boot/grub`, o `/@/boot/grub` con btrfs).

## Preparar la imagen (VM, Mint con btrfs)

Instalación: VM con **EFI**, disco **VHD fijo**, modo OEM, particionado manual: ESP 512 MB + btrfs en `/`
(el instalador crea los subvolúmenes `@` y `@home`). Sin partición swap.

1. `sudo apt full-upgrade` (shim y grub al día; Windows Update revoca shims viejos vía SBAT).
2. Etiqueta: `sudo btrfs filesystem label / MintRoot`
3. `/etc/fstab`:
   ```
   LABEL=MintRoot  /          btrfs  subvol=@,noatime,compress=zstd:1,commit=60      0  0
   LABEL=MintRoot  /home      btrfs  subvol=@home,noatime,compress=zstd:1,commit=60  0  0
   UUID=XXXX-XXXX  /boot/efi  vfat   umask=0077,nofail,x-systemd.device-timeout=5s   0  1
   ```
   La ESP queda con el UUID de la VM y `nofail`: en la PC real la corrige el servicio.
4. Swap con **zram** (un swapfile no funciona en un btrfs de varias particiones):
   `sudo apt install zram-tools`, en `/etc/default/zramswap` `ALGO=zstd` y `PERCENT=50`.
   Si hubo partición swap: borrarla y `echo RESUME=none | sudo tee /etc/initramfs-tools/conf.d/resume && sudo update-initramfs -u`
   (si no, el arranque espera ~30 s un dispositivo de hibernación que no existe).
5. GRUB: `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off pcie_aspm=off"` y `sudo update-grub`.
6. Comprimir lo ya instalado (montando el subvolumen raíz aparte para no recorrer `/proc`, etc.):
   ```sh
   sudo mount -o subvolid=5 LABEL=MintRoot /mnt
   sudo btrfs filesystem defragment -r -czstd /mnt/@ /mnt/@home
   sudo umount /mnt
   ```
7. Servicio:
   ```sh
   sudo install -m755 linuxoneclick.sh /usr/local/sbin/linuxoneclick
   sudo install -m644 linuxoneclick.service /etc/systemd/system/
   sudo systemctl enable linuxoneclick.service
   ```
   En la VM no hace nada: solo actúa si encuentra el marcador que deja el instalador en la ESP.
   Para probarlo igual: `sudo linuxoneclick --forzar --simular`.
8. Limpiar: `sudo apt-get clean`, `sudo rm -rf /var/lib/apt/lists/*`, logs viejos, y quitar lo temporal
   (`openssh-server` si se usó: `sudo apt purge openssh-server && sudo rm -f /etc/ssh/ssh_host_*`).
9. Llenar con ceros el espacio libre **sin compresión** (si no, btrfs comprime los ceros y no pisa nada):
   ```sh
   sudo mkdir /ceros && sudo chattr +C /ceros
   sudo dd if=/dev/zero of=/ceros/cero bs=4M status=progress   # hasta llenar (o dejar ~1 GB de margen con count=)
   sudo rm -rf /ceros
   ```
10. Último paso, ya sin volver a usar la VM: `oem-config-prepare` (ícono del escritorio) y apagar.
11. Desde Windows como admin:
    `.\Crear-Paquete.ps1 -Imagen C:\VMint\Mint\Mint.vhd -Salida ..\Paquete\Mint.7z -Nombre "Linux Mint 22.3" -Compresion 9 -SieteZip "C:\Program Files\7-Zip\7z.exe"`

### Sobre btrfs

- **CoW queda activado**: sin CoW se pierde la compresión (lo que más rinde en discos lentos) y los checksums.
  Si hiciera falta, desactivarlo **solo** en carpetas de discos de VM o bases de datos: `chattr +C carpeta`.
- **No activar quotas** (Timeshift ofrece "qgroups"): es lo que más frena a btrfs.

## Publicar

1. Subir `Mint.7z` a SourceForge por SFTP (`frs.sourceforge.net`, carpeta `/home/frs/project/linuxoneclick/`).
2. En `LinuxOneClick-Mint.nsi` poner `URL` y `SHA256` (los imprime `Crear-Paquete.ps1`).
   La URL directa es `https://downloads.sourceforge.net/project/linuxoneclick/Mint.7z`
   (a los navegadores SourceForge les muestra su página; a curl/BITS les da el archivo).
3. Compilar: `makensis LinuxOneClick-Mint.nsi` → `..\Paquete\LinuxOneClick-Mint.exe`.
   Prueba sin tocar el disco: `makensis -DPRUEBA LinuxOneClick-Mint.nsi`, poner el `-PRUEBA.exe` junto a
   `Mint.7z` y ejecutarlo: solo analiza el paquete y deja `prueba-lanzador.log`.

El `.exe` extrae el PS1 y `7za.exe` a una carpeta temporal y abre PowerShell (64 bits). Si hay un `Mint.7z`
junto al `.exe`, usa ese en lugar de descargar (igual verifica el SHA256).
Sin firma de código, SmartScreen muestra "Windows protegió su PC" → "Más información" → "Ejecutar de todas formas".

## Uso del PS1

```powershell
.\Instalar-Linux.ps1 -Paquete D:\Mint.7z -SoloAnalizar     # no toca nada
.\Instalar-Linux.ps1 -Paquete D:\Mint.7z                   # instala
.\Instalar-Linux.ps1 -Paquete https://.../Mint.7z -Sha256 <hash>
.\Instalar-Linux.ps1 -Desinstalar                          # o Configuración > Aplicaciones
```

Opciones: `-Arranque Auto|Linux|Windows`, `-TamanoGB 35`, `-MargenLibreGB 10`, `-SinConfirmar`, `-ConservarPaquete`, `-SieteZip <ruta>`.
Descarga con `curl.exe` de Windows (retoma si se corta), y si falla con BITS o `Invoke-WebRequest`.
Registro de cada ejecución: `%ProgramData%\LinuxOneClick\registro-*.log`.

## Qué hace el instalador, en orden

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

## Arranque predeterminado y BitLocker

Con BitLocker, **arrancar Windows desde GRUB** cambia la cadena de arranque que mide el TPM y Windows pide la
**clave de recuperación de 48 dígitos**. Muchas notebooks con Windows 11 traen el cifrado de dispositivo
activado de fábrica sin que el usuario lo sepa. Por eso:

- **`-Arranque Auto`** (lo que usa el `.exe`): **GRUB primero**, con menú de 5 s que ofrece Windows,
  **salvo que la unidad de Windows esté cifrada** (aunque sea "esperando activación"): entonces Windows primero.
- **`-Arranque Linux`** / **`-Arranque Windows`**: forzar uno u otro.

Con Windows primero, a Linux se entra con el acceso directo del escritorio o el menú de arranque del BIOS.

## Qué hace Linux en cada arranque (`linuxoneclick.service`)

Corre antes de la pantalla de inicio de sesión. Si no hay marcador en ninguna ESP, no hace nada.

1. **Una sola vez**: apunta `/boot/efi` a la ESP de Windows (UUID real), así las actualizaciones de shim/grub
   van a la ESP que de verdad arranca.
2. **Siempre, arranque**:
   - **modo linux**: GRUB primero en el firmware, menú con Windows (os-prober), `update_nvram=true`.
   - **modo windows**: Windows primero, `update_nvram=false` (GRUB no se pone primero al actualizarse).
   - **modo seguro**: si aparece una partición **BitLocker** (por ejemplo el usuario activó el cifrado después),
     Windows pasa a primero y **sale del menú de GRUB**, para que nadie lo arranque por ahí.
   - Si una actualización de Windows o del firmware cambió el orden, lo vuelve a acomodar.
   - Instala en el menú el lanzador **"Reiniciar en Windows"** (`efibootmgr -n`): el próximo arranque va directo
     a Windows desde el firmware, sin GRUB, así BitLocker no se queja.
   - Nota: si alguien activa BitLocker estando en modo linux (Windows arrancado desde GRUB), puede pedir la clave
     **una vez** al pasar a modo seguro; después ya no, porque Windows deja de arrancarse desde GRUB.
3. **Siempre, espacio**:
   - Si el btrfs ocupa menos que su partición (primer arranque: imagen de ~25 GB en una partición más grande), lo agranda.
   - Si hay **1 GB o más sin particionar pegado a una partición de Linux**, lo suma:
     - hueco **después** → agranda la partición y el btrfs (instantáneo);
     - hueco **antes** (lo normal después de achicar C:) → crea una partición nueva y `btrfs device add` (instantáneo).
   - Los huecos que no tocan a Linux no se usan.

**Para darle más espacio a Linux**: volver a ejecutar el `.exe` → opción 3 (achica la unidad que está justo
antes de Linux), o achicar C: a mano desde Administración de discos, y reiniciar en Linux.
Ojo: a partir de la instalación, **el espacio libre pegado a Linux se lo queda Linux** en el próximo arranque.

Registro: `journalctl -u linuxoneclick`. Estado: `/var/lib/linuxoneclick/` (`modo`, `esp-hecho`, `grub-hecho`).

## Si ya está instalado

Ejecutar el `.exe` de nuevo muestra un menú (con `-SinConfirmar` no hay menú: da error).

1. **Reinstalar**: descarga y verifica el paquete, y recién después borra la instalación actual (entrada de
   arranque, `EFI\<dir>`, todas las particiones del btrfs) y escribe la imagen en **una sola partición** que ocupa
   el mismo lugar, más el espacio sin asignar pegado antes. No achica C:. Si las particiones de Linux no
   están juntas o el lugar no alcanza para la versión nueva, no toca nada y lo avisa.
2. **Desinstalar**: lo mismo que desde Configuración > Aplicaciones (ver abajo).
3. **Darle más espacio a Linux** (solo btrfs): achica la unidad NTFS que está justo antes de Linux, dejando
   `-MargenLibreGB` libres. El espacio queda sin asignar pegado a Linux y el servicio lo suma en el próximo arranque.
   Achicar Linux para devolverle espacio a Windows no está: hay que reinstalar o desinstalar.

## Desinstalar

Borra la entrada de arranque, `EFI\ubuntu` (solo si tiene el marcador), **todas** las particiones del btrfs
(la original y las que se sumaron; se reconocen por el UUID del superbloque) y devuelve el espacio a la unidad
NTFS que está justo antes de Linux (normalmente C:), incluido el espacio sin asignar que haya en el medio.
Si antes de Linux no hay una unidad de Windows, el espacio queda sin asignar. Lo avisa antes de confirmar.

## Rendimiento y seguridad

La imagen trae `mitigations=off` (desactiva las protecciones contra Spectre/Meltdown y similares: hasta ~50 %
más rendimiento en CPUs viejas, a cambio de menos aislamiento entre procesos) y `pcie_aspm=off`
(más estable en algunos equipos, pero más consumo en notebooks). Se cambian en `/etc/default/grub` + `sudo update-grub`.

## Etiquetas vs UUID

- La raíz se busca **por etiqueta** en el `grub.cfg` de la ESP y en `fstab`. Con btrfs de varias particiones,
  todas tienen la misma etiqueta y el mismo UUID.
- El `grub.cfg` interno (`/@/boot/grub/grub.cfg`) usa UUID, y está bien: la copia es bit a bit y el UUID no cambia.
- La ESP de Windows no tiene una etiqueta confiable: el servicio la encuentra por el marcador y escribe su UUID real.
