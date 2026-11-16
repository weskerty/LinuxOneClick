<#
.SYNOPSIS
    Arma el paquete .7z que usa Instalar-Linux.ps1, a partir del VHD preparado en la VM.

.DESCRIPTION
    - Verifica que el VHD sea de tamano fijo (o que sea una imagen .img cruda).
    - Monta el VHD en solo lectura y copia EFI\<EfiDir> de su ESP (o usa -DirEfi).
    - Escribe paquete.json y comprime todo con -ms=off (no solido), asi el instalador
      puede sacar los archivos chicos sin descomprimir la imagen entera.

.EXAMPLE
    .\Crear-Paquete.ps1 -Imagen ..\Cosas\Mint.vhd.vtoy -Salida D:\Mint.7z -Nombre "Linux Mint 22.2"
.EXAMPLE
    .\Crear-Paquete.ps1 -Imagen D:\arch.img -DirEfi D:\efi-arch -EfiDir arch -Salida D:\Arch.7z -Nombre "Arch Linux"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$Imagen,
    [Parameter(Mandatory = $true)] [string]$Salida,
    [string]$Nombre = 'Linux Mint',
    [string]$EfiDir = 'ubuntu',
    [string]$Loader = 'shimx64.efi',
    [string]$DirEfi,
    [string]$PrefijoGrub,          # por defecto: se lee del grub.cfg de la ESP del VHD (/boot/grub o /@/boot/grub en btrfs)
    [int]$MinimoGB = 30,
    [ValidateRange(0, 9)] [int]$Compresion = 5,
    [string]$SieteZip
)

$ErrorActionPreference = 'Stop'
if (-not $SieteZip) { $SieteZip = Join-Path $PSScriptRoot '7za.exe' }
if (-not (Test-Path -LiteralPath $SieteZip)) { throw "No se encontro 7-Zip en '$SieteZip'." }
$TIPO_ESP = '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

function Copy-Directorio([string]$Origen, [string]$Destino) {
    [IO.Directory]::CreateDirectory($Destino) | Out-Null
    foreach ($f in [IO.Directory]::GetFiles($Origen)) { [IO.File]::Copy($f, [IO.Path]::Combine($Destino, [IO.Path]::GetFileName($f)), $true) }
    foreach ($d in [IO.Directory]::GetDirectories($Origen)) { Copy-Directorio $d ([IO.Path]::Combine($Destino, [IO.Path]::GetFileName($d))) }
}

$Imagen = (Resolve-Path -LiteralPath $Imagen).Path
$Salida = [IO.Path]::GetFullPath($Salida)

# --- tipo de imagen
$fs = [IO.File]::OpenRead($Imagen)
try {
    $ini = New-Object byte[] 8; [void]$fs.Read($ini, 0, 8)
    $pie = New-Object byte[] 512; $fs.Position = $fs.Length - 512; [void]$fs.Read($pie, 0, 512)
} finally { $fs.Dispose() }
if ([Text.Encoding]::ASCII.GetString($ini) -eq 'conectix') {
    throw 'El VHD es dinamico. Convertilo a fijo: VBoxManage clonemedium disk origen.vhd destino.vhd --format VHD --variant Fixed'
}
$esVhd = [Text.Encoding]::ASCII.GetString($pie, 0, 8) -eq 'conectix'
if ($esVhd) {
    $tipoDisco = [BitConverter]::ToUInt32([byte[]]($pie[63], $pie[62], $pie[61], $pie[60]), 0)   # big-endian
    if ($tipoDisco -ne 2) { throw "El VHD no es de tamano fijo (tipo $tipoDisco)." }
}

