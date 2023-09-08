![Static Badge](https://img.shields.io/badge/Built_with-PowerShell-orange) ![Static Badge](https://img.shields.io/badge/Windows_10-Supported-lime) ![Static Badge](https://img.shields.io/badge/Windows_11-Supported-lime)


# BadPS
BadUSB Payload Development Launcher

This tool was created to give people the ability to develop BadUSB payloads without plugging in a device, loading the device, loading the dev payload, then executing on device. This allows the BadUSB script to be simulated as if a BadUSB Device was running the attack. More features will be added later. This project is meant for development and education purposes only. 


```PS> > .\BadPS.ps1 --help


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
PRINTSCREEN

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



