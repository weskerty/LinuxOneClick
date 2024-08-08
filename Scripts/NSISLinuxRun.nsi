OutFile "MiLinuxVDI.exe"
Icon "F:\Documentos\LinuxMint\ICO\MintIcon.ico"
RequestExecutionLevel admin
InstallDir "C:\MiLinux\"
Name "LinuxVDI"

Section "MainSection" SEC01
    CreateDirectory "$INSTDIR"
    SetOutPath "$INSTDIR"
    
    SetCompress off
    File "F:\Documentos\LinuxMint\MiLinux\MiLinuxZip\MiLinuxVDI.zip"
    File "F:\Documentos\LinuxMint\MiLinux\MiLinuxZip\7za.exe" 
    
    ExecWait '"$INSTDIR\7za.exe" x "$INSTDIR\MiLinuxVDI.zip" -o"$INSTDIR" -y'
    
    Delete "$INSTDIR\MiLinuxVDI.zip"
    Delete "$INSTDIR\7za.exe"
    ExecWait '"$WINDIR\SysNative\cmd.exe" /c "$INSTDIR\ISEFI.bat"'
	
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    Quit
SectionEnd

Section "Uninstall"
    ExecWait '"$WINDIR\SysNative\cmd.exe" /c "$INSTDIR\UnIsl.bat"'
    RMDir /r "$INSTDIR"
    ExecShell "open" "https://github.com/weskerty/LinuxOneClick/issues/new"
SectionEnd
