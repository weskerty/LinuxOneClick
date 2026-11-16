<#
.SYNOPSIS
    LinuxOneClick (EFI): instala una distro Linux en una particion real desde Windows,
    manteniendo Secure Boot activado (cadena shim firmada por Microsoft -> grub -> kernel).

.DESCRIPTION
    Contenido esperado del paquete (.7z o carpeta):
        paquete.json            metadatos (lo genera Crear-Paquete.ps1)
        EFI\<efiDir>\...        archivos que van a la ESP: shimx64.efi, grubx64.efi, mmx64.efi, BOOTX64.CSV
        <imagen>                VHD de tamano fijo o imagen cruda (.img) con GPT y UNA particion Linux

    La particion Linux de la imagen se descomprime en streaming directo a la particion nueva:
    no hace falta espacio temporal para los ~25 GB descomprimidos.

    El sistema de archivos de la imagen tiene que tener etiqueta. El grub.cfg que se escribe en
    la ESP busca la raiz por esa etiqueta, no por UUID.

    Arranque predeterminado (-Arranque):
        Auto     (por defecto) Linux/GRUB primero, salvo que la unidad de Windows este cifrada con
                 BitLocker (o cifrado de dispositivo): entonces Windows primero. Arrancar Windows
                 desde GRUB con BitLocker pide la clave de recuperacion.
        Linux    GRUB primero siempre.
        Windows  Windows primero siempre.

    Todos los mensajes salen en dos lineas: ingles arriba, espanol abajo.

.EXAMPLE
    .\Instalar-Linux.ps1 -Paquete D:\Mint.7z
.EXAMPLE
    .\Instalar-Linux.ps1 -Paquete https://ejemplo.com/Mint.7z -Sha256 0123ABC...
.EXAMPLE
    .\Instalar-Linux.ps1 -Paquete D:\Mint.7z -SoloAnalizar      # no toca nada, no requiere admin
.EXAMPLE
    .\Instalar-Linux.ps1 -Desinstalar
#>
[CmdletBinding(DefaultParameterSetName = 'Instalar')]
param(
    [Parameter(ParameterSetName = 'Instalar', Mandatory = $true, Position = 0)]
    [Parameter(ParameterSetName = 'Analizar', Mandatory = $true, Position = 0)]
    [string]$Paquete,

    [Parameter(ParameterSetName = 'Instalar')] [string]$Sha256,
    [Parameter(ParameterSetName = 'Instalar')] [ValidateRange(10, 2000)] [int]$TamanoGB = 35,
    [Parameter(ParameterSetName = 'Instalar')] [ValidateRange(1, 500)] [int]$MargenLibreGB = 10,
    [Parameter(ParameterSetName = 'Instalar')] [ValidateSet('Auto', 'Linux', 'Windows')] [string]$Arranque = 'Auto',
    [Parameter(ParameterSetName = 'Instalar')] [switch]$LinuxPorDefecto,      # compatibilidad: igual a -Arranque Linux
    [Parameter(ParameterSetName = 'Instalar')] [switch]$SinConfirmar,
    [Parameter(ParameterSetName = 'Instalar')] [switch]$ConservarPaquete,

    [Parameter(ParameterSetName = 'Analizar', Mandatory = $true)] [switch]$SoloAnalizar,

    [Parameter(ParameterSetName = 'Desinstalar', Mandatory = $true)] [switch]$Desinstalar,

    [string]$SieteZip,
    [switch]$PausarAlFinal
)

$ErrorActionPreference = 'Stop'
try { $Host.UI.RawUI.WindowTitle = 'LinuxOneClick' } catch { }
# Lo primero que se ve: compilar el codigo nativo (Add-Type) tarda unos segundos, mas en discos lentos.
Write-Host "Preparing the installer...`nPreparando el instalador..." -ForegroundColor Cyan

# Si Windows PowerShell 5.1 se abre desde PowerShell 7, hereda sus rutas de modulos y falla al
# cargar modulos del sistema (Get-AuthenticodeSignature, etc.). Se dejan solo las de Windows PowerShell.
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $rutas = @("$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules") +
             ([Environment]::GetEnvironmentVariable('PSModulePath', 'Machine') -split ';')
    $env:PSModulePath = (@($rutas | Where-Object { $_ } | Select-Object -Unique)) -join ';'
}
# En PS 5.1 $PSScriptRoot esta vacio dentro de param(); se resuelve aca.
if (-not $SieteZip) { $SieteZip = Join-Path $PSScriptRoot '7za.exe' }

# ------------------------------------------------------------------ constantes

$TIPO_ESP         = '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
$TIPOS_LINUX      = @('{0fc63daf-8483-4772-8e79-3d69d8477de4}',   # Linux filesystem
                      '{4f68bce3-e8cd-4db1-96e7-fbcaf984b709}')   # Linux root x86-64 (discoverable partitions)
$TIPO_LINUX_NUEVA = $TIPOS_LINUX[0]
$GUID_BOOTMGR     = '{9dea862c-5cdd-4e70-acc1-f32b344d4795}'
$GUID_FWBOOTMGR   = '{a5a30fa2-3d06-4e9f-b5f4-a01df9d1fcba}'
$RegEstado        = 'HKLM:\SOFTWARE\LinuxOneClick\EFI'
$RegDesinstalar   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LinuxOneClickEFI'
$Marcador         = 'linuxoneclick.txt'
$DirDatos         = Join-Path $env:ProgramData 'LinuxOneClick'
$BLOQUE           = 4MB
$CABECERA         = 64KB
$MUESTRA_FS       = 128KB
$script:LinuxPrimero = $false

# ------------------------------------------------------------------ nativo

if (-not ('LocNative' -as [type])) {
    # El compilador busca System.dll primero en la carpeta actual. Si el script corre desde la
    # carpeta temporal de NSIS, ahi hay un plugin "System.dll" que no es de .NET y Add-Type falla.
    $cwdAnterior = [Environment]::CurrentDirectory
    [Environment]::CurrentDirectory = [Environment]::SystemDirectory
    try {
    Add-Type -Language CSharp -TypeDefinition @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public static class LocNative {
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern SafeFileHandle CreateFileW(string name, uint access, uint share, IntPtr sa, uint disposition, uint flags, IntPtr template);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool SetFilePointerEx(SafeFileHandle h, long distance, out long newPos, uint method);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool WriteFile(SafeFileHandle h, byte[] buf, int count, out int done, IntPtr ov);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool ReadFile(SafeFileHandle h, byte[] buf, int count, out int done, IntPtr ov);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool FlushFileBuffers(SafeFileHandle h);
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool GetFirmwareType(out uint type);

    static Exception Falla(string en, string es) {
        int e = Marshal.GetLastWin32Error();
        return new IOException(en + " (Win32 error " + e + ")\n" + es + " (error Win32 " + e + ")");
    }

    // 1 = BIOS, 2 = UEFI, 0 = desconocido
    public static uint FirmwareType() { uint t; return GetFirmwareType(out t) ? t : 0; }

    public static SafeFileHandle OpenDisk(int number, bool write) {
        uint access = write ? 0xC0000000u : 0x80000000u;   // GENERIC_READ | GENERIC_WRITE
        uint flags  = write ? 0x80000000u : 0u;            // FILE_FLAG_WRITE_THROUGH
        SafeFileHandle h = CreateFileW(@"\\.\PhysicalDrive" + number, access, 3, IntPtr.Zero, 3, flags, IntPtr.Zero);
        if (h.IsInvalid) throw Falla("Could not open PhysicalDrive" + number, "No se pudo abrir PhysicalDrive" + number);
        return h;
    }

    static void Seek(SafeFileHandle h, long offset) {
        long pos;
        if (!SetFilePointerEx(h, offset, out pos, 0)) throw Falla("SetFilePointerEx " + offset, "SetFilePointerEx " + offset);
    }

    public static void WriteAt(SafeFileHandle h, long offset, byte[] buf, int count) {
        Seek(h, offset);
        int done;
        if (!WriteFile(h, buf, count, out done, IntPtr.Zero) || done != count) throw Falla("WriteFile at offset " + offset, "WriteFile en offset " + offset);
    }

    public static void ReadAt(SafeFileHandle h, long offset, byte[] buf, int count) {
        Seek(h, offset);
        int done;
        if (!ReadFile(h, buf, count, out done, IntPtr.Zero) || done != count) throw Falla("ReadFile at offset " + offset, "ReadFile en offset " + offset);
    }

    public static void Flush(SafeFileHandle h) {
        if (!FlushFileBuffers(h)) throw Falla("FlushFileBuffers", "FlushFileBuffers");
    }

    // Lee hasta 'count' bytes o hasta el final del stream (los pipes devuelven de a pedazos).
    public static int ReadFull(Stream s, byte[] buf, int count) {
        int total = 0;
        while (total < count) {
            int n = s.Read(buf, total, count - total);
            if (n <= 0) break;
            total += n;
        }
        return total;
    }

    public static void Skip(Stream s, long count) {
        byte[] tmp = new byte[1 << 20];
        while (count > 0) {
            int n = s.Read(tmp, 0, (int)Math.Min(tmp.Length, count));
            if (n <= 0) throw new EndOfStreamException("The image ended earlier than expected.\nLa imagen termino antes de lo esperado.");
            count -= n;
        }
    }
}
'@
    } finally { [Environment]::CurrentDirectory = $cwdAnterior }
}

# ------------------------------------------------------------------ mensajes

# Mensajes en dos lineas: ingles arriba, espanol abajo.
function T([string]$En, [string]$Es) { return "$En`n$Es" }

function Write-Lineas([string]$Texto, [string]$Primera, [string]$Resto, [string]$Color) {
    $i = 0
    foreach ($l in ($Texto -split "`n")) {
        $pre = if ($i -eq 0) { $Primera } else { $Resto }
        Write-Host ($pre + $l) -ForegroundColor $Color
        $i++
    }
}
function Write-Paso([string]$Texto)  { Write-Host ''; Write-Lineas $Texto '==> ' '    ' 'Cyan' }
function Write-Aviso([string]$Texto) { Write-Lineas $Texto 'WARNING: ' 'AVISO:   ' 'Yellow' }
function Write-Info([string]$Texto, [string]$Color = 'Gray') { Write-Lineas $Texto '' '' $Color }

function Read-Confirmacion {
    Write-Host 'Type YES to continue' -ForegroundColor White
    $r = Read-Host 'Escribi SI para continuar'
    return (@('YES', 'SI') -contains ([string]$r).Trim().ToUpper())
}

# ------------------------------------------------------------------ utilidades

