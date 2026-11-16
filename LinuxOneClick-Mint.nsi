; LinuxOneClick (EFI) - lanzador .exe para Linux Mint
; Compilar con NSISBI:  makensis LinuxOneClick-Mint.nsi
;
; El .exe no trae la imagen: solo Instalar-Linux.ps1 y 7za.exe. Los extrae a una carpeta
; temporal ($PLUGINSDIR, NSIS la borra al salir) y abre PowerShell, que descarga el paquete,
; verifica el SHA256 y hace la instalacion. La consola de PowerShell es la interfaz.
;
; Sin internet: si hay un Mint.7z junto al .exe, se usa ese (igual se verifica el SHA256).

Unicode true
!include x64.nsh
!include LogicLib.nsh

; ---------------------------------------------------------------- paquete publicado
!define NOMBRE  "Linux Mint 22.3"
!define VERSION "22.3.0.0"
!define URL     "https://downloads.sourceforge.net/project/linuxoneclick/Mint.7z"
!define SHA256  "B74A61AF3BA6EA9A739B0DF1AC360B04C3FDD1CF1A76D0F4D8F3010EEE0F9326"
!define LOCAL   "Mint.7z"

; ---------------------------------------------------------------- archivos de entrada
!define DATOS   "..\#1DatosNoAgregar"

Name "LinuxOneClick - ${NOMBRE}"
!ifdef PRUEBA
    ; makensis /DPRUEBA ...: mismo .exe pero solo analiza el paquete (no toca el disco)
    ; y deja la salida en prueba-lanzador.log junto al .exe.
    OutFile "..\Paquete\LinuxOneClick-Mint-PRUEBA.exe"
!else
    OutFile "..\Paquete\LinuxOneClick-Mint.exe"
!endif
Icon "${DATOS}\Iconos\Mint.ico"
RequestExecutionLevel admin
SilentInstall silent
SetCompressor /SOLID lzma
ManifestDPIAware true

VIProductVersion "${VERSION}"
VIAddVersionKey "ProductName"     "LinuxOneClick - ${NOMBRE}"
VIAddVersionKey "FileDescription" "Instalador de ${NOMBRE} junto a Windows (Secure Boot)"
VIAddVersionKey "FileVersion"     "${VERSION}"
VIAddVersionKey "ProductVersion"  "${VERSION}"
VIAddVersionKey "LegalCopyright"  "github.com/weskerty/LinuxOneClick"

Section
    ${IfNot} ${RunningX64}
        MessageBox MB_ICONSTOP "LinuxOneClick needs 64-bit Windows.$\r$\nLinuxOneClick necesita Windows de 64 bits."
        SetErrorLevel 1
        Quit
    ${EndIf}

    ; Subcarpeta propia: en $PLUGINSDIR quedan los plugins de NSIS (System.dll, etc.) y no deben
    ; mezclarse con el directorio de trabajo de PowerShell.
    InitPluginsDir
    SetOutPath "$PLUGINSDIR\lo1c"
    File "Instalar-Linux.ps1"
    File "${DATOS}\7za.exe"

    StrCpy $0 "${URL}"
    ${If} ${FileExists} "$EXEDIR\${LOCAL}"
        StrCpy $0 "$EXEDIR\${LOCAL}"
    ${EndIf}

    ; PowerShell de 64 bits. Si el .exe se compila con stub de 32 bits, System32 apuntaria
    ; a SysWOW64 salvo que se desactive la redireccion (con stub de 64 bits no cambia nada).
    ${DisableX64FSRedirection}
!ifdef PRUEBA
    ExecWait '"$WINDIR\System32\cmd.exe" /c ""$WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$PLUGINSDIR\lo1c\Instalar-Linux.ps1" -Paquete "$0" -SoloAnalizar -SieteZip "$PLUGINSDIR\lo1c\7za.exe" > "$EXEDIR\prueba-lanzador.log" 2>&1"' $1
!else
    ExecWait '"$WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$PLUGINSDIR\lo1c\Instalar-Linux.ps1" -Paquete "$0" -Sha256 ${SHA256} -SieteZip "$PLUGINSDIR\lo1c\7za.exe" -PausarAlFinal' $1
!endif
    ${EnableX64FSRedirection}

    ; Salir de $PLUGINSDIR para que NSIS pueda borrarlo.
    SetOutPath "$TEMP"
    SetErrorLevel $1
SectionEnd
