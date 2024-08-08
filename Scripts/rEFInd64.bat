@echo off
setlocal

echo Buscando tu Particion EFI

rem Estas palabras pueden Variar por Idioma, en caso de que no encuentre Agrega la variante de Sistema en tu Idioma. Esto ejecuta diskpart list volume y busca el efi encontrando la palabra Sistema.
set "keywords=Sistema System"

set "EFI_VOLUME="

for %%k in (%keywords%) do (
    for /f "tokens=2 delims= " %%i in ('echo list volume ^| diskpart ^| findstr /i "%%k"') do (
        set "EFI_VOLUME=%%i"
        goto :found
    )
)

:found
if "%EFI_VOLUME%"=="" (
    echo Lamentablemente no encontre la Particion.
    pause
    exit /b 1
)

echo Volumen encontrado: %EFI_VOLUME%

(
    echo select volume %EFI_VOLUME%
    echo assign letter=S
) | diskpart > nul 2>&1

if %errorlevel% neq 0 (
    echo Error. Al parecer la letra S ya esta en uso en alguna unidad. Desactiva la unidad S y vuelve a ejecutar este script.
    pause
    exit /b %errorlevel%
)

if exist "S:\EFI\refind" (
    rd /s /q "S:\EFI\refind"
)

echo Instalando rEFInd...
xcopy /E /I /Y "C:\MiLinux\refind" "S:\EFI\refind\" > nul 2>&1

if %errorlevel% neq 0 (
    echo Error en la copia. Es probable que la carpeta "C:\MiLinux\refind" no exista.
    goto :hide_partition
)

echo Ajustando para iniciar rEFInd al encender la PC...

rem Usa la ruta completa para bcdedit.exe
C:\Windows\System32\bcdedit.exe /set {bootmgr} path \EFI\refind\refind_x64.efi

if %errorlevel% neq 0 (
    echo Error al ejecutar bcdedit. Intentando con PowerShell...

    powershell -Command "C:\Windows\System32\bcdedit.exe /set '{bootmgr}' path '\EFI\refind\refind_x64.efi'"     

    if %errorlevel% neq 0 (
        echo Error al ejecutar bcdedit a través de PowerShell. 
        goto :hide_partition
    )
)

:hide_partition
(
    echo select volume %EFI_VOLUME%
    echo remove letter=S
) | diskpart > nul 2>&1

if %errorlevel% neq 0 (
    echo Error ocultando particion EFI. 
    pause
    exit /b %errorlevel%
)
echo.
echo ##############################################################
echo #                Instalacion Completa \:D/                   #
echo #              Reiniciar la PC para Probarlo.                #
echo #            Debes tener SecureBoot Desactivado              #
echo #                 Pulsa ENTER para Salir                     #
echo ##############################################################
echo.
timeout /t 3 /nobreak >nul
endlocal
exit /b 0