function Test-Admin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Las particiones sin letra devuelven [char]0, que PowerShell considera "verdadero".
function Test-Letra($Letra) { return ([string]$Letra) -match '^[A-Za-z]$' }

function Format-GB([long]$Bytes) { return '{0:N1} GB' -f ($Bytes / 1GB) }

# Ejecuta un programa nativo sin que stderr se convierta en excepcion (PS 5.1 + Stop).
function Invoke-Nativo([string]$Exe, [string[]]$Argumentos) {
    $ErrorActionPreference = 'Continue'
    $salida = & $Exe @Argumentos 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Codigo = $LASTEXITCODE; Salida = @($salida) }
}

function Invoke-Bcd([string[]]$Argumentos) {
    $r = Invoke-Nativo "$env:SystemRoot\System32\bcdedit.exe" $Argumentos
    if ($r.Codigo -ne 0) {
        $txt = "bcdedit $($Argumentos -join ' '): $($r.Salida -join ' ')"
        throw (T "Failed: $txt" "Fallo: $txt")
    }
    return $r.Salida
}

function Copy-Directorio([string]$Origen, [string]$Destino) {
    [IO.Directory]::CreateDirectory($Destino) | Out-Null
    foreach ($f in [IO.Directory]::GetFiles($Origen)) {
        [IO.File]::Copy($f, [IO.Path]::Combine($Destino, [IO.Path]::GetFileName($f)), $true)
    }
    foreach ($d in [IO.Directory]::GetDirectories($Origen)) {
        Copy-Directorio $d ([IO.Path]::Combine($Destino, [IO.Path]::GetFileName($d)))
    }
}

function Get-TamanoDirectorio([string]$Ruta) {
    $total = [long]0
    foreach ($f in [IO.Directory]::GetFiles($Ruta, '*', [IO.SearchOption]::AllDirectories)) { $total += (New-Object IO.FileInfo $f).Length }
    return $total
}

function Get-Ascii([byte[]]$Buf, [int]$Offset, [int]$Largo) {
    return [Text.Encoding]::ASCII.GetString($Buf, $Offset, $Largo)
}

function Get-Hex([byte[]]$Buf, [int]$Offset, [int]$Largo) {
    $sb = New-Object Text.StringBuilder
    for ($i = 0; $i -lt $Largo; $i++) { [void]$sb.Append($Buf[$Offset + $i].ToString('x2')) }
    return $sb.ToString()
}

function Assert-SieteZip {
    if (-not (Test-Path -LiteralPath $SieteZip)) {
        throw (T "7-Zip not found at '$SieteZip'. Use -SieteZip to point to 7za.exe or 7z.exe." "No se encontro 7-Zip en '$SieteZip'. Usa -SieteZip para indicar 7za.exe o 7z.exe.")
    }
}

# ------------------------------------------------------------------ paquete

# Descarga en este orden: curl.exe de Windows (10 1803+ / 11; sigue redirecciones y retoma),
# BITS, Invoke-WebRequest. Siempre con un user-agent que no sea de navegador: a los navegadores
# SourceForge les devuelve su pagina HTML en vez del archivo.
function Save-Descarga([string]$Url, [string]$Destino) {
    $curl = Join-Path $env:SystemRoot 'System32\curl.exe'
    if (Test-Path -LiteralPath $curl) {
        for ($intento = 1; $intento -le 3; $intento++) {
            # -C - retoma lo que haya quedado a medias (de este intento o de una corrida anterior)
            & $curl -L --fail --progress-bar -A 'LinuxOneClick' --connect-timeout 30 -C - -o $Destino $Url
            if ($LASTEXITCODE -eq 0) { return }
            Write-Aviso (T "curl exited with code $LASTEXITCODE (attempt $intento of 3)." "curl termino con codigo $LASTEXITCODE (intento $intento de 3).")
            if ($intento -lt 3) { Start-Sleep -Seconds 5 }
        }
        Write-Aviso (T 'curl could not download; trying BITS.' 'curl no pudo descargar; se prueba con BITS.')
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        Start-BitsTransfer -Source $Url -Destination $Destino -DisplayName 'LinuxOneClick' -ErrorAction Stop
    } catch {
        $m = $_.Exception.Message
        Write-Aviso (T "BITS not available ($m); using a simple download, without progress." "BITS no disponible ($m); se usa descarga simple, sin progreso.")
        $pp = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
        try { Invoke-WebRequest -Uri $Url -OutFile $Destino -UseBasicParsing -UserAgent 'LinuxOneClick' }
        finally { $ProgressPreference = $pp }
    }
}

function Resolve-Paquete([string]$Origen) {
    if ($Origen -match '^https?://') {
        $dir = Join-Path $DirDatos 'descargas'
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $nombre = [IO.Path]::GetFileName(([uri]$Origen).LocalPath)
        if (-not $nombre) { $nombre = 'paquete.7z' }
        $destino = Join-Path $dir $nombre

        # Si ya esta bajado entero (corrida anterior, -ConservarPaquete) no se vuelve a bajar.
        $yaEsta = $Sha256 -and (Test-Path -LiteralPath $destino) -and
                  ((Get-FileHash -Algorithm SHA256 -LiteralPath $destino).Hash -eq $Sha256.Trim().ToUpper())
        if ($yaEsta) {
            Write-Paso (T "Package already downloaded: $destino" "Paquete ya descargado: $destino")
        } else {
            Write-Paso (T "Downloading $Origen" "Descargando $Origen")
            Save-Descarga $Origen $destino
        }
        $item = Get-Item -LiteralPath $destino
        $descargado = $true
    } else {
        $item = Get-Item -LiteralPath $Origen
        $descargado = $false
    }

    if ($Sha256 -and -not $item.PSIsContainer) {
        Write-Paso (T 'Checking the package SHA256' 'Verificando SHA256 del paquete')
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $item.FullName).Hash
        if ($hash -ne $Sha256.Trim().ToUpper()) {
            # Una descarga corrupta no se conserva: si no, el reintento la "retomaria".
            if ($descargado) { Remove-Item -LiteralPath $item.FullName -Force -ErrorAction SilentlyContinue }
            throw (T "The package SHA256 does not match (expected $Sha256, got $hash)." "El SHA256 del paquete no coincide (esperado $Sha256, obtenido $hash).")
        }
    }

    return [pscustomobject]@{ Ruta = $item.FullName; EsDirectorio = [bool]$item.PSIsContainer; Descargado = $descargado }
}

