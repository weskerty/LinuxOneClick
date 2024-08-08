@echo off
setlocal

set "infoFile=C:\MiLinux\MiInfo.txt"

find /i "UEFI" "%infoFile%" >nul

if %errorlevel% equ 0 (
    echo Des rEFInd
    cmd /c "bcdedit /set {bootmgr} path \EFI\Microsoft\Boot\bootmgfw.efi"
    
    if %errorlevel% neq 0 (
        echo Error bcdedit
        powershell -Command "C:\Windows\System32\bcdedit.exe /set '{bootmgr}' path '\EFI\Microsoft\Boot\bootmgfw.efi'"
        
        if %errorlevel% neq 0 (
            echo error PowerShell.
        )
    )
) else (
    echo Des Grub2Win
    start /wait  C:\grub2\grub2win.exe Uninstall Quiet
)

endlocal
