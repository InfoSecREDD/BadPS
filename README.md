# BadPS
BadUSB Payload Development Launcher

This tool was created to give people the ability to develop BadUSB payloads without plugging in a device, loading the device, loading the dev payload, then executing on device. This allows the BadUSB script to be simulated as if a BadUSB Device was running the attack. More features will be added later. This project is meant for development and education purposes only. 


```PS> > .\BadPS.ps1 --help


BadPS Examples:
.\BadPS.ps1 <badusb_file.txt>        - Launch a BadUSB payload
.\BadPS.ps1                          - Launch BadPS in Dev Mode


Supported BadUSB Commands:
DELAY, DEFAULT_DELAY, BACKSPACE, ENTER, PRINTSCREEN, GUI, ALT, CTRL, SHIFT, ESCAPE,
CTRL-SHIFT, SHIFT-ALT, SHIFT-GUI, CTRL-ALT, F1-12, UP, DOWN, LEFT, RIGHT, STRING/ALTSTRING,
TAB, SCROLLLOCK, CAPSLOCK, INSERT

Un-Supported BadUSB Commands:
DEFINE, EXFIL, CTRL-ALT DELETE (due to Windows Limits), ALTCODE, Unknown


```