# Extrae paquete.json y la carpeta EFI a un temporal (todo menos la imagen grande).
function Expand-Paquete($Pkg) {
    $tmp = Join-Path $env:TEMP ('linuxoneclick-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $tmp | Out-Null

    if ($Pkg.EsDirectorio) {
        Copy-Item -LiteralPath (Join-Path $Pkg.Ruta 'paquete.json') -Destination $tmp
    } else {
        Assert-SieteZip
        $r = Invoke-Nativo $SieteZip @('e', $Pkg.Ruta, 'paquete.json', "-o$tmp", '-y', '-bso0', '-bsp0')
        if ($r.Codigo -ne 0) {
            $txt = $r.Salida -join ' '
            throw (T "Could not read paquete.json from the package: $txt" "No se pudo leer paquete.json del paquete: $txt")
        }
    }

    $json = Get-Content -Raw -LiteralPath (Join-Path $tmp 'paquete.json') | ConvertFrom-Json
    $meta = [pscustomobject]@{
        Nombre      = if ($json.nombre) { [string]$json.nombre } else { 'Linux' }
        Imagen      = [string]$json.imagen
        EfiDir      = [string]$json.efiDir
        Loader      = [string]$json.loader
        Etiqueta    = [string]$json.etiqueta
        PrefijoGrub = if ($json.prefijoGrub) { [string]$json.prefijoGrub } else { '/boot/grub' }
        MinimoGB    = if ($json.minimoGB) { [int]$json.minimoGB } else { 0 }
        Particion   = if ($json.particion) { [int]$json.particion } else { 0 }
    }

    # El paquete puede venir de internet: nada de rutas raras.
    $invalido = $null
    if ($meta.Imagen -notmatch '^[^\\/:*?"<>|]+$')          { $invalido = 'imagen' }
    if ($meta.EfiDir -notmatch '^[A-Za-z0-9_.-]+$')          { $invalido = 'efiDir' }
    if ($meta.Loader -notmatch '^[A-Za-z0-9_.-]+\.efi$')     { $invalido = 'loader' }
    if ($meta.PrefijoGrub -notmatch '^/[A-Za-z0-9_./@-]*$')  { $invalido = 'prefijoGrub' }
    if ($meta.Nombre -match '["\r\n%^&|<>]')                 { $invalido = 'nombre' }
    if ($invalido) { throw (T "paquete.json: invalid '$invalido'." "paquete.json: '$invalido' invalido.") }

    if ($Pkg.EsDirectorio) {
        Copy-Directorio (Join-Path $Pkg.Ruta 'EFI') (Join-Path $tmp 'EFI')
    } else {
        $r = Invoke-Nativo $SieteZip @('x', $Pkg.Ruta, "-o$tmp", "-x!$($meta.Imagen)", '-y', '-bso0', '-bsp0')
        if ($r.Codigo -ne 0) {
            $txt = $r.Salida -join ' '
            throw (T "Could not extract the EFI files: $txt" "No se pudieron extraer los archivos EFI: $txt")
        }
    }

    $dirEfi = Join-Path $tmp "EFI\$($meta.EfiDir)"
    $rel = "EFI\$($meta.EfiDir)\$($meta.Loader)"
    if (-not (Test-Path -LiteralPath (Join-Path $dirEfi $meta.Loader))) { throw (T "The package does not include $rel." "El paquete no trae $rel.") }
    foreach ($f in 'grubx64.efi', 'mmx64.efi') {
        if (-not (Test-Path -LiteralPath (Join-Path $dirEfi $f))) {
            Write-Aviso (T "The package does not include EFI\$($meta.EfiDir)\$f." "El paquete no trae EFI\$($meta.EfiDir)\$f.")
        }
    }

    return [pscustomobject]@{ Tmp = $tmp; Meta = $meta; DirEfi = $dirEfi }
}

# ------------------------------------------------------------------ imagen

function Open-Imagen($Pkg, $Meta) {
    if ($Pkg.EsDirectorio) {
        $ruta = [IO.Path]::Combine($Pkg.Ruta, $Meta.Imagen)
        return [pscustomobject]@{ Stream = [IO.File]::OpenRead($ruta); Proceso = $null }
    }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $SieteZip
    $psi.Arguments = 'e -so -bd "{0}" "{1}"' -f $Pkg.Ruta, $Meta.Imagen
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true       # al cortar el pipe a proposito 7z se queja; solo se muestra si hay un error real
    $p = [Diagnostics.Process]::Start($psi)
    $errores = $p.StandardError.ReadToEndAsync()
    return [pscustomobject]@{ Stream = $p.StandardOutput.BaseStream; Proceso = $p; Errores = $errores }
}

# Mensaje de 7-Zip si termino solo (para explicar una imagen cortada o corrupta).
function Get-ErrorImagen($Img) {
    if (-not $Img.Proceso) { return '' }
    if (-not $Img.Proceso.WaitForExit(5000)) { return '' }
    $txt = ($Img.Errores.Result -replace '\s+', ' ').Trim()
    if ($Img.Proceso.ExitCode -ne 0 -or $txt) { return "`n7-Zip ($($Img.Proceso.ExitCode)): $txt" }
    return ''
}

function Close-Imagen($Img) {
    if (-not $Img) { return }
    try { $Img.Stream.Dispose() } catch { }
    if ($Img.Proceso) {
        if (-not $Img.Proceso.HasExited) { try { $Img.Proceso.Kill() } catch { } }
        $Img.Proceso.WaitForExit()
    }
}

function Read-Gpt([IO.Stream]$Stream) {
    $cab = New-Object byte[] $CABECERA
    $n = [LocNative]::ReadFull($Stream, $cab, $CABECERA)
    if ($n -lt $CABECERA) {
        throw (T 'The image is empty, too small, or 7-Zip could not extract it (check the name in paquete.json).' `
                 'La imagen esta vacia, es demasiado chica, o 7-Zip no la pudo extraer (revisa el nombre en paquete.json).')
    }
    if ((Get-Ascii $cab 0 8) -eq 'conectix') {
        throw (T 'The image is a dynamic VHD. A fixed-size VHD or a raw .img image is required.' `
                 'La imagen es un VHD dinamico. Hace falta un VHD de tamano fijo o una imagen .img cruda.')
    }

    $ss = 0
    foreach ($c in 512, 4096) { if ((Get-Ascii $cab $c 8) -eq 'EFI PART') { $ss = $c; break } }
    if (-not $ss) { throw (T 'The image has no GPT partition table.' 'La imagen no tiene tabla de particiones GPT.') }

    $lbaEntradas = [BitConverter]::ToUInt64($cab, $ss + 72)
    $numEntradas = [BitConverter]::ToUInt32($cab, $ss + 80)
    $tamEntrada  = [BitConverter]::ToUInt32($cab, $ss + 84)
    $inicio = [long]$lbaEntradas * $ss
    if ($tamEntrada -lt 128 -or ($inicio + [long]$numEntradas * $tamEntrada) -gt $CABECERA) {
        throw (T 'Unexpected GPT table format.' 'Tabla GPT con formato inesperado.')
    }

    $parts = @()
    for ($i = 0; $i -lt $numEntradas; $i++) {
        $o = [int]($inicio + [long]$i * $tamEntrada)
        $tipoBytes = New-Object byte[] 16
        [Array]::Copy($cab, $o, $tipoBytes, 0, 16)
        $tipo = (New-Object Guid (, $tipoBytes)).ToString('B')
        if ($tipo -eq '{00000000-0000-0000-0000-000000000000}') { continue }
        $primero = [long][BitConverter]::ToUInt64($cab, $o + 32)
        $ultimo  = [long][BitConverter]::ToUInt64($cab, $o + 40)
        $parts += [pscustomobject]@{
            Indice   = $i + 1
            Tipo     = $tipo
            Offset   = $primero * $ss
            Longitud = ($ultimo - $primero + 1) * $ss
            Nombre   = [Text.Encoding]::Unicode.GetString($cab, $o + 56, 72).TrimEnd([char]0)
        }
    }
    return [pscustomobject]@{ SectorSize = $ss; Particiones = $parts; Leidos = [long]$CABECERA }
}

function Select-ParticionRaiz($Gpt, $Meta) {
    if ($Meta.Particion) {
        $p = @($Gpt.Particiones | Where-Object { $_.Indice -eq $Meta.Particion })
        if ($p.Count -ne 1) {
            throw (T "Partition $($Meta.Particion) given in paquete.json does not exist in the image." `
                     "La particion $($Meta.Particion) indicada en paquete.json no existe en la imagen.")
        }
        return $p[0]
    }
    $linux = @($Gpt.Particiones | Where-Object { $TIPOS_LINUX -contains $_.Tipo })
    if ($linux.Count -ne 1) {
        throw (T "Expected a single Linux partition in the image and found $($linux.Count). Set it with 'particion' in paquete.json." `
                 "Se esperaba una sola particion Linux en la imagen y hay $($linux.Count). Indicala con 'particion' en paquete.json.")
    }
    return $linux[0]
}

# Lee etiqueta/UUID/tamano del superbloque ext2/3/4 o btrfs.
function Get-InfoFs([byte[]]$Buf) {
    if ($Buf.Length -ge 2048 -and [BitConverter]::ToUInt16($Buf, 1024 + 0x38) -eq 0xEF53) {
        $b = 1024
        $bloques = [long][BitConverter]::ToUInt32($Buf, $b + 0x04)
        if ([BitConverter]::ToUInt32($Buf, $b + 0x60) -band 0x80) {     # INCOMPAT_64BIT
            $bloques += ([long][BitConverter]::ToUInt32($Buf, $b + 0x150)) -shl 32
        }
        $tamBloque = [long]1024 -shl [BitConverter]::ToUInt32($Buf, $b + 0x18)
        $u = Get-Hex $Buf ($b + 0x68) 16
        return [pscustomobject]@{
            Tipo     = 'ext4'
            Etiqueta = [Text.Encoding]::UTF8.GetString($Buf, $b + 0x78, 16).TrimEnd([char]0)
            Uuid     = '{0}-{1}-{2}-{3}-{4}' -f $u.Substring(0, 8), $u.Substring(8, 4), $u.Substring(12, 4), $u.Substring(16, 4), $u.Substring(20, 12)
            Tamano   = $bloques * $tamBloque
        }
    }
    $b = 65536
    if ($Buf.Length -ge ($b + 4096) -and (Get-Ascii $Buf ($b + 0x40) 8) -eq '_BHRfS_M') {
        $u = Get-Hex $Buf ($b + 0x20) 16
        return [pscustomobject]@{
            Tipo     = 'btrfs'
            Etiqueta = [Text.Encoding]::UTF8.GetString($Buf, $b + 0x12B, 256).TrimEnd([char]0)
            Uuid     = '{0}-{1}-{2}-{3}-{4}' -f $u.Substring(0, 8), $u.Substring(8, 4), $u.Substring(12, 4), $u.Substring(16, 4), $u.Substring(20, 12)
            Tamano   = [long][BitConverter]::ToUInt64($Buf, $b + 0x70)
        }
    }
    return $null
}

function Get-AnalisisImagen($Pkg, $Meta) {
    $img = Open-Imagen $Pkg $Meta
    try {
        $gpt = Read-Gpt $img.Stream
        $raiz = Select-ParticionRaiz $gpt $Meta
        if ($raiz.Offset -lt $gpt.Leidos) {
            throw (T 'The Linux partition starts too close to the beginning of the image.' 'La particion Linux empieza demasiado cerca del inicio de la imagen.')
        }
        [LocNative]::Skip($img.Stream, $raiz.Offset - $gpt.Leidos)
        $buf = New-Object byte[] $MUESTRA_FS
        [void][LocNative]::ReadFull($img.Stream, $buf, $MUESTRA_FS)
        $fs = Get-InfoFs $buf
    } finally {
        Close-Imagen $img
    }

    if (-not $fs) { throw (T 'The Linux partition in the image is neither ext4 nor btrfs.' 'La particion Linux de la imagen no es ext4 ni btrfs.') }
    if (-not $fs.Etiqueta) {
        throw (T 'The image file system has no label. Set one in the VM (see README).' 'El sistema de archivos de la imagen no tiene etiqueta. Ponele una en la VM (ver README).')
    }
    if ($fs.Etiqueta -notmatch '^[A-Za-z0-9_.-]+$') {
        throw (T "The label '$($fs.Etiqueta)' has unsupported characters (use letters, numbers, _ . -)." `
                 "La etiqueta '$($fs.Etiqueta)' tiene caracteres no soportados (usar letras, numeros, _ . -).")
    }
    if ($Meta.Etiqueta -and $Meta.Etiqueta -cne $fs.Etiqueta) {
        throw (T "paquete.json says label '$($Meta.Etiqueta)' but the image has '$($fs.Etiqueta)'." `
                 "paquete.json dice etiqueta '$($Meta.Etiqueta)' pero la imagen tiene '$($fs.Etiqueta)'.")
    }

    return [pscustomobject]@{ Gpt = $gpt; Raiz = $raiz; Fs = $fs }
}

# ------------------------------------------------------------------ ESP

function Get-LetraLibre {
    $usadas = @([IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name.Substring(0, 1).ToUpper() })
    foreach ($l in 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'R', 'Q', 'P', 'O', 'N') {
        if ($usadas -notcontains $l) { return $l }
    }
    throw (T 'No free drive letters to mount the EFI partition.' 'No hay letras de unidad libres para montar la particion EFI.')
}

function Mount-Esp {
    $esp = @(Get-Partition | Where-Object { $_.GptType -eq $TIPO_ESP -and $_.IsSystem })
    if ($esp.Count -ne 1) {
        throw (T "Could not identify the system EFI partition (found: $($esp.Count))." "No se pudo identificar la particion EFI del sistema (encontradas: $($esp.Count)).")
    }
    if (Test-Letra $esp[0].DriveLetter) {
        return [pscustomobject]@{ Letra = [string]$esp[0].DriveLetter; Montada = $false; Particion = $esp[0] }
    }
    $letra = Get-LetraLibre
    $r = Invoke-Nativo "$env:SystemRoot\System32\mountvol.exe" @("$($letra):", '/S')
    if ($r.Codigo -ne 0) {
        $txt = $r.Salida -join ' '
        throw (T "mountvol could not mount the EFI partition: $txt" "mountvol no pudo montar la particion EFI: $txt")
    }
    for ($i = 0; $i -lt 20 -and -not [IO.Directory]::Exists("$($letra):\"); $i++) { Start-Sleep -Milliseconds 250 }
    return [pscustomobject]@{ Letra = $letra; Montada = $true; Particion = $esp[0] }
}

function Dismount-Esp($Esp) {
    if ($Esp -and $Esp.Montada) {
        [void](Invoke-Nativo "$env:SystemRoot\System32\mountvol.exe" @("$($Esp.Letra):", '/D'))
    }
}

# ------------------------------------------------------------------ Secure Boot / BitLocker

function Get-EstadoSecureBoot {
    try { return [bool](Confirm-SecureBootUEFI) } catch { return $null }
}

# Devuelve $true/$false si la db de Secure Boot confia en la CA que firmo el shim; $null si no se puede saber.
function Test-ConfianzaShim([string]$RutaShim) {
    $cn = $null
    try {
        $firma = Get-AuthenticodeSignature -LiteralPath $RutaShim
        if ($firma.SignerCertificate -and $firma.SignerCertificate.Issuer -match 'CN=([^,]+)') { $cn = $Matches[1].Trim() }
    } catch { }
    try { $db = [Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI -Name db).Bytes) } catch { return $null }
    if ($cn) { return $db.Contains($cn) }
    return ($db.Contains('Microsoft Corporation UEFI CA 2011') -or $db.Contains('Microsoft UEFI CA 2023'))
}

# BitLocker / cifrado de dispositivo de la unidad de Windows.
#   Cifrado:   cifrada o cifrandose, aunque la proteccion este suspendida o "esperando activacion"
#              (cifrado de dispositivo de fabrica): la proteccion se puede activar despues sola.
#   Protegido: proteccion activa (el TPM solo libera la clave si el arranque es el de siempre).
function Get-EstadoBitLocker([string]$Unidad) {
    $v = $null
    try {
        $v = Get-CimInstance -Namespace 'root\cimv2\Security\MicrosoftVolumeEncryption' -ClassName Win32_EncryptableVolume `
                             -Filter "DriveLetter='$Unidad'" -ErrorAction Stop
    } catch { }
    if (-not $v) { return [pscustomobject]@{ Cifrado = $false; Protegido = $false } }
    $protegido = ($v.ProtectionStatus -eq 1)
    $conv = $v.ConversionStatus
    if ($null -eq $conv) {
        try { $conv = (Invoke-CimMethod -InputObject $v -MethodName GetConversionStatus -ErrorAction Stop).ConversionStatus } catch { $conv = 0 }
    }
    return [pscustomobject]@{ Cifrado = ($protegido -or [int]$conv -ne 0); Protegido = $protegido }
}

# ------------------------------------------------------------------ particiones

function Get-Candidatos([long]$Necesario) {
    $res = @()
    foreach ($vol in @(Get-Volume | Where-Object { (Test-Letra $_.DriveLetter) -and $_.FileSystem -eq 'NTFS' -and $_.DriveType -eq 'Fixed' })) {
        $part = Get-Partition -DriveLetter $vol.DriveLetter -ErrorAction SilentlyContinue
        if (-not $part) { continue }
        $disco = Get-Disk -Number $part.DiskNumber
        if ($disco.PartitionStyle -ne 'GPT') { continue }
        if (@('USB', 'SD', 'MMC') -contains [string]$disco.BusType) { continue }
        try { $sop = Get-PartitionSupportedSize -DiskNumber $part.DiskNumber -PartitionNumber $part.PartitionNumber } catch { continue }
        $reducible = $part.Size - $sop.SizeMin
        if ($reducible -lt ($Necesario + 1MB)) { continue }
        if (($vol.SizeRemaining - $Necesario) -lt ($MargenLibreGB * 1GB)) { continue }
        $res += [pscustomobject]@{
            Letra           = [string]$vol.DriveLetter
            Etiqueta        = $vol.FileSystemLabel
            Libre           = $vol.SizeRemaining
            Disco           = $disco.FriendlyName
            DiskNumber      = $part.DiskNumber
            PartitionNumber = $part.PartitionNumber
        }
    }
    return $res
}

function Select-Candidato([object[]]$Candidatos) {
    if ($Candidatos.Count -eq 1) { return $Candidatos[0] }
    Write-Host ''
    Write-Info (T 'Drives where space can be made:' 'Unidades donde se puede hacer lugar:')
    Write-Host ''
    for ($i = 0; $i -lt $Candidatos.Count; $i++) {
        $c = $Candidatos[$i]
        Write-Host ("  {0}. {1}: {2,-14} {3} free / libres  ({4})" -f ($i + 1), $c.Letra, $c.Etiqueta, (Format-GB $c.Libre), $c.Disco)
    }
    do {
        Write-Host ''
        Write-Host "Choose the drive number (1-$($Candidatos.Count))"
        $sel = Read-Host "Elegi el numero de unidad (1-$($Candidatos.Count))"
        $num = 0
        $ok = [int]::TryParse($sel, [ref]$num) -and $num -ge 1 -and $num -le $Candidatos.Count
    } while (-not $ok)
    return $Candidatos[$num - 1]
}

function New-ParticionLinux($Cand, [long]$Necesario) {
    $p = Get-Partition -DiskNumber $Cand.DiskNumber -PartitionNumber $Cand.PartitionNumber
    $finOriginal = $p.Offset + $p.Size
    $gb = Format-GB $Necesario

    Write-Paso (T "Shrinking $($Cand.Letra): by $gb" "Reduciendo $($Cand.Letra): en $gb")
    Resize-Partition -DiskNumber $p.DiskNumber -PartitionNumber $p.PartitionNumber -Size ($p.Size - $Necesario - 1MB)

    try {
        $p = Get-Partition -DiskNumber $Cand.DiskNumber -PartitionNumber $Cand.PartitionNumber
        $offset = [long]([Math]::Ceiling(($p.Offset + $p.Size) / 1MB)) * 1MB
        if (($offset + $Necesario) -gt $finOriginal) {
            throw (T 'The freed space is not enough (inconsistent calculation).' 'El espacio liberado no alcanza (calculo inconsistente).')
        }
        Write-Paso (T 'Creating the Linux partition' 'Creando la particion Linux')
        $nueva = New-Partition -DiskNumber $p.DiskNumber -Offset $offset -Size $Necesario -GptType $TIPO_LINUX_NUEVA
        $nueva = Get-Partition -DiskNumber $nueva.DiskNumber -PartitionNumber $nueva.PartitionNumber
        if (-not $nueva.Guid) { throw (T 'The new partition has no GUID.' 'La particion nueva no tiene GUID.') }
        return $nueva
    } catch {
        Write-Aviso (T "Could not create the partition; giving the space back to $($Cand.Letra):" "No se pudo crear la particion; devolviendo el espacio a $($Cand.Letra):")
        try {
            $sop = Get-PartitionSupportedSize -DiskNumber $Cand.DiskNumber -PartitionNumber $Cand.PartitionNumber
            Resize-Partition -DiskNumber $Cand.DiskNumber -PartitionNumber $Cand.PartitionNumber -Size $sop.SizeMax
        } catch {
            $m = $_.Exception.Message
            Write-Aviso (T "Could not extend $($Cand.Letra): either ($m). Do it from Disk Management." "Tampoco se pudo extender $($Cand.Letra): ($m). Hacelo desde Administracion de discos.")
        }
        throw
    }
}

function Copy-Imagen($Pkg, $Meta, $Analisis, $Nueva) {
    $raiz = $Analisis.Raiz
    if ($raiz.Longitud -gt $Nueva.Size) {
        throw (T 'The image partition is larger than the new partition.' 'La particion de la imagen es mas grande que la particion nueva.')
    }
    $sector = [int](Get-Disk -Number $Nueva.DiskNumber).LogicalSectorSize
    if ($sector -le 0) { $sector = 512 }

    $actividad = "Copying / Copiando $($Meta.Nombre)"
    $img = Open-Imagen $Pkg $Meta
    $h = $null
    try {
        $gpt = Read-Gpt $img.Stream
        $r2 = Select-ParticionRaiz $gpt $Meta
        if ($r2.Offset -ne $raiz.Offset -or $r2.Longitud -ne $raiz.Longitud) {
            throw (T 'The image changed between the analysis and the copy.' 'La imagen cambio entre el analisis y la copia.')
        }
        [LocNative]::Skip($img.Stream, $raiz.Offset - $gpt.Leidos)

        $h = [LocNative]::OpenDisk($Nueva.DiskNumber, $true)
        $buf = New-Object byte[] $BLOQUE
        $hecho = [long]0
        $ultimoAviso = [long]0
        $reloj = [Diagnostics.Stopwatch]::StartNew()

        while ($hecho -lt $raiz.Longitud) {
            $pedir = [int][Math]::Min([long]$BLOQUE, $raiz.Longitud - $hecho)
            $n = [LocNative]::ReadFull($img.Stream, $buf, $pedir)
            if ($n -ne $pedir) {
                $gb = Format-GB $hecho
                throw ((T "The image was cut off after $gb of the partition." "La imagen se corto a los $gb de la particion.") + (Get-ErrorImagen $img))
            }

            if ($hecho -eq 0) {
                $fs = Get-InfoFs $buf
                if (-not $fs -or $fs.Uuid -ne $Analisis.Fs.Uuid) {
                    throw (T 'The image content does not match what was analyzed.' 'El contenido de la imagen no coincide con lo analizado.')
                }
            }

            $escribir = $n
            $resto = $n % $sector
            if ($resto) { $escribir = $n + $sector - $resto; [Array]::Clear($buf, $n, $escribir - $n) }
            if (($hecho + $escribir) -gt $Nueva.Size) {
                throw (T 'Tried to write outside the new partition.' 'Se intento escribir fuera de la particion nueva.')
            }

            [LocNative]::WriteAt($h, $Nueva.Offset + $hecho, $buf, $escribir)
            $hecho += $n

            if (($hecho - $ultimoAviso) -ge 256MB -or $hecho -eq $raiz.Longitud) {
                $ultimoAviso = $hecho
                $mbs = if ($reloj.Elapsed.TotalSeconds -gt 0) { $hecho / 1MB / $reloj.Elapsed.TotalSeconds } else { 0 }
                Write-Progress -Activity $actividad -Status ('{0} / {1}  ({2:N0} MB/s)' -f (Format-GB $hecho), (Format-GB $raiz.Longitud), $mbs) `
                               -PercentComplete ([int](100 * $hecho / $raiz.Longitud))
            }
        }

        # Borrar el ultimo MiB de la particion: evita que blkid encuentre firmas viejas de lo que habia antes.
        $finEscrito = [long]([Math]::Ceiling($hecho / $sector)) * $sector
        if (($Nueva.Size - 1MB) -ge $finEscrito) {
            $ceros = New-Object byte[] 1MB
            [LocNative]::WriteAt($h, $Nueva.Offset + $Nueva.Size - 1MB, $ceros, $ceros.Length)
        }
        [LocNative]::Flush($h)

        $ver = New-Object byte[] $MUESTRA_FS
        [LocNative]::ReadAt($h, $Nueva.Offset, $ver, $ver.Length)
        $fs2 = Get-InfoFs $ver
        if (-not $fs2 -or $fs2.Uuid -ne $Analisis.Fs.Uuid) {
            throw (T 'Verification failed: the written superblock does not match.' 'Verificacion fallida: el superbloque escrito no coincide.')
        }
        $t = '{0:mm\:ss}' -f $reloj.Elapsed
        Write-Info (T "Copied $(Format-GB $hecho) in $t." "Copiados $(Format-GB $hecho) en $t.")
    } finally {
        Write-Progress -Activity $actividad -Completed
        if ($h) { $h.Dispose() }
        Close-Imagen $img
    }
}

# ------------------------------------------------------------------ arranque

function Install-ArchivosEsp($Esp, $Exp, $Fs) {
    $destino = "$($Esp.Letra):\EFI\$($Exp.Meta.EfiDir)"
    if ([IO.Directory]::Exists($destino)) { throw (T "$destino already exists." "$destino ya existe.") }
    Copy-Directorio $Exp.DirEfi $destino

    $utf8 = New-Object Text.UTF8Encoding $false
    # Stub: busca la raiz por etiqueta y carga el grub.cfg real de la particion Linux.
    $cfg = "search --no-floppy --label $($Fs.Etiqueta) --set=root`nset prefix=(`$root)'$($Exp.Meta.PrefijoGrub)'`nconfigfile `$prefix/grub.cfg`n"
    [IO.File]::WriteAllText("$destino\grub.cfg", $cfg, $utf8)

    # Marcador: lo usa el desinstalador (solo borra carpetas con marcador) y el servicio de Linux.
    $marca = "nombre=$($Exp.Meta.Nombre)`netiqueta=$($Fs.Etiqueta)`nuuid=$($Fs.Uuid)`n" +
             "por_defecto=$(if ($script:LinuxPrimero) { 'linux' } else { 'windows' })`ninstalado=$(Get-Date -Format 'yyyy-MM-dd')`n"
    [IO.File]::WriteAllText("$destino\$Marcador", $marca, $utf8)
}

function Register-Arranque($Meta) {
    # Copiar {bootmgr} crea una entrada de firmware (NVRAM) real; /create osloader no.
    $salida = Invoke-Bcd @('/copy', '{bootmgr}', '/d', $Meta.Nombre)
    $guid = [regex]::Match(($salida -join ' '), '\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}').Value
    if (-not $guid) {
        $txt = $salida -join ' '
        throw (T "Could not read the GUID of the new boot entry: $txt" "No se pudo leer el GUID de la entrada creada: $txt")
    }
    Set-ItemProperty -Path $RegEstado -Name BcdGuid -Value $guid

    Invoke-Bcd @('/set', $guid, 'path', "\EFI\$($Meta.EfiDir)\$($Meta.Loader)") | Out-Null
    $posicion = if ($script:LinuxPrimero) { '/addfirst' } else { '/addlast' }
    Invoke-Bcd @('/set', '{fwbootmgr}', 'displayorder', $guid, $posicion) | Out-Null
    Invoke-Bcd @('/set', '{fwbootmgr}', 'bootsequence', $guid) | Out-Null
    return $guid
}

function Remove-EntradasFirmware([string]$EfiDir) {
    $r = Invoke-Nativo "$env:SystemRoot\System32\bcdedit.exe" @('/enum', 'firmware', '/v')
    if ($r.Codigo -ne 0) { return }
    $patron = [regex]::Escape("\EFI\$EfiDir\")
    foreach ($bloque in (($r.Salida -join "`n") -split "\n\s*\n")) {
        if ($bloque -notmatch $patron) { continue }
        $m = [regex]::Match($bloque, '\{[0-9a-fA-F-]{36}\}')
        if (-not $m.Success) { continue }
        $g = $m.Value.ToLower()
        if (@($GUID_BOOTMGR, $GUID_FWBOOTMGR) -contains $g) { continue }
        Write-Info (T "Removing firmware entry $g" "Quitando entrada de firmware $g")
        [void](Invoke-Nativo "$env:SystemRoot\System32\bcdedit.exe" @('/delete', $g, '/f'))
    }
}

function New-AccesoDirecto($Meta, [string]$Guid) {
    New-Item -ItemType Directory -Force -Path $DirDatos | Out-Null
    $cmd = Join-Path $DirDatos 'Reiniciar-en-Linux.cmd'
    $contenido = @(
        '@echo off'
        "`"%SystemRoot%\System32\bcdedit.exe`" /set {fwbootmgr} bootsequence $Guid >nul 2>&1"
        'if errorlevel 1 ('
        '  echo Could not schedule the restart. Run this shortcut as administrator.'
        '  echo No se pudo programar el reinicio. Ejecuta este acceso directo como administrador.'
        '  pause'
        '  exit /b 1'
        ')'
        'shutdown /r /t 0'
    ) -join "`r`n"
    [IO.File]::WriteAllText($cmd, $contenido + "`r`n", [Text.Encoding]::ASCII)

    # El nombre del acceso directo es uno solo: segun el idioma de Windows.
    $titulo = if ((Get-UICulture).TwoLetterISOLanguageName -eq 'es') { "Reiniciar en $($Meta.Nombre)" } else { "Restart into $($Meta.Nombre)" }
    $lnk = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) "$titulo.lnk"
    $sh = New-Object -ComObject WScript.Shell
    $sc = $sh.CreateShortcut($lnk)
    $sc.TargetPath = $cmd
    $sc.WorkingDirectory = $DirDatos
    $sc.IconLocation = "$env:SystemRoot\System32\shell32.dll,27"
    $sc.Description = "Restart the PC directly into $($Meta.Nombre) / Reinicia la PC directo en $($Meta.Nombre)"
    $sc.Save()
    # Marca "Ejecutar como administrador" (bit 0x20 del byte 0x15 del .lnk).
    $b = [IO.File]::ReadAllBytes($lnk)
    $b[0x15] = $b[0x15] -bor 0x20
    [IO.File]::WriteAllBytes($lnk, $b)
    return $lnk
}

function Register-Desinstalador($Meta, [long]$Tamano) {
    New-Item -ItemType Directory -Force -Path $DirDatos | Out-Null
    $copia = Join-Path $DirDatos 'Instalar-Linux.ps1'
    if ($PSCommandPath -ne $copia) { Copy-Item -LiteralPath $PSCommandPath -Destination $copia -Force }
    New-Item -Path $RegDesinstalar -Force | Out-Null
    $vals = @{
        DisplayName     = "$($Meta.Nombre) (LinuxOneClick)"
        UninstallString = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$copia`" -Desinstalar"
        DisplayIcon     = "$env:SystemRoot\System32\shell32.dll,27"
        Publisher       = 'LinuxOneClick'
    }
    foreach ($k in $vals.Keys) { New-ItemProperty -Path $RegDesinstalar -Name $k -Value $vals[$k] -PropertyType String -Force | Out-Null }
    New-ItemProperty -Path $RegDesinstalar -Name EstimatedSize -Value ([int]($Tamano / 1KB)) -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $RegDesinstalar -Name NoModify -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $RegDesinstalar -Name NoRepair -Value 1 -PropertyType DWord -Force | Out-Null
}

# ------------------------------------------------------------------ flujos

function Invoke-Analizar {
    $pkg = Resolve-Paquete $Paquete
    $exp = Expand-Paquete $pkg
    try {
        $a = Get-AnalisisImagen $pkg $exp.Meta
        Write-Paso "Package / Paquete: $($exp.Meta.Nombre)"
        Write-Host "Image / Imagen:          $($exp.Meta.Imagen)"
        Write-Host "EFI loader / Cargador:   \EFI\$($exp.Meta.EfiDir)\$($exp.Meta.Loader)  ($([math]::Round((Get-TamanoDirectorio $exp.DirEfi) / 1KB)) KB)"
        $firma = Get-AuthenticodeSignature -LiteralPath (Join-Path $exp.DirEfi $exp.Meta.Loader)
        Write-Host "Shim signature / Firma:  $(if ($firma.SignerCertificate) { $firma.SignerCertificate.Issuer } else { 'none / sin firma' })"
        Write-Host "Sector:                  $($a.Gpt.SectorSize) bytes"
        $a.Gpt.Particiones | Format-Table Indice, Nombre, Tipo, @{ n = 'Offset'; e = { Format-GB $_.Offset } }, @{ n = 'Tamano'; e = { Format-GB $_.Longitud } } -AutoSize | Out-String | Write-Host
        Write-Host "Root / Raiz:             partition / particion $($a.Raiz.Indice), $(Format-GB $a.Raiz.Longitud)"
        Write-Host "File system / Sist. arch.: $($a.Fs.Tipo), label / etiqueta '$($a.Fs.Etiqueta)', UUID $($a.Fs.Uuid), $(Format-GB $a.Fs.Tamano)"
        $min = [Math]::Max($exp.Meta.MinimoGB, [Math]::Ceiling($a.Raiz.Longitud / 1GB) + 2)
        Write-Host "Minimum target size / Tamano minimo: $min GB"
    } finally {
        Remove-Item -LiteralPath $exp.Tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-Instalar {
    if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
        throw (T 'Run the script with 64-bit PowerShell.' 'Ejecuta el script con PowerShell de 64 bits.')
    }
    if ([LocNative]::FirmwareType() -ne 2) {
        throw (T 'This PC does not boot in UEFI mode. This installer is UEFI only.' 'Esta PC no arranca en modo UEFI. Este instalador es solo para UEFI.')
    }
    # Ya instalado: menu (reinstalar / desinstalar / mas espacio). Sin confirmaciones no hay menu.
    $reinstalar = $null
    if (Test-Path $RegEstado) {
        if ($SinConfirmar) {
            throw (T 'LinuxOneClick (EFI) is already installed. Uninstall it first (Settings > Apps, or -Desinstalar).' `
                     'Ya hay una instalacion de LinuxOneClick (EFI). Desinstalala primero (Configuracion > Aplicaciones, o -Desinstalar).')
        }
        switch (Select-OpcionInstalado) {
            'Desinstalar' { Invoke-Desinstalar; return }
            'Espacio'     { Invoke-AmpliarLinux; return }
            'Salir'       { Write-Info (T 'Nothing was changed.' 'No se modifico nada.'); return }
        }
        $reinstalar = Get-ItemProperty -Path $RegEstado
    }

    $pkg = Resolve-Paquete $Paquete
    $exp = Expand-Paquete $pkg
    $meta = $exp.Meta
    $nombre = $meta.Nombre
    try {
        Write-Paso (T "Analyzing the $nombre image" "Analizando la imagen de $nombre")
        $a = Get-AnalisisImagen $pkg $meta
        Write-Info (T "Linux partition: $(Format-GB $a.Raiz.Longitud), $($a.Fs.Tipo), label '$($a.Fs.Etiqueta)'" `
                      "Particion Linux: $(Format-GB $a.Raiz.Longitud), $($a.Fs.Tipo), etiqueta '$($a.Fs.Etiqueta)'")

        # --- Secure Boot
        $sb = Get-EstadoSecureBoot
        if ($sb) {
            $confia = Test-ConfianzaShim (Join-Path $exp.DirEfi $meta.Loader)
            if ($confia -eq $false) {
                throw (T ('Secure Boot is on but this PC does not trust the Microsoft CA that signed the shim (happens on "Secured-core" PCs). ' +
                          'Enable "Microsoft 3rd Party UEFI CA" in the BIOS, or turn Secure Boot off.') `
                         ('Secure Boot esta activo pero esta PC no confia en la CA de Microsoft que firmo el shim (pasa en equipos "Secured-core"). ' +
                          'Habilita "Microsoft 3rd Party UEFI CA" en el BIOS, o desactiva Secure Boot.'))
            }
            Write-Info (T 'Secure Boot: on (compatible).' 'Secure Boot: activo (compatible).')
        } elseif ($sb -eq $false) {
            Write-Info (T 'Secure Boot: off.' 'Secure Boot: desactivado.')
        }

        # --- BitLocker y arranque predeterminado
        # Con BitLocker, arrancar Windows desde GRUB cambia la cadena de arranque que mide el TPM
        # y Windows pide la clave de recuperacion. Por eso en Auto, si esta cifrado, Windows primero.
        $bl = Get-EstadoBitLocker $env:SystemDrive
        $modo = if ($LinuxPorDefecto) { 'Linux' } else { $Arranque }
        if ($modo -eq 'Auto') { $modo = if ($bl.Cifrado) { 'Windows' } else { 'Linux' } }
        $script:LinuxPrimero = ($modo -eq 'Linux')
        if ($bl.Cifrado) {
            Write-Aviso (T "BitLocker / device encryption is on in $env:SystemDrive. Starting Windows from the GRUB menu would ask for the 48-digit recovery key." `
                           "BitLocker / cifrado de dispositivo activo en $env:SystemDrive. Arrancar Windows desde el menu de GRUB pediria la clave de recuperacion de 48 digitos.")
            if ($script:LinuxPrimero) {
                Write-Aviso (T 'Linux first was forced anyway. Save your recovery key before going on: https://aka.ms/myrecoverykey' `
                               'Se forzo Linux primero igual. Guarda tu clave de recuperacion antes de seguir: https://aka.ms/myrecoverykey')
            } else {
                Write-Info (T 'So Windows stays as the default. To enter Linux: desktop shortcut or the BIOS boot menu.' `
                              'Por eso Windows queda como predeterminado. Para entrar a Linux: acceso directo del escritorio o el menu de arranque del BIOS.')
            }
        }

        # --- tamano (al reinstalar se usa el espacio que ya tiene Linux)
        $minimoGB = [Math]::Max($meta.MinimoGB, [int][Math]::Ceiling($a.Raiz.Longitud / 1GB) + 2)
        if ($reinstalar) {
            $hueco = Get-HuecoReinstalacion $reinstalar ([long]$minimoGB * 1GB)
            $necesario = $hueco.Size
        } else {
            $gb = [Math]::Max($TamanoGB, $minimoGB)
            if ($gb -ne $TamanoGB) {
                Write-Aviso (T "The requested size ($TamanoGB GB) is not enough for this image; using $gb GB." "El tamano pedido ($TamanoGB GB) no alcanza para esta imagen; se usan $gb GB.")
            }
            $necesario = [long]$gb * 1GB
        }

        # --- ESP: chequeos sin modificar nada
        $esp = Mount-Esp
        try {
            $destino = "$($esp.Letra):\EFI\$($meta.EfiDir)"
            # Al reinstalar, la carpeta de la instalacion actual (con marcador) se borra antes de copiar.
            $seReemplaza = $reinstalar -and $reinstalar.EfiDir -eq $meta.EfiDir -and [IO.File]::Exists("$destino\$Marcador")
            if ([IO.Directory]::Exists($destino) -and -not $seReemplaza) {
                throw (T "$destino already exists in the EFI partition (another distro with the same loader). It will not be overwritten." `
                         "Ya existe $destino en la particion EFI (otra distro basada en el mismo cargador). No se pisa.")
            }
            $libre = (New-Object IO.DriveInfo "$($esp.Letra):").AvailableFreeSpace
            if ($seReemplaza) { $libre += Get-TamanoDirectorio $destino }
            if ($libre -lt ((Get-TamanoDirectorio $exp.DirEfi) + 1MB)) {
                $mb = [math]::Round($libre / 1MB)
                throw (T "The EFI partition does not have enough space ($mb MB free)." "La particion EFI no tiene espacio suficiente ($mb MB libres).")
            }
        } finally { Dismount-Esp $esp }

        # --- destino
        if ($reinstalar) {
            $t = Format-GB $hueco.Size
            Write-Host ''
            Write-Info (T "Everything in the current Linux will be ERASED, personal files included." `
                          "Se va a BORRAR todo lo que hay en el Linux actual, archivos personales incluidos.") 'Yellow'
            Write-Info (T "$nombre will be installed again in the same space ($t, in a single partition)." `
                          "$nombre se instala de nuevo en el mismo espacio ($t, en una sola particion).") 'White'
        } else {
            Write-Paso (T 'Looking for a drive to make room on (may take a while)' 'Buscando una unidad donde hacer lugar (puede tardar un poco)')
            $cands = @(Get-Candidatos $necesario)
            if ($cands.Count -eq 0) {
                throw (T "No NTFS drive on a GPT disk can give up $gb GB while keeping at least $MargenLibreGB GB free." `
                         "Ninguna unidad NTFS en disco GPT puede ceder $gb GB dejando al menos $MargenLibreGB GB libres.")
            }
            $obj = Select-Candidato $cands

            Write-Host ''
            Write-Info (T "$($obj.Letra): will be shrunk by $gb GB to create a partition for $nombre." `
                          "Se va a reducir $($obj.Letra): en $gb GB y crear una particion para $nombre.") 'White'
        }
        if ($script:LinuxPrimero) {
            Write-Info (T "Default at startup: $nombre (GRUB menu, which also offers Windows)." `
                          "Arranque predeterminado: $nombre (menu de GRUB, que tambien ofrece Windows).")
        } else {
            Write-Info (T 'Default at startup: Windows (Linux from the desktop shortcut or the BIOS boot menu).' `
                          'Arranque predeterminado: Windows (Linux con el acceso directo o el menu de arranque del BIOS).')
        }
        if (-not $SinConfirmar) {
            Write-Host ''
            if (-not (Read-Confirmacion)) { Write-Info (T 'Cancelled. Nothing was changed.' 'Cancelado. No se modifico nada.'); return }
        }

        # --- a partir de aca se modifica el disco
        # (New-Item -Force sobre una clave que ya existe le borra los valores: al reinstalar no se usa.)
        if (-not $reinstalar) { New-Item -Path $RegEstado -Force | Out-Null }
        Set-ItemProperty -Path $RegEstado -Name Estado -Value 'instalando'

        try {
            # Si algo falla desde aca, el catch deshace todo con Invoke-Desinstalar -Automatico.
            if ($reinstalar) { $nueva = Reset-ParticionLinux $reinstalar $hueco }
            else             { $nueva = New-ParticionLinux $obj $necesario }
            Set-ItemProperty -Path $RegEstado -Name Nombre -Value $nombre
            Set-ItemProperty -Path $RegEstado -Name EfiDir -Value $meta.EfiDir
            Set-ItemProperty -Path $RegEstado -Name PartitionGuid -Value $nueva.Guid
            Set-ItemProperty -Path $RegEstado -Name FsTipo -Value $a.Fs.Tipo
            Set-ItemProperty -Path $RegEstado -Name FsUuid -Value $a.Fs.Uuid

            Write-Paso (T "Copying $nombre (a few minutes; do not turn off the PC)" "Copiando $nombre (unos minutos; no apagues la PC)")
            Copy-Imagen $pkg $meta $a $nueva

            Write-Paso (T 'Copying the boot loader to the EFI partition' 'Copiando el cargador a la particion EFI')
            $esp = Mount-Esp
            try { Install-ArchivosEsp $esp $exp $a.Fs } finally { Dismount-Esp $esp }

            Write-Paso (T 'Registering the boot entry' 'Registrando la entrada de arranque')
            $guid = Register-Arranque $meta

            $lnk = New-AccesoDirecto $meta $guid
            Set-ItemProperty -Path $RegEstado -Name AccesoDirecto -Value $lnk
            Register-Desinstalador $meta $necesario
            Set-ItemProperty -Path $RegEstado -Name Estado -Value 'completo'
        } catch {
            $err = $_
            $m = $err.Exception.Message
            Write-Aviso (T "The installation failed: $m" "Fallo la instalacion: $m")
            Write-Aviso (T 'Undoing the changes...' 'Deshaciendo los cambios...')
            try { Invoke-Desinstalar -Automatico } catch {
                $m2 = $_.Exception.Message
                Write-Aviso (T "Could not undo everything: $m2. Run it again with -Desinstalar." "No se pudo deshacer todo: $m2. Volve a correr con -Desinstalar.")
            }
            throw $err
        }

        if ($pkg.Descargado -and -not $ConservarPaquete) { Remove-Item -LiteralPath $pkg.Ruta -Force -ErrorAction SilentlyContinue }

        Write-Paso (T 'Done' 'Listo')
        Write-Info (T "- $nombre starts on the next restart." "- En el proximo reinicio arranca $nombre.")
        if ($script:LinuxPrimero) {
            Write-Info (T '- From then on the GRUB menu comes first and also offers Windows.' '- Desde entonces el menu de GRUB queda primero y tambien ofrece Windows.')
        } else {
            Write-Info (T "- Windows stays as the default. To go back to Linux: desktop shortcut '$([IO.Path]::GetFileNameWithoutExtension($lnk))'" `
                          "- Windows sigue siendo el predeterminado. Para volver a Linux: acceso directo '$([IO.Path]::GetFileNameWithoutExtension($lnk))'")
            Write-Info (T '  or the BIOS boot menu (F12 / F9 / Esc).' '  o el menu de arranque del BIOS (F12 / F9 / Esc).')
        }
        Write-Info (T '- To uninstall: Settings > Apps.' '- Para desinstalar: Configuracion > Aplicaciones.')
        if (-not $SinConfirmar) {
            Write-Host ''
            Write-Host 'Restart now? (y/N)'
            if ((Read-Host 'Reiniciar ahora? (s/N)') -match '^[yYsS]') { Restart-Computer -Force }
        }
    } finally {
        Remove-Item -LiteralPath $exp.Tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Particiones tipo Linux del disco cuyo superbloque btrfs tiene ese fsid
# (las que Linux sumo con "btrfs device add" al encontrar espacio libre).
function Get-ParticionesDelBtrfs([int]$DiskNumber, [string]$FsUuid) {
    $res = @()
    $h = [LocNative]::OpenDisk($DiskNumber, $false)
    try {
        foreach ($p in @(Get-Partition -DiskNumber $DiskNumber | Where-Object { $TIPOS_LINUX -contains $_.GptType })) {
            if ($p.Size -lt $MUESTRA_FS) { continue }
            $buf = New-Object byte[] $MUESTRA_FS
            try { [LocNative]::ReadAt($h, $p.Offset, $buf, $buf.Length) } catch { continue }
            $fs = Get-InfoFs $buf
            if ($fs -and $fs.Tipo -eq 'btrfs' -and $fs.Uuid -eq $FsUuid) { $res += $p }
        }
    } finally { $h.Dispose() }
    return ,$res
}

# Particiones de la instalacion registrada: la original + las que Linux sumo despues (btrfs),
# ordenadas por posicion en el disco.
function Get-ParticionesInstaladas($St) {
    $part = $null
    if ($St.PartitionGuid) {
        $encontradas = @(Get-Partition | Where-Object { $_.Guid -eq $St.PartitionGuid })
        if ($encontradas.Count -eq 1) { $part = $encontradas[0] }
    }
    if ($part -and $TIPOS_LINUX -notcontains $part.GptType) {
        throw (T "Partition $($St.PartitionGuid) is no longer a Linux partition; it will not be touched." `
                 "La particion $($St.PartitionGuid) ya no es de tipo Linux; no se toca.")
    }
    $partes = @()
    if ($part) {
        $partes = @($part)
        if ($St.FsTipo -eq 'btrfs' -and $St.FsUuid) {
            foreach ($p in (Get-ParticionesDelBtrfs $part.DiskNumber $St.FsUuid)) {
                if ($p.Guid -ne $part.Guid) { $partes += $p }
            }
        }
    }
    $total = [long]0; foreach ($p in $partes) { $total += $p.Size }
    return [pscustomobject]@{ Principal = $part; Partes = @($partes | Sort-Object Offset); Total = $total }
}

# La particion que termina justo antes de $Inicio (entre las dos solo puede haber espacio sin asignar).
function Get-ParticionPrevia([int]$DiskNumber, [long]$Inicio) {
    return (Get-Partition -DiskNumber $DiskNumber | Where-Object { ($_.Offset + $_.Size) -le $Inicio } |
            Sort-Object Offset | Select-Object -Last 1)
}

# Unidad de Windows a la que se le puede devolver (o sacar) espacio: la previa, si es NTFS con letra.
function Get-UnidadPrevia($Previa) {
    if (-not $Previa -or -not (Test-Letra $Previa.DriveLetter)) { return $null }
    $vol = Get-Volume -DriveLetter $Previa.DriveLetter -ErrorAction SilentlyContinue
    if (-not $vol -or $vol.FileSystem -ne 'NTFS') { return $null }
    return $vol
}

function Restore-EspacioPrevia($Previa) {
    $l = $Previa.DriveLetter
    Write-Info (T "Giving the space back to $($l):" "Devolviendo el espacio a $($l):")
    $sop = Get-PartitionSupportedSize -DiskNumber $Previa.DiskNumber -PartitionNumber $Previa.PartitionNumber
    Resize-Partition -DiskNumber $Previa.DiskNumber -PartitionNumber $Previa.PartitionNumber -Size $sop.SizeMax
}

# Entradas de arranque y archivos de la ESP de la instalacion registrada.
function Remove-ArranqueInstalado($St) {
    # Entradas de arranque (la nuestra y las que haya creado grub-install desde Linux)
    if ($St.BcdGuid) { [void](Invoke-Nativo "$env:SystemRoot\System32\bcdedit.exe" @('/delete', $St.BcdGuid, '/f')) }
    if ($St.EfiDir) { Remove-EntradasFirmware $St.EfiDir }

    # Archivos en la ESP (solo si tienen nuestro marcador)
    if ($St.EfiDir) {
        $esp = $null
        try {
            $esp = Mount-Esp
            $dir = "$($esp.Letra):\EFI\$($St.EfiDir)"
            if ([IO.File]::Exists("$dir\$Marcador")) {
                Write-Info (T "Deleting $dir" "Borrando $dir")
                [IO.Directory]::Delete($dir, $true)
            } elseif ([IO.Directory]::Exists($dir)) {
                Write-Aviso (T "$dir has no LinuxOneClick marker; it is not deleted." "$dir no tiene el marcador de LinuxOneClick; no se borra.")
            }
        } catch {
            $m = $_.Exception.Message
            Write-Aviso (T "Could not clean the EFI partition: $m" "No se pudo limpiar la particion EFI: $m")
        } finally { Dismount-Esp $esp }
    }
}

function Remove-Particiones([object[]]$Partes) {
    foreach ($p in ($Partes | Sort-Object Offset -Descending)) {
        $t = Format-GB $p.Size
        Write-Info (T "Deleting the Linux partition ($t)" "Borrando la particion Linux ($t)")
        Remove-Partition -DiskNumber $p.DiskNumber -PartitionNumber $p.PartitionNumber -Confirm:$false
    }
    Update-Disk -Number $Partes[0].DiskNumber
}

function Invoke-Desinstalar([switch]$Automatico) {
    if (-not (Test-Path $RegEstado)) {
        Write-Info (T 'There is no LinuxOneClick (EFI) installation registered.' 'No hay ninguna instalacion de LinuxOneClick (EFI) registrada.')
        return
    }
    $st = Get-ItemProperty -Path $RegEstado
    $nombre = if ($st.Nombre) { $st.Nombre } else { 'Linux' }

    $inst = Get-ParticionesInstaladas $st
    $partes = $inst.Partes
    $previa = $null
    $unidad = $null
    if ($partes.Count -gt 0) {
        $previa = Get-ParticionPrevia $partes[0].DiskNumber $partes[0].Offset
        $unidad = Get-UnidadPrevia $previa
    }

    if (-not $Automatico) {
        Write-Host ''
        Write-Info (T "$nombre will be uninstalled." "Se va a desinstalar $nombre.") 'White'
        if ($partes.Count -gt 0) {
            $n = $partes.Count; $d = $partes[0].DiskNumber; $t = Format-GB $inst.Total
            Write-Info (T "$n Linux partition(s) on disk $d ($t in total) will be DELETED with everything in them, personal files included." `
                          "Se borra(n) $n particion(es) Linux del disco $d ($t en total) con todo lo que tienen, archivos personales incluidos.") 'White'
            if ($unidad) {
                Write-Info (T "The space goes back to Windows ($($unidad.DriveLetter):)." "El espacio vuelve a Windows ($($unidad.DriveLetter):).") 'White'
            } else {
                Write-Info (T 'The space will be left unallocated (there is no Windows drive right before Linux); it can be added from Disk Management.' `
                              'El espacio va a quedar sin asignar (no hay una unidad de Windows justo antes de Linux); se puede sumar desde Administracion de discos.') 'White'
            }
        }
        Write-Host ''
        if (-not (Read-Confirmacion)) { Write-Info (T 'Cancelled.' 'Cancelado.'); return }
    }

    # 1 y 2. Entradas de arranque y archivos de la ESP
    Remove-ArranqueInstalado $st

    # 3. Particiones Linux y devolver el espacio a la unidad de Windows de antes
    if ($partes.Count -gt 0) {
        Remove-Particiones $partes
        # SizeMax llega hasta donde el hueco sea contiguo: incluye el espacio sin asignar que haya
        # quedado entre la unidad y Linux. Si entre las particiones borradas habia otra cosa, el resto
        # queda sin asignar.
        if ($unidad) { Restore-EspacioPrevia $previa }
        else {
            Write-Aviso (T 'The space was left unallocated; it can be added to another drive from Disk Management.' `
                           'El espacio quedo sin asignar; se puede sumar a otra unidad desde Administracion de discos.')
        }
    } elseif ($st.PartitionGuid) {
        Write-Aviso (T 'The registered partition no longer exists; skipped.' 'La particion registrada ya no existe; se omite.')
    }

    # 4. Acceso directo, desinstalador y estado
    if ($st.AccesoDirecto -and (Test-Path -LiteralPath $st.AccesoDirecto)) { Remove-Item -LiteralPath $st.AccesoDirecto -Force }
    Remove-Item -Path (Join-Path $DirDatos 'Reiniciar-en-Linux.cmd') -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $RegDesinstalar -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $RegEstado -Recurse -Force
    if (-not $Automatico) {
        Remove-Item -Path (Join-Path $DirDatos 'Instalar-Linux.ps1') -Force -ErrorAction SilentlyContinue
        Write-Paso (T "$nombre uninstalled." "$nombre desinstalado.")
    }
}

# ------------------------------------------------------------------ ya instalado

function Select-OpcionInstalado {
    $st = Get-ItemProperty -Path $RegEstado
    $nombre = if ($st.Nombre) { $st.Nombre } else { 'Linux' }
    Write-Paso (T "$nombre (LinuxOneClick) is already installed." "$nombre (LinuxOneClick) ya esta instalado.")
    Write-Host ''
    Write-Host '  1. Reinstall: erases Linux (personal files included) and installs it again in the same space'
    Write-Host '     Reinstalar: borra Linux (archivos personales incluidos) y lo instala de nuevo en el mismo espacio'
    Write-Host '  2. Uninstall: erases Linux and gives the space back to Windows'
    Write-Host '     Desinstalar: borra Linux y le devuelve el espacio a Windows'
    Write-Host '  3. Give Linux more space (taken from Windows)'
    Write-Host '     Darle mas espacio a Linux (se lo saca a Windows)'
    Write-Host '  4. Exit'
    Write-Host '     Salir'
    do {
        Write-Host ''
        Write-Host 'Choose an option (1-4)'
        $sel = ([string](Read-Host 'Elegi una opcion (1-4)')).Trim()
    } while (@('1', '2', '3', '4') -notcontains $sel)
    switch ($sel) {
        '1' { return 'Reinstalar' }
        '2' { return 'Desinstalar' }
        '3' { return 'Espacio' }
        default { return 'Salir' }
    }
}

# Lugar para reinstalar: todas las particiones de la instalacion actual (tienen que estar juntas)
# mas el espacio sin asignar pegado antes (el que deja "darle mas espacio" si Linux todavia no lo uso).
function Get-HuecoReinstalacion($St, [long]$Minimo) {
    $inst = Get-ParticionesInstaladas $St
    $partes = $inst.Partes
    if ($partes.Count -eq 0) {
        throw (T 'The Linux partition of the current installation was not found. Uninstall it and install again.' `
                 'No se encontro la particion Linux de la instalacion actual. Desinstala y volve a instalar.')
    }
    $disco = $partes[0].DiskNumber
    $ini = $partes[0].Offset
    $fin = [long]0
    foreach ($p in $partes) { $fin = [Math]::Max($fin, $p.Offset + $p.Size) }

    $guids = @($partes | ForEach-Object { $_.Guid })
    $ajenas = @(Get-Partition -DiskNumber $disco | Where-Object {
        $guids -notcontains $_.Guid -and $_.Offset -lt $fin -and ($_.Offset + $_.Size) -gt $ini })
    if ($ajenas.Count -gt 0) {
        throw (T 'There are other partitions between the Linux partitions, so it cannot be reinstalled in place. Uninstall it and install again.' `
                 'Hay otras particiones entre las particiones de Linux; no se puede reinstalar en el lugar. Desinstala y volve a instalar.')
    }

    $previa = Get-ParticionPrevia $disco $ini
    if ($previa) { $ini = [long]([Math]::Ceiling(($previa.Offset + $previa.Size) / 1MB)) * 1MB }
    $tam = [long]([Math]::Floor(($fin - $ini) / 1MB)) * 1MB
    if ($tam -lt $Minimo) {
        throw (T "Linux has $(Format-GB $tam) and this version needs at least $(Format-GB $Minimo). Give Linux more space first (option 3) and try again." `
                 "Linux tiene $(Format-GB $tam) y esta version necesita al menos $(Format-GB $Minimo). Primero dale mas espacio a Linux (opcion 3) y volve a intentar.")
    }
    return [pscustomobject]@{ DiskNumber = $disco; Offset = $ini; Size = $tam; Partes = $partes; Previa = $previa }
}

# Reinstalar: quita arranque y particiones de la instalacion actual y crea una sola particion en su lugar.
function Reset-ParticionLinux($St, $Hueco) {
    Write-Paso (T 'Removing the current installation' 'Quitando la instalacion actual')
    Remove-ArranqueInstalado $St
    Remove-ItemProperty -Path $RegEstado -Name BcdGuid -ErrorAction SilentlyContinue
    if ($St.AccesoDirecto -and (Test-Path -LiteralPath $St.AccesoDirecto)) { Remove-Item -LiteralPath $St.AccesoDirecto -Force }
    Remove-Particiones $Hueco.Partes

    Write-Paso (T 'Creating the Linux partition' 'Creando la particion Linux')
    try {
        $nueva = New-Partition -DiskNumber $Hueco.DiskNumber -Offset $Hueco.Offset -Size $Hueco.Size -GptType $TIPO_LINUX_NUEVA
        $nueva = Get-Partition -DiskNumber $nueva.DiskNumber -PartitionNumber $nueva.PartitionNumber
    } catch {
        $m = $_.Exception.Message
        if (Get-UnidadPrevia $Hueco.Previa) {
            Write-Aviso (T "Could not create the partition ($m)." "No se pudo crear la particion ($m).")
            try { Restore-EspacioPrevia $Hueco.Previa } catch { }
        }
        throw
    }
    Set-ItemProperty -Path $RegEstado -Name PartitionGuid -Value $nueva.Guid
    if (-not $nueva.Guid) { throw (T 'The new partition has no GUID.' 'La particion nueva no tiene GUID.') }
    return $nueva
}

# Achica la unidad de Windows que esta justo antes de Linux. El espacio queda sin asignar pegado a
# Linux y el servicio linuxoneclick lo suma al btrfs en el proximo arranque de Linux.
function Invoke-AmpliarLinux {
    $st = Get-ItemProperty -Path $RegEstado
    $nombre = if ($st.Nombre) { $st.Nombre } else { 'Linux' }
    if ($st.FsTipo -ne 'btrfs') {
        throw (T "$nombre does not use btrfs, so it cannot take more space by itself." `
                 "$nombre no usa btrfs, asi que no puede sumar espacio solo.")
    }
    $inst = Get-ParticionesInstaladas $st
    if ($inst.Partes.Count -eq 0) {
        throw (T 'The Linux partition of the current installation was not found.' 'No se encontro la particion Linux de la instalacion actual.')
    }
    $primera = $inst.Partes[0]
    $previa = Get-ParticionPrevia $primera.DiskNumber $primera.Offset
    $vol = Get-UnidadPrevia $previa
    if (-not $vol) {
        throw (T 'The partition right before Linux is not a Windows drive. Space can only be taken from the drive right before Linux.' `
                 'La particion que esta justo antes de Linux no es una unidad de Windows. Solo se puede sacar espacio de la unidad que esta justo antes de Linux.')
    }
    $letra = [string]$previa.DriveLetter
    $sop = Get-PartitionSupportedSize -DiskNumber $previa.DiskNumber -PartitionNumber $previa.PartitionNumber
    $max = [Math]::Min($previa.Size - $sop.SizeMin - 1MB, $vol.SizeRemaining - [long]$MargenLibreGB * 1GB)
    $maxGB = [int][Math]::Floor([Math]::Max(0, $max) / 1GB)

    Write-Host ''
    Write-Info (T "$($nombre): $(Format-GB $inst.Total).  $($letra): $(Format-GB $vol.SizeRemaining) free." `
                  "$($nombre): $(Format-GB $inst.Total).  $($letra): $(Format-GB $vol.SizeRemaining) libres.")
    if ($maxGB -lt 1) {
        throw (T "$($letra): cannot give more space while keeping at least $MargenLibreGB GB free." `
                 "$($letra): no puede ceder mas espacio dejando al menos $MargenLibreGB GB libres.")
    }
    do {
        Write-Host ''
        Write-Host "How many GB to give Linux? (1-$maxGB, Enter to cancel)"
        $sel = ([string](Read-Host "Cuantos GB darle a Linux? (1-$maxGB, Enter para cancelar)")).Trim()
        if (-not $sel) { Write-Info (T 'Cancelled. Nothing was changed.' 'Cancelado. No se modifico nada.'); return }
        $gb = 0
        $ok = [int]::TryParse($sel, [ref]$gb) -and $gb -ge 1 -and $gb -le $maxGB
    } while (-not $ok)

    Write-Host ''
    Write-Info (T "$($letra): will be shrunk by $gb GB. $nombre takes that space the next time it starts." `
                  "Se va a reducir $($letra): en $gb GB. $nombre toma ese espacio la proxima vez que arranque.") 'White'
    Write-Host ''
    if (-not (Read-Confirmacion)) { Write-Info (T 'Cancelled. Nothing was changed.' 'Cancelado. No se modifico nada.'); return }

    Write-Paso (T "Shrinking $($letra): by $gb GB" "Reduciendo $($letra): en $gb GB")
    Resize-Partition -DiskNumber $previa.DiskNumber -PartitionNumber $previa.PartitionNumber -Size ($previa.Size - [long]$gb * 1GB)
    if (Test-Path $RegDesinstalar) {
        New-ItemProperty -Path $RegDesinstalar -Name EstimatedSize -Value ([int](($inst.Total + [long]$gb * 1GB) / 1KB)) -PropertyType DWord -Force | Out-Null
    }

    Write-Paso (T 'Done' 'Listo')
    Write-Info (T "- $nombre takes the new space the next time it starts." "- $nombre toma el espacio nuevo la proxima vez que arranque.")
    if ($st.BcdGuid) {
        Write-Host ''
        Write-Host "Restart into $nombre now? (y/N)"
        if ((Read-Host "Reiniciar en $nombre ahora? (s/N)") -match '^[yYsS]') {
            Invoke-Bcd @('/set', '{fwbootmgr}', 'bootsequence', $st.BcdGuid) | Out-Null
            Restart-Computer -Force
        }
    }
}

# ------------------------------------------------------------------ inicio

if (-not $SoloAnalizar -and -not (Test-Admin)) {
    # Re-lanzar elevado, con rutas absolutas (el proceso elevado arranca en System32).
    if ($PSBoundParameters.ContainsKey('Paquete') -and $Paquete -notmatch '^https?://') {
        $PSBoundParameters['Paquete'] = (Resolve-Path -LiteralPath $Paquete).Path
    }
    if ($PSBoundParameters.ContainsKey('SieteZip')) { $PSBoundParameters['SieteZip'] = (Resolve-Path -LiteralPath $SieteZip).Path }
    $argumentos = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    foreach ($kv in $PSBoundParameters.GetEnumerator()) {
        if ($kv.Value -is [switch]) { if ($kv.Value.IsPresent) { $argumentos += "-$($kv.Key)" } }
        else { $argumentos += "-$($kv.Key)"; $argumentos += "`"$($kv.Value)`"" }
    }
    if (-not $PausarAlFinal) { $argumentos += '-PausarAlFinal' }
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs -ArgumentList $argumentos
    exit 0
}

# Registro de todo lo que pasa (para soporte): %ProgramData%\LinuxOneClick\registro-*.log
$registro = $null
if (-not $SoloAnalizar) {
    try {
        New-Item -ItemType Directory -Force -Path $DirDatos | Out-Null
        $registro = Join-Path $DirDatos ('registro-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
        Start-Transcript -LiteralPath $registro | Out-Null
    } catch { $registro = $null }
}

$codigo = 0
try {
    switch ($PSCmdlet.ParameterSetName) {
        'Analizar'    { Invoke-Analizar }
        'Desinstalar' { Invoke-Desinstalar }
        default       { Invoke-Instalar }
    }
} catch {
    Write-Host ''
    Write-Lineas $_.Exception.Message 'ERROR: ' '       ' 'Red'
    $codigo = 1
} finally {
    if ($registro) {
        Write-Host ''
        Write-Info (T "Log: $registro" "Registro: $registro")
        try { Stop-Transcript | Out-Null } catch { }
    }
    if ($PausarAlFinal) {
        Write-Host ''
        Write-Host 'Press Enter to close'
        [void](Read-Host 'Presiona Enter para cerrar')
    }
}
exit $codigo
