@echo off
setlocal enabledelayedexpansion

set vhdPath=%~dp0Cosas\MiLinux.vhd
set oldVhdPath=%vhdPath%.vtoy

if exist "%oldVhdPath%" ren "%oldVhdPath%" MiLinux.vhd

if not exist "%vhdPath%" (
    exit /b 1
)

set /p gbAdd="Nuevo Tamano Total en GB - New Total Size in GB; "

set /a sizeMB=%gbAdd%*1024

(
echo select vdisk file="%vhdPath%"
echo expand vdisk maximum=%sizeMB%
) | diskpart

if %errorlevel% neq 0 (
    ren "%vhdPath%" MiLinux.vhd.vtoy
    exit /b 1
)

ren "%vhdPath%" MiLinux.vhd.vtoy

echo.
echo Nuevo Tamano %gbAdd% GB Recuerda Aumentarlo en la Aplicacion Discos Linux.
echo New Size %gbAdd% GB Remember to Increase it in the Linux Disks Application.
echo Novo tamanho %gbAdd% GB Lembre-se de aumenta-lo no aplicativo Linux Disks.
pause
