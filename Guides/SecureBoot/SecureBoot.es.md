## 🌎 Select Language;
[![en](https://img.shields.io/badge/English-red.svg)](SecureBoot.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](SecureBoot.br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](SecureBoot.es.md)

# 🔏 ¿Que es SecureBoot?
SecureBoot es un Sistema de Seguridad la cual evita que programas no certificados puedan arrancar con el Sistema. <br>
Lamentablemente este Script de Instalacion Facil Requiere tener SecureBoot Desactivado. 

# 📴 Aqui Tienes 2 Metodos de Desactivacion;

<details>
<summary>👨‍💻 Desactivar SecureBoot desde BIOS</summary>
Este metodo Desactiva SecureBoot y Permite la Ejecucion de todo tipo de Sistemas y Aplicaciones al Iniciar la PC.<br>
Para Desactivar SecureBoot con este metodo Deberas Reiniciar la PC, y cuando enciende Deberas Pulsar la Tecla `Setup` que aparece en Pantalla. Suele ser `F2` `F12` o `DEL` <br>
Luego Buscar a travez de las flechas del teclado la Seccion Sistema, Inicio, Seguridad o BOOT y en un Sub Menu debe aparecer SecureBoot, ajustarlo a apagado, guardar y reiniciar. <br>
Esto varia por PC, Aqui dejare unos Ejemplos de algunas marcas;
  
<details>
<summary>Lenovo ThinkPad</summary> 
Aqui un Ejemplo en Video de la Propia Lenovo;
<video src="https://github.com/user-attachments/assets/1517bb59-abd1-43a2-9a51-0ef32ccd21db">
</details>
<details>
<summary>HP</summary>
Deberas Reiniciar tu PC y cuando encienda la pantalla pulsar Rapidamente la tecla `ESC` y aparecera este menu <br>
<img src="https://github.com/user-attachments/assets/61ba5f8b-7b1d-4323-94c2-36a757129b33"> <br>
Luego Tendras que Elegir `F10` <br>
Se Abrira un menu gris. Con las Flechitas del teclado Deberas ir a la Seccion "Seguridad del Sistema" y seleccionar "Opciones de Inicio" <br>
<img src="https://github.com/user-attachments/assets/52cbe76b-4613-430e-840c-bf8828a8ebc8"> <br>
Luego `Enter` en SecureBoot y Ajustarlo a Desactivado. <br>
<img src="https://github.com/user-attachments/assets/dc00844f-1067-47c1-afed-32c128222120"> <br>
Ahora Pulsa `F10` o ir hasta la Seccion Guardar y Reiniciar. Reinicia y Todo Listo.
</details>

<details>
<summary>Gigabyte</summary>
Deberas Reiniciar y cuando esta enciende pulsar la tecla `DEL` para mostrar el menu. Luego ir a la Seccion Sistema o BIOS y Seleccionar SecureBoot <br>
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894" width="350" height="240" /> <br>
Luego seleccionar SecureBoot, enter y Disable/OFF. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659" width="350" height="240" /> <br>
Ahora ir a Guardar y Reiniciar.


</details>

</details>

<details>
<summary>🔏 Sin Necesidad de Entrar a la BIOS</summary>
Esto es un Script de Instalacion SemiAutomatica que Instala YoursBootloader. Requiere una Interaccion de una sola vez para Agregar una Llave. <br>
Aqui no se desactiva SecureBoot, Reemplaza la Llave Anterior con una Llave de uso Global para que los Programas con esta llave Puedan Ejecutarse. <br>
Esto Reemplaza la carpeta BOOT de la particion EFI, esto puede no Funcionar en Computadoras con Firmware del 2024 y Superior.<br>
Descargalo de Aqui; https://github.com/weskerty/rEFIndWindowsInstaller/releases/download/SecureBoot/Yours.exe <br>

Agradecimiento MLP YoursBootloader; https://github.com/M-L-P/Yours-UEFI

Aqui un Video demostrativo de lo que debes Hacer;
<img src="https://github.com/user-attachments/assets/3353ca92-bd34-4924-a4ac-e909f78b2662"> <br>
<video src="https://github.com/user-attachments/assets/dbdf15c5-0af3-4857-8837-17f4e27bea10"> <br>

</details>
