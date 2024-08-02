@echo off
setlocal

echo Buscando Tu Particion EFI...

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
    echo No he encontrado una particion EFI. rEFInd solo funciona con Sistemas UEFI. No te preocupes, aun puedes Instalar Linux de Otra Manera, con Grub por ejemplo.
    pause
    exit /b 1
)

echo EFI en: %EFI_VOLUME%

(
    echo select volume %EFI_VOLUME%
    echo assign letter=S
) | diskpart > nul 2>&1

if %errorlevel% neq 0 (
    echo Error. Al Parecer la letra S ya esta en uso en alguna Unidad. Desactiva la Unidad S y Vuelve a Ejecutar este Script.
    pause
    exit /b %errorlevel%
)

if exist "S:\EFI\refind" (
    rd /s /q "S:\EFI\refind"
)

echo Instalando rEFInd...

xcopy /E /I /Y "C:\LinuxMint\refind" "S:\EFI\refind" > nul 2>&1

if %errorlevel% neq 0 (
    echo Error en la copia. Intenta abrir desde CMD como Administrador y no en PowerShell...
    pause
    exit /b %errorlevel%
)

echo Ajustando para iniciar rEFInd al encender la PC...

:: Comando para ajustar el Gestor de Inicio. Aqui debes cambiar si tu PC no es x64, pero Debes descargar la Version de rEFInd correspondiente Manualmente.
bcdedit /set {bootmgr} path \EFI\refind\refind_x64.efi > nul 2>&1

if %errorlevel% neq 0 (
    echo Error al ejecutar bcdedit. Intenta abrir desde CMD como Administrador y no en PowerShell...
    pause
    exit /b %errorlevel%
)

echo Volviendo Particion EFI como estaba (oculto)...

(
    echo select volume %EFI_VOLUME%
    echo remove letter=S
) | diskpart > nul 2>&1

if %errorlevel% neq 0 (
    echo Error ocultando particion EFI. Lamentablemente veras una Nueva unidad en el Inicio, Desde Ahi Puedes instalar rEFInd Manualmente moviendo la Carpeta a EFI/EFI. NO BORRES NADA DE ESA UNIDAD O TU PC YA NO ENCENDERA.
    pause
    exit /b %errorlevel%
)

echo.
echo ##############################################################
echo #                Instalacion Completa \:D/                   #
echo #              Reiniciar la PC para Probarlo.                #
echo #                                                            #
echo #                 Pulsa ENTER para Salir                     #
echo ##############################################################
echo.

pause >nul
endlocal
exit /b 0
