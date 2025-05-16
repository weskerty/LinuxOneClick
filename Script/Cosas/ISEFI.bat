@echo off
setlocal EnableDelayedExpansion

echo Detectando tipo de Sistema...
echo Detecting System Type...

REM Verificar UEFI
bcdedit | find ".efi" > nul
if not errorlevel 1 (
    echo Es UEFI
    
    REM Verificar SecureBoot
    powershell -Command "$result = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue; if ($null -eq $result) { exit 2 } else { Write-Host $result; exit [int](!$result) }" >nul 2>&1
    
    if !errorlevel! equ 1 (
        cls
        echo #############################
        echo #Tu Sistema Tiene SecureBoot#
		echo ###Tienes que Desactivarlo###
        echo #############################
        timeout /t 10 >nul
    ) else if !errorlevel! equ 0 (
        echo Secure Boot: OFF
    ) else (
        echo SCF
    )
    
    echo Instalando rEFInd...
    call %~dp0rEFInd64.bat
) else (
    echo Es BIOS
    echo Instalando Grub2Win...
    call %~dp0Grub2Win\setup.bat
)

endlocal







REM @echo off
REM setlocal

REM set "msinfoFile=%~dp0MiInfo.txt"

REM rem msinfo32.exe hace todo un informe cuando solo necesito la palabra uefi, si encuentras otra opcion menos invasiva avisa para cambiarlo.
REM echo Detectando tipo de Sistema...
REM echo Detecting System Type...
REM start /wait msinfo32.exe /report "%msinfoFile%"

REM find /i "UEFI" "%msinfoFile%" >nul
REM if not errorlevel 1 (
    REM echo Es UEFI, Instalando rEFInd
    REM call %~dp0rEFInd64.bat
REM ) else (
    REM echo Es BIOS, Instalando Grub2Win
    REM call %~dp0Grub2Win\setup.bat
REM )

REM endlocal