$staging = Join-Path $env:TEMP ('lo1c-paquete-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$destEfi = Join-Path $staging "EFI\$EfiDir"
New-Item -ItemType Directory -Force -Path $destEfi | Out-Null

try {
    # --- archivos EFI
    if ($DirEfi) {
        Copy-Directorio (Resolve-Path -LiteralPath $DirEfi).Path $destEfi
    } else {
        if (-not $esVhd) { throw 'Windows no puede montar una imagen .img cruda: pasa los archivos EFI con -DirEfi.' }
        $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Para montar el VHD hace falta ejecutar como administrador (o usar -DirEfi).' }

        # Mount-DiskImage elige el formato por extension: si no es .vhd, se monta a traves de un hardlink.
        $montar = $Imagen
        $enlace = $null
        if ([IO.Path]::GetExtension($Imagen) -ne '.vhd') {
            $enlace = "$Imagen.montaje-temporal.vhd"
            New-Item -ItemType HardLink -Path $enlace -Target $Imagen | Out-Null
            $montar = $enlace
        }
        try {
            $di = Mount-DiskImage -ImagePath $montar -Access ReadOnly -NoDriveLetter -PassThru
            try {
                $disco = $di | Get-Disk
                $esp = @(Get-Partition -DiskNumber $disco.Number | Where-Object { $_.GptType -eq $TIPO_ESP })
                if ($esp.Count -ne 1) { throw "Se esperaba una ESP dentro del VHD y hay $($esp.Count)." }
                $esp[0] | Add-PartitionAccessPath -AssignDriveLetter
                $esp = Get-Partition -DiskNumber $disco.Number -PartitionNumber $esp[0].PartitionNumber
                $origen = "$($esp.DriveLetter):\EFI\$EfiDir"
                for ($i = 0; $i -lt 20 -and -not [IO.Directory]::Exists($origen); $i++) { Start-Sleep -Milliseconds 250 }
                if (-not [IO.Directory]::Exists($origen)) { throw "No existe $origen dentro del VHD." }
                Copy-Directorio $origen $destEfi
            } finally {
                Dismount-DiskImage -ImagePath $montar | Out-Null
            }
        } finally {
            if ($enlace) { Remove-Item -LiteralPath $enlace -Force }
        }
    }

    # grub.cfg del VM (busca por UUID) no hace falta: el instalador escribe uno por etiqueta.
    # Antes de borrarlo se lee la ruta de GRUB dentro de la raiz (cambia con subvolumenes btrfs).
    $cfgVm = Join-Path $destEfi 'grub.cfg'
    if (-not $PrefijoGrub -and (Test-Path -LiteralPath $cfgVm)) {
        $m = [regex]::Match((Get-Content -Raw -LiteralPath $cfgVm), "set prefix=\(\`$root\)'?([^'\s]+)'?")
        if ($m.Success) { $PrefijoGrub = $m.Groups[1].Value }
    }
    if (-not $PrefijoGrub) {
        $PrefijoGrub = '/boot/grub'
        Write-Warning "No se pudo leer la ruta de GRUB; se usa $PrefijoGrub (con btrfs suele ser /@/boot/grub: pasala con -PrefijoGrub)."
    }
    Write-Host "Ruta de GRUB en la raiz: $PrefijoGrub"
    Remove-Item -LiteralPath $cfgVm -Force -ErrorAction SilentlyContinue
    foreach ($f in $Loader, 'grubx64.efi', 'mmx64.efi') {
        if (-not (Test-Path -LiteralPath (Join-Path $destEfi $f))) { Write-Warning "Falta EFI\$EfiDir\$f" }
    }
    $firma = Get-AuthenticodeSignature -LiteralPath (Join-Path $destEfi $Loader) -ErrorAction SilentlyContinue
    if ($firma -and $firma.SignerCertificate) { Write-Host "Shim firmado por: $($firma.SignerCertificate.Issuer)" }
    else { Write-Warning 'El shim no tiene firma Authenticode: no va a arrancar con Secure Boot.' }

    # --- paquete.json
    $meta = [ordered]@{
        nombre      = $Nombre
        imagen      = [IO.Path]::GetFileName($Imagen)
        efiDir      = $EfiDir
        loader      = $Loader
        prefijoGrub = $PrefijoGrub
        minimoGB    = $MinimoGB
    }
    $meta | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $staging 'paquete.json') -Encoding ASCII

    # --- comprimir
    if (Test-Path -LiteralPath $Salida) { Remove-Item -LiteralPath $Salida -Force }
    Write-Host "Comprimiendo (puede tardar bastante)..."
    Push-Location $staging
    try {
        & $SieteZip a -t7z "-mx=$Compresion" -ms=off -mmt=on $Salida 'paquete.json' 'EFI' $Imagen
        if ($LASTEXITCODE -ne 0) { throw "7-Zip termino con codigo $LASTEXITCODE." }
    } finally { Pop-Location }

    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Salida).Hash
    Write-Host "`nPaquete: $Salida"
    Write-Host "SHA256:  $hash"
} finally {
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
}
