@echo off
setlocal

echo Buscando particion EFI con nombre ESP o EFI...

for /f "tokens=2 delims= " %%i in ('echo list volume ^| diskpart ^| findstr /i "ESP"') do (
    set EFI_VOLUME=%%i
)

if "%EFI_VOLUME%"=="" (

    for /f "tokens=2 delims= " %%i in ('echo list volume ^| diskpart ^| findstr /i "EFI"') do (
        set EFI_VOLUME=%%i
    )
)

if "%EFI_VOLUME%"=="" (

    for /f "tokens=2 delims= " %%i in ('echo list volume ^| diskpart ^| findstr /i "System"') do (
        set EFI_VOLUME=%%i
    )
)

if "%EFI_VOLUME%"=="" (
    echo No he encontrado una particion EFI. Este script solo funciona en sistemas con EFI
    pause
    exit /b 1
)

echo EFI en: %EFI_VOLUME%

echo select volume %EFI_VOLUME% > diskpart_script.txt
echo assign letter=S >> diskpart_script.txt
diskpart /s diskpart_script.txt

if %errorlevel% neq 0 (
    echo Error al asignar la letra de unidad a la particion EFI.
    pause
    exit /b %errorlevel%
)

del diskpart_script.txt

echo Instalando rEFInd...

xcopy /E /I /Y "C:\LinuxMint\refind" "S:\EFI\refind"

if %errorlevel% neq 0 (
    echo Error en la copia. Intenta abrir desde CMD y no PowerShell...
    pause
    exit /b %errorlevel%
)

echo Ajustando para iniciar rEFInd al encender...

:: Comando para ajustar el Gestor de Inicio. Aqui debes cambiar si tu PC no es x64
bcdedit /set {bootmgr} path \EFI\refind\refind_x64.efi

if %errorlevel% neq 0 (
    echo Error al ejecutar bcdedit. Intenta abrir desde CMD y no PowerShell...
    pause
    exit /b %errorlevel%
)

echo Volviendo EFI como estaba (oculto)...

echo select volume %EFI_VOLUME% > diskpart_script.txt
echo remove letter=S >> diskpart_script.txt
diskpart /s diskpart_script.txt

if %errorlevel% neq 0 (
    echo Error al ocultar la letra en EFI.
    pause
    exit /b %errorlevel%
)

del diskpart_script.txt

echo Instalacion completa, Ahora Reinicia y podras elegir el Sistema a Iniciar.

pause >nul
endlocal
exit /b 0
