!include x64.nsh

OutFile "MiLinux.exe"
Icon "F:\Documentos\LinuxMint\ICO\MintIcon.ico"
RequestExecutionLevel highest
InstallDir "C:\MiLinux\"
Name "Mi Linux VHD"

Section "MainSection" SEC01
	CreateDirectory "$INSTDIR"
	SetOutPath "$INSTDIR"
	
	SetCompress off
	File "F:\Documentos\LinuxMint\MiLinux\MiLinuxZip\MiLinux.7z"
	File "F:\Documentos\LinuxMint\MiLinux\MiLinuxZip\7za.exe"
	
	ExecWait '"$INSTDIR\7za.exe" x "$INSTDIR\MiLinux.7z" -o"$INSTDIR" -y'
	
	Delete "$INSTDIR\MiLinuxVDI.7z"
	Delete "$INSTDIR\7za.exe"
	
	${If} ${RunningX64}
		; Si es 64 bits requiere usarse SysNative o el comando bcdedit fallara.
		ExecWait '"$WINDIR\SysNative\cmd.exe" /c "$INSTDIR\ISEFI.bat"'
	${Else}
		; En 32bits usa el cmd predeterminado
		ExecWait '"$WINDIR\System32\cmd.exe" /c "$INSTDIR\ISEFI.bat"'
	${EndIf}
	
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	MessageBox MB_OK "Finalizado, puedes Reiniciar. Finalized. You can Restart."

	Quit
SectionEnd

Section "Uninstall"
	${If} ${RunningX64}
		ExecWait '"$WINDIR\SysNative\cmd.exe" /c "$INSTDIR\UnIsl.bat"'
	${Else}
		ExecWait '"$WINDIR\System32\cmd.exe" /c "$INSTDIR\UnIsl.bat"'
	${EndIf}
	
	RMDir /r "$INSTDIR"
	ExecShell "open" "https://github.com/weskerty/LinuxOneClick/issues/new"
SectionEnd
