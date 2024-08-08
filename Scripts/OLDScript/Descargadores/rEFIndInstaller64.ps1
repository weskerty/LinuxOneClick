# Link de Descarga Directa, se puede Cambiar.
$downloadUrl = "https://master.dl.sourceforge.net/project/linuxoneclick/rEFInd.zip?viasf=1"
$outputFile = "C:\archivo.zip"
$destinationFolder = "C:\"

Write-Output "Descargando Archivo. Esto Tomara Tiempo, Relajate :)"
Start-BitsTransfer -Source $downloadUrl -Destination $outputFile

Write-Output "Descomprimiendo. Esto tomara aun mas Tiempo, Relajate x2 :)"
Expand-Archive -Path "$outputFile" -DestinationPath "$destinationFolder"

Remove-Item $outputFile

Write-Output "Descarga Completada"

Write-Output "Instalando..."
# Ubicacion del Script que se ejecuta al descomprimit.
Start-Process "C:\rEFIndAjustes\Instalar.bat" -NoNewWindow -Wait

Stop-Process -Id $PID
