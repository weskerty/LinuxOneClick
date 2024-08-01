# Link de Descarga Directa, se puede Cambiar.
$downloadUrl = "https://razaoinfo.dl.sourceforge.net/project/linuxoneclick/LOClicK.zip?viasf=1"
$outputFile = "C:\archivo.zip"
$destinationFolder = "C:\"

Write-Output "Descargando Archivo. Esto Tomara Tiempo, Relajate :)"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile

Write-Output "Descomprimiendo. Esto tomara aun mas Tiempo, Relajate x2 :)"
Expand-Archive -Path "$outputFile" -DestinationPath "$destinationFolder"

Remove-Item $outputFile

Write-Output "Descarga Completada"

Write-Output "Instalando..."
# Ubicacion del Script que se ejecuta al descomprimit.
Start-Process "C:\LinuxMint\Instalar.bat" -NoNewWindow -Wait

Stop-Process -Id $PID
