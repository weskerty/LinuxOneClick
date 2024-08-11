# 🌎 Select Language;
[![en](https://img.shields.io/badge/English-en-red.svg)](SecureBoot.md)
[![pt-br](https://img.shields.io/badge/Português-pt--br-green.svg)](SecureBoot.BR.md)
[![es](https://img.shields.io/badge/Espa%C3%B1ol-es-yellow.svg)](SecureBoot.ES.md)

# 🔏 What is SecureBoot?
SecureBoot is a Security System which prevents non-certified programs from starting with the System. <br>
Unfortunately this Easy Installation Script Requires having SecureBoot Disabled.

#3️⃣ Here are 3 Alternatives You Can Try
<details>
<summary>🔏 No need to enter the BIOS</summary>
This is a Semi-Automatic Installation Script that Requires Interaction. This does not disable SecureBoot, but adds a globally used key so that programs with this key can run. <br>
Yours Bootloader will be installed, a variant of rEFInd that Replaces the BOOT folder of the EFI partition, this may not work on Computers with Firmware of 2024 and Higher.<br>
Here is a demonstration video of what you should do;

This will replace the previous SecureBoot Key to allow this Key/Certificate to be executed.

</details>

<details>
<summary>👨‍💻 Disable SecureBoot from BIOS</summary>
The best option, it allows the execution of all types of systems and applications when starting the PC.<br>
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
You must restart and when it turns on, press the 'DEL' key to display the menu. Then go to the System or BIOS Section and Select SecureBoot <br>
<img src="https://github.com/user-attachments/assets/284ecb93-4284-42af-b042-0a15faf6a894"> <br>
Then select SecureBoot, enter and Disable/OFF. <br>
<img src="https://github.com/user-attachments/assets/cbff9304-1fb4-455f-9808-a8ccc3c93659"> <br>
Now go to Save and Restart.


</details>

</details>



<details>
<summary>Install Linux Manually</summary>

</details>
