## 🌎 Select Language;
[![en](https://img.shields.io/badge/English-red.svg)](SecureBoot.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](SecureBoot.br.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](SecureBoot.es.md)

# 🔏 What is SecureBoot?
SecureBoot is a Security System which prevents non-certified programs from starting with the System. <br>
Unfortunately this Easy Installation Script Requires having SecureBoot Disabled.

# 📴 Here You Have 2 Deactivation Methods;

<details>
<summary>👨‍💻 Disable SecureBoot from BIOS</summary>
This method Disables SecureBoot and Allows the Execution of all types of Systems and Applications when Starting the PC.<br>
To Deactivate SecureBoot with this method, you must restart the PC, and when it turns on, you must press the `Setup` key that appears on the screen. This is usually `F2` `F12` or `DEL` <br>
Then use the keyboard arrows to search for the System, Start, Security or BOOT Section and SecureBoot should appear in a Sub Menu, set it to off, save and restart. <br>
This varies by PC, here I will leave some examples of some brands;

<details>
<summary>Lenovo ThinkPad</summary>
Here is a Video Example from Lenovo Itself;
<video src="https://github.com/user-attachments/assets/1517bb59-abd1-43a2-9a51-0ef32ccd21db">
</details>
<details>
<summary>HP</summary>
You should restart your PC and when the screen turns on, quickly press the 'ESC' key and this menu will appear <br>
<img src="https://github.com/user-attachments/assets/61ba5f8b-7b1d-4323-94c2-36a757129b33"> <br>
Then you will have to choose `F10` <br>
A gray menu will open. With the Arrows on the keyboard you must go to the "System Security" Section and select "Startup Options" <br>
<img src="https://github.com/user-attachments/assets/52cbe76b-4613-430e-840c-bf8828a8ebc8"> <br>
Then `Enter` in SecureBoot and Set it to Disabled. <br>
<img src="https://github.com/user-attachments/assets/dc00844f-1067-47c1-afed-32c128222120"> <br>
Now Press `F10` or go to the Save and Restart Section. Reboot and Everything Ready.
</details>

<details>
<summary>Gigabyte</summary>
You will have to restart and when it turns on, press the 'DEL' key to display the menu. Then go to the System or BIOS Section and Select SecureBoot <br>
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894" width="350" height="240" /> <br>
Then select SecureBoot, enter and Disable/OFF. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659" width="350" height="240" /> <br>
Now go to Save and Restart.


</details>

</details>

<details>
<summary>🔏 No need to enter the BIOS</summary>
This is a Semi-Automatic Installation Script that Installs YoursBootloader. Requires a one-time Interaction to Add a Key. <br>
SecureBoot is not deactivated here, Replace the Previous Key with a Global Use Key so that Programs with this key Can Run. <br>
This Replaces the BOOT folder of the EFI partition, this may not work on Computers with Firmware 2024 and Higher.<br>
Download it from Here; https://github.com/weskerty/rEFIndWindowsInstaller/releases/download/SecureBoot/Yours.exe <br>

Thanks MLP YoursBootloader; https://github.com/M-L-P/Yours-UEFI

Here is a demonstration video of what you should do;
<img src="https://github.com/user-attachments/assets/3353ca92-bd34-4924-a4ac-e909f78b2662"> <br>
<video src="https://github.com/user-attachments/assets/dbdf15c5-0af3-4857-8837-17f4e27bea10"> <br>

</details>
