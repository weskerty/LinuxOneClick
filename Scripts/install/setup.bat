@echo off
set runparms=AutoInstall Quiet Shortcut=No  
cls
set rundir="%~dp0"
echo Instalando Grub2Win 
start /wait "" "%rundir%winsource\grub2win.exe" %runparms%
echo Completado
timeout /t 3 /nobreak >nul
exit
