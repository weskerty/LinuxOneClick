@echo off
setlocal

set "msinfoFile=C:\MiLinux\MiInfo.txt"

rem msinfo32.exe hace todo un informe cuando solo necesito la palabra uefi, si encuentras otra opcion menos invasiva avisa para cambiarlo.
echo Detectando tipo de Sistema...
echo Detecting System Type...
start /wait msinfo32.exe /report "%msinfoFile%"

find /i "UEFI" "%msinfoFile%" >nul
if not errorlevel 1 (
    echo Es UEFI, Instalando rEFInd
    call C:\MiLinux\rEFInd64.bat
) else (
    echo Es BIOS, Instalando Grub2Win
    call C:\MiLinux\install\setup.bat
)

endlocal
