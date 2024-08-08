@echo off
setlocal

bcdedit | findstr /i "EFI" > nul 2>&1

if %errorlevel% equ 0 (
    echo Tu PC parece estar en UEFI. Comienza la Descarga.
    
    rem URL de Descarga Instalador, se puede cambiar.
    set "downloadUrl=https://master.dl.sourceforge.net/project/linuxoneclick/rEFInd.zip?viasf=1"
    set "outputFile=C:\archivo.zip"
    set "destinationFolder=C:\"

    echo Descargando Archivo. Esto Tomara Tiempo, Relajate :)

    bitsadmin /transfer DescargaMint /download /priority high /DYNAMIC %downloadUrl% %outputFile%

    if %errorlevel% neq 0 (
        echo Error en la descarga.
        pause
        exit /b %errorlevel%
    )

    echo Descomprimiendo. Esto tomara aun mas Tiempo, Relajate x2 :)

    rem Descomprimir con tar, Funciona en W10 y Superior.
    tar -xf %outputFile% -C %destinationFolder%

    if %errorlevel% neq 0 (
        echo Error en la descompresion.
        pause
        exit /b %errorlevel%
    )

    del %outputFile%

    echo Instalando...
    rem Ubicacion del Script que se ejecuta al descomprimir.
    call "C:\rEFIndAjustes\Instalar.bat"
    
    exit /b 0
) else (
    echo Tu sistema no parece estar en UEFI.
    echo Este script esta diseñado para sistemas UEFI unicamente.
    pause
    exit /b 1
)

endlocal
exit /b 0
