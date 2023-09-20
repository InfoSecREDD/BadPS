# BadPS - BadPowerShell
**BadUSB Payload Development Launcher**


![Static Badge](https://img.shields.io/badge/Built_with-PowerShell-orange) ![Static Badge](https://img.shields.io/badge/Windows_10-Supported-lime) ![Static Badge](https://img.shields.io/badge/Windows_11-Supported-lime)
##

This tool was created to give people the ability to develop BadUSB payloads without plugging in a device, loading the device, loading the dev payload, then executing on device. This allows the BadUSB script to be simulated as if a BadUSB Device was running the attack. More features will be added later. This project is meant for development and education purposes only. 


## FAQ
**Q. What does this project do?**

_**A.** This project allows you to develop payloads for a device using the correct "core" without plugging in, transferring payload, disconnecting, reconnecting, then testing to see if it works. You don't even need to own a device. Just need a PC with a Supported OS._




**Q. Will this work on my PC?**

_**A.** Currently, this project only supports Windows 10 and Windows 11. - Hence why it's called "BadPowerShell". We have plans to support UNIX/OSX in the future._




**Q. So if I have a supported PC, I can just develop Payloads for free?**

_**A.** Yes. This is meant to help the community develop/test/experience what BadUSB/DuckyScript is all about. Purely educational and for development._




**Q. Do you have a place where I can compare commands of all the versions?**

_**A.** Not yet, but in the process of being completed. This repo is supposed to be as accurate as possible, and will only be posted on here once we can verify with documentation or via Developers._

##

**Supported Cores**

| Core# | Versions     | 
|------:|--------------|
|      0| Flipper Zero |
|      1| DuckyScriptV1| 

**Future Cores**

| Versions     | Est. Firmware Completion |
|--------------|--------------------------|
| ATTINY85     |  Version 2.4             |
| PwnP1 (Orig.)|  Version 2.5             |


> [!NOTE]
> DuckyScript 2+ is Trademarked and Copyrighted. We can not support it at this current time.


##


```PowerShell> > .\BadPS.ps1 --help


BadPS Examples:
.\BadPS.ps1 <badusb_file.txt>        - Launch a BadUSB payload
.\BadPS.ps1 --update                 - Update BadPS to current Version
.\BadPS.ps1 --version                - Show local Version of BadPS
.\BadPS.ps1                          - Launch BadPS in Dev Mode


Supported DUCKYSCRIPT V1 Core Commands:
DELAY, DEFAULT_DELAY, BACKSPACE, ENTER, STRING_DELAY, GUI, ALT, CTRL, SHIFT, ESCAPE,
CTRL-SHIFT, SHIFT-ALT, SHIFT-GUI, CTRL-ALT, F1-12, UP, DOWN, LEFT, RIGHT, STRING,
TAB, SCROLLLOCK, CAPSLOCK, INSERT, SPACE, PAUSE, PRINTSCREEN

Supported Flipper BadUSB Core Commands:
DELAY, DEFAULT_DELAY, BACKSPACE, ENTER, STRING_DELAY, GUI, ALT, CTRL, SHIFT, ESCAPE,
CTRL-SHIFT, SHIFT-ALT, SHIFT-GUI, CTRL-ALT, F1-12, UP, DOWN, LEFT, RIGHT, STRING,
TAB, SCROLLLOCK, CAPSLOCK, INSERT, SPACE, RELEASE, HOLD, PAUSE, REPEAT, ALTCHAR, ALTSTRING,
PRINTSCREEN, WAIT_FOR_BUTTON_PRESS

Un-Supported BadUSB Commands:
 CTRL-ALT DELETE (due to Windows Limits), Unknown


```

## Updating the Project
We have made it about as easy as possible.
```PS> .\BadPS.ps1 --update```
OR
Just type ``` update ``` in Dev Mode.


## Contributions
Want to help improve the project? Pull Requests Welcome!

## Issues?
Missing a Command? Found a bug? Let us know!
Submit them to the [Issues](https://github.com/InfoSecREDD/BadPS/issues) section of this Repo.



