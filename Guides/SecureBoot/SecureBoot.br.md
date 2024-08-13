## 🌎 Selecione o idioma;
[![en](https://img.shields.io/badge/English-red.svg)](SecureBoot.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](SecureBoot.br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](SecureBoot.es.md)

# 🔏 O que é SecureBoot?
SecureBoot é um sistema de segurança que impede que programas não certificados sejam iniciados no sistema. <br>
Infelizmente, este script de instalação fácil requer a desativação do SecureBoot.

# 📴 Aqui você tem 2 métodos de desativação;

<details>
<summary>👨‍💻 Desative o SecureBoot do BIOS</summary>
Este método desativa o SecureBoot e permite a execução de todos os tipos de sistemas e aplicativos ao iniciar o PC.<br>
Para desativar o SecureBoot com este método, você deve reiniciar o PC e, quando ele ligar, você deve pressionar a tecla `Setup` que aparece na tela. Geralmente é `F2` `F12` ou `DEL` <br>
Em seguida, use as setas do teclado para pesquisar a seção Sistema, Iniciar, Segurança ou BOOT e o SecureBoot deve aparecer em um submenu, desative-o, salve e reinicie. <br>
Isso varia de acordo com o PC, aqui deixarei alguns exemplos de algumas marcas;

<details>
<summary>Lenovo ThinkPad</summary>
Aqui está um exemplo de vídeo da própria Lenovo;
<video src="https://github.com/user-attachments/assets/1517bb59-abd1-43a2-9a51-0ef32ccd21db">
</details>
<details>
<summary>HP</summary>
Você deve reiniciar o seu PC e quando a tela ligar, pressione rapidamente a tecla 'ESC' e este menu aparecerá <br>
<img src="https://github.com/user-attachments/assets/61ba5f8b-7b1d-4323-94c2-36a757129b33"> <br>
Então você terá que escolher `F10` <br>
Um menu cinza será aberto. Com as setas do teclado você deve ir até a seção "Segurança do Sistema" e selecionar "Opções de Inicialização" <br>
<img src="https://github.com/user-attachments/assets/52cbe76b-4613-430e-840c-bf8828a8ebc8"> <br>
Em seguida, `Enter` no SecureBoot e defina-o como Desativado. <br>
<img src="https://github.com/user-attachments/assets/dc00844f-1067-47c1-afed-32c128222120"> <br>
Agora pressione `F10` ou vá para a seção Salvar e reiniciar. Reinicie e tudo pronto.
</details>

<details>
<summary>Gigabytes</summary>
Você terá que reiniciar e quando ligar, pressione a tecla 'DEL' para exibir o menu. Em seguida, vá para a seção Sistema ou BIOS e selecione SecureBoot <br>
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894" width="350" height="240" /> <br>
Em seguida, selecione SecureBoot, entre e Desative/DESLIGUE. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659" width="350" height="240" /> <br>
Agora vá para Salvar e Reiniciar.


</details>

</details>

<details>
<summary>🔏 Não há necessidade de entrar na BIOS</summary>
Este é um script de instalação semiautomático que instala o YoursBootloader. Requer uma interação única para adicionar uma chave. <br>
O SecureBoot não está desativado aqui. Substitua a chave anterior por uma chave de uso global para que os programas com esta chave possam ser executados. <br>
Isso substitui a pasta BOOT da partição EFI. Isso pode não funcionar em computadores com firmware 2024 e superior.<br>
Baixe aqui; https://github.com/weskerty/rEFIndWindowsInstaller/releases/download/SecureBoot/Yours.exe <br>

Obrigado MLP YoursBootloader; https://github.com/M-L-P/Yours-UEFI

Aqui está um vídeo de demonstração do que você deve fazer;
<img src="https://github.com/user-attachments/assets/3353ca92-bd34-4924-a4ac-e909f78b2662"> <br>
<video src="https://github.com/user-attachments/assets/dbdf15c5-0af3-4857-8837-17f4e27bea10"> <br>

</details>
