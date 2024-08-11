# 🌎 Selecciona Idioma; 
[![en](https://img.shields.io/badge/English-en-red.svg)](Guides/SecureBoot/SecureBoot.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](Guides/SecureBoot/SecureBoot.BR.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](Guides/SecureBoot/SecureBoot.ES.md)

# 🔏 ¿Que es SecureBoot?
SecureBoot es un Sistema de Seguridad la cual evita que programas no certificados puedan arrancar con el Sistema. <br>
Lamentablemente este Script de Instalacion Facil Requiere tener SecureBoot Desactivado. 

# 3️⃣ Aqui tienes 3 Alternativas que Puedes Probar
<details>
<summary>🔏 Sin Necesidad de Entrar a la BIOS</summary>
Esto es un Script de Instalacion SemiAutomatica que Requiere una Interaccion. Esto no desactiva SecureBoot, pero Agrega una Llave de uso Global para que los Programas con esta llave Puedan Ejecutarse. <br>
Se instalara Yours Bootloader, una variante de rEFInd que Reemplaza la carpeta BOOT de la particion EFI, esto puede no Funcionar en Computadoras con Firmware del 2024 y Superior.<br>
Aqui un Video demostrativo de lo que debes Hacer;

Esto Reemplazara la Llave de SecureBoot anterior para permitir la Ejecucion de esta Llave/Certificado.

</details>

<details>
<summary>👨‍💻 Desactivar SecureBoot desde BIOS</summary>
La mejor Opcion, Permite la Ejecucion de todo tipo de Sistemas y Aplicaciones al Iniciar la PC.<br>
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
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894"> <br>
Luego seleccionar SecureBoot, enter y Disable/OFF. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659"> <br>
Ahora ir a Guardar y Reiniciar.


</details>

</details>



<details>
<summary>Instalar Linux Manualmente</summary>

</details>
