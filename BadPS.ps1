# Title: BadPS - BadPowerShell BadUSB Payload Development Launcher
# Description: This tool was created to give people the ability to develop
#     BadUSB payloads without plugging in a device, loading the device, loading
#     the dev payload, then executing on device. This allows the BadUSB script 
#     to be simulated as if a BadUSB Device was running the attack. More 
#     features will be added later. This project is meant for development
#     and education purposes only. 
# AUTHOR: InfoSecREDD
# Version: 2.2.3
# Target: Windows
$version = "2.2.3"
$source = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeyboardSend
{
    public class KeyboardSend
    {
        [DllImport("user32.dll")]
        public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

        private const int KEYEVENTF_EXTENDEDKEY = 1;
        private const int KEYEVENTF_KEYUP = 2;

        public static void KeyDown(Keys vKey)
        {
            keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY, 0);
        }

        public static void KeyUp(Keys vKey)
        {
            keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
        }    
    }  
}
"@
Add-Type -TypeDefinition $source -ReferencedAssemblies "System.Windows.Forms"
$specialKeys = @{
    'BACK'     = [System.Windows.Forms.Keys]::Back
    'TAB'      = [System.Windows.Forms.Keys]::Tab
    'ENTER'    = [System.Windows.Forms.Keys]::Enter
    'ESCAPE'   = [System.Windows.Forms.Keys]::Escape
    'SPACE'    = [System.Windows.Forms.Keys]::Space
    'PAGEUP'   = [System.Windows.Forms.Keys]::PageUp
    'PAGEDOWN' = [System.Windows.Forms.Keys]::PageDown
    'END'      = [System.Windows.Forms.Keys]::End
    'HOME'     = [System.Windows.Forms.Keys]::Home
    'LEFT'     = [System.Windows.Forms.Keys]::Left
    'UP'       = [System.Windows.Forms.Keys]::Up
    'RIGHT'    = [System.Windows.Forms.Keys]::Right
    'DOWN'     = [System.Windows.Forms.Keys]::Down
    'DELETE'   = [System.Windows.Forms.Keys]::Delete
    'INSERT'   = [System.Windows.Forms.Keys]::Insert
    'F1'       = [System.Windows.Forms.Keys]::F1
    'F2'       = [System.Windows.Forms.Keys]::F2
    'F3'       = [System.Windows.Forms.Keys]::F3
    'F4'       = [System.Windows.Forms.Keys]::F4
    'F5'       = [System.Windows.Forms.Keys]::F5
    'F6'       = [System.Windows.Forms.Keys]::F6
    'F7'       = [System.Windows.Forms.Keys]::F7
    'F8'       = [System.Windows.Forms.Keys]::F8
    'F9'       = [System.Windows.Forms.Keys]::F9
    'F10'      = [System.Windows.Forms.Keys]::F10
    'F11'      = [System.Windows.Forms.Keys]::F11
    'F12'      = [System.Windows.Forms.Keys]::F12
    'NUMLOCK'  = [System.Windows.Forms.Keys]::NumLock
    'SCROLL'   = [System.Windows.Forms.Keys]::Scroll
    'CAPSLOCK' = [System.Windows.Forms.Keys]::Capital
    'PRINT'    = [System.Windows.Forms.Keys]::PrintScreen
    'PAUSE'    = [System.Windows.Forms.Keys]::Pause
}
function VersionNewer($version, $onlineVersion) {
    $components = $version -split '\.'
    $onlineComponents = $onlineVersion -split '\.'
    if ($components.Count -lt 2 -or $onlineComponents.Count -lt 2) {
        return $false
    }
    $Major = [int]$components[0]
    $Minor = [int]$components[1]
    $onlineMajor = [int]$onlineComponents[0]
    $onlineMinor = [int]$onlineComponents[1]
    if ($Major -lt $onlineMajor) {
        return $true
    } elseif ($Major -eq $onlineMajor -and $Minor -lt $onlineMinor) {
        return $true
    }
    return $false
}
$atos = "$pwd/setting.db"
$BpPID = $PID
$URL = "https://raw.githubusercontent.com/InfoSecREDD/BadPS/main/BadPS.ps1"
$windowHeight = $Host.UI.RawUI.WindowSize.Height
$windowWidth = $Host.UI.RawUI.WindowSize.Width
$fileName = $MyInvocation.MyCommand.Name
function VersionNewer($version, $onlineVersion) {
  $components = $version -split '\.'
  $onlineComponents = $onlineVersion -split '\.'
  if ($components.Count -lt 2 -or $onlineComponents.Count -lt 2) {
    return $false
  }
  $numComponents = [Math]::Max($components.Count, $onlineComponents.Count)
  for ($i = 0; $i -lt $numComponents; $i++) {
    $localComponent = if ($i -lt $components.Count) { [int]$components[$i] } else { 0 }
    $onlineComponent = if ($i -lt $onlineComponents.Count) { [int]$onlineComponents[$i] } else { 0 }
    if ($localComponent -lt $onlineComponent) {
      return $true
    } elseif ($localComponent -gt $onlineComponent) {
      return $false
    }
  }
  return $false
}
if ($args.Count -gt 0) {
  if ($args -eq '--help' -Or $args -eq '-help' -Or $args -eq 'help') {
    Write-Host "`n`nBadPS Examples:"
    Write-Host ".`\$fileName `<badusb_file.txt`>        - Launch a BadUSB payload"
    Write-Host ".`\$fileName --update                 - Update BadPS to current Version"
    Write-Host ".`\$fileName --version                - Show local Version of BadPS"
    Write-Host ".`\$fileName                          - Launch BadPS in Dev Mode"
    Write-Host "`n"
    Write-Host "Supported BadUSB Commands:"
    Write-Host "DELAY, DEFAULT_DELAY, BACKSPACE, ENTER, PRINTSCREEN, GUI, ALT, CTRL, SHIFT, ESCAPE, "
    Write-Host "CTRL-SHIFT, SHIFT-ALT, SHIFT-GUI, CTRL-ALT, F1-12, UP, DOWN, LEFT, RIGHT, STRING/ALTSTRING,"
    Write-Host "TAB, SCROLLLOCK, CAPSLOCK, INSERT, SPACE, RELEASE, HOLD`n"
    Write-Host "Un-Supported BadUSB Commands:"
    Write-Host "DEFINE, EXFIL, CTRL-ALT DELETE (due to Windows Limits), ALTCODE, Unknown`n`n`n"
    exit 0
  }
  if ($args -eq '--version' -Or $args -eq '-version' -Or $args -eq '-v' -Or $args -eq 'version') {
    Write-Host "`nCurrent Version: $version`n`n"
    exit 0
  }
  if ($args -eq '--update' -Or $args -eq '-update' -Or $args -eq 'update') {
    Write-Host "Checking GitHub for newer release..."
    $content = Invoke-RestMethod -Uri $url
    if ($content) {
      $lines = $content -split "`r`n"
      if ($lines.Count -ge 11) {
        $versionLine = $lines[10]
        $lineParts = $versionLine -split '\s+'
        if ($lineParts.Count -ge 2) {
          $versionNumber = $lineParts[-1]
          $versionNumber = $versionNumber -replace '"', ''
        }
      }
    }
    if (VersionNewer $version $versionNumber) {
      Write-Host "`nNEWER VERSION DETECTED`!`n`nGithub Version: $versionNumber`nLocal Version: $version`n"
      $updateConfirm = ""
      $updateConfirm = Read-Host "Are you sure you want to update? (y`/N)" 
      if ( $updateConfirm -eq "yes" -Or $updateConfirm -eq "y" -Or $updateConfirm -eq "Y" ) {
        if (Test-Path "UPDATE-$fileName")
        {
          Remove-Item -Path "UPDATE-$fileName" -Force -Recurse  >$null 2>&1
        }
        if (!(Test-Path "UPDATE-$fileName"))
        {
          New-Item -Path "$pwd" -Name "UPDATE-$fileName" -ItemType File  >$null 2>&1
        }
        "$content" | Out-File -FilePath "UPDATE-$fileName"
        if (Test-Path "OLD-$fileName")
        {
          Remove-Item -Path "OLD-$fileName" -Force -Recurse  >$null 2>&1
        }
        Write-Host "  --> Updating now`!"
        Sleep 3
        Rename-Item -Path "$pwd\$fileName" -NewName "OLD-$fileName"
        Remove-Item -Path "$fileName" -Force -Recurse  >$null 2>&1
        Rename-Item -Path "$pwd\UPDATE-$fileName" -NewName "$fileName"
        Remove-Item -Path "OLD-$fileName" -Force -Recurse  >$null 2>&1
        Write-Host "`n${BG}  --`> Finished Updating from $version to $versionNumber`!"
      }
    Write-Host "`n`n"
    exit 0
    } else {
      Write-Host "Github Version: $versionNumber`nLocal Version: $version`n`nNo update needed.`n`n"
      exit 0
    }
  } 
}
if ($args.Count -eq 0) {
    if (!(Test-Path "$atos")) {
      New-Item -Path $atos -ItemType File >$null 2>&1
      "0" | Set-Content -Path "$atos"
      $tos = Get-Content -Path $atos
      if ($tos -ne 1) {
        Write-Host "THIS SCRIPT IS PROVIDED `"AS IS`" AND WITHOUT WARRANTIES.`nTHE DEVELOPER MAKES NO WARRANTIES, EXPRESS OR IMPLIED,`nREGARDING THE SCRIPTS FUNCTIONALITY, PERFORMANCE, OR `nFITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN RISK.`nINFOSECREDD(REDD) IS NOT LIABLE FOR ANY MISUSE OF THIS`nPROJECT. THIS PROJECT IS MEANT FOR DEVELOPMENT AND`nEDUCATIONAL PURPOSES. PLEASE USE RESPONSIBLY. `n`n"
        $confirmation = ""
        while ($confirmation -ne "yes") {
          $confirmation = Read-Host "Do you agree to the Terms and Conditions? (Type 'yes' to proceed)" 
          if ($confirmation -ne "yes") {
            Write-Host "You must agree to the Terms and Conditions to proceed."
          }
          if ($confirmation -eq "yes") {
            Write-Host "Thank you for agreeing to the Terms and Conditions."
            "1" | Set-Content -Path "$atos"
            continue;
          }
        }
      }
    }
    if (Test-Path "$atos") {
      $tos = Get-Content -Path $atos
      if ($tos -ne 1) {
        Write-Host "`n`n`nTHIS SCRIPT IS PROVIDED `"AS IS`" AND WITHOUT WARRANTIES.`nTHE DEVELOPER MAKES NO WARRANTIES, EXPRESS OR IMPLIED,`nREGARDING THE SCRIPTS FUNCTIONALITY, PERFORMANCE, OR `nFITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN RISK.`nINFOSECREDD(REDD) IS NOT LIABLE FOR ANY MISUSE OF THIS`nPROJECT. THIS PROJECT IS MEANT FOR DEVELOPMENT AND`nEDUCATIONAL PURPOSES. PLEASE USE RESPONSIBLY. `n`n"
        $confirmation = ""
        while ($confirmation -ne "yes") {
          $confirmation = Read-Host "Do you agree to the terms and conditions? (Type 'yes' to proceed)" 
          if ($confirmation -ne "yes") {
            Write-Host "You must agree to the terms and conditions to proceed."
          }
          if ($confirmation -eq "yes") {
            Write-Host "Thank you for agreeing to the terms and conditions."
            "1" | Set-Content -Path "$atos"
            continue;
          }
        }
      }
    }
    else
    {
      New-Item -Path $atos -ItemType File
      $tos = Get-Content -Path $atos
      if ($tos -ne 1) {
        Write-Host "`n`n`nTHIS SCRIPT IS PROVIDED `"AS IS`" AND WITHOUT WARRANTIES.`nTHE DEVELOPER MAKES NO WARRANTIES, EXPRESS OR IMPLIED,`nREGARDING THE SCRIPTS FUNCTIONALITY, PERFORMANCE, OR `nFITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN RISK.`nINFOSECREDD(REDD) IS NOT LIABLE FOR ANY MISUSE OF THIS`nPROJECT. THIS PROJECT IS MEANT FOR DEVELOPMENT AND`nEDUCATIONAL PURPOSES. PLEASE USE RESPONSIBLY. `n`n"
        $confirmation = ""
        while ($confirmation -ne "yes") {
          $confirmation = Read-Host "Do you agree to the terms and conditions? (Type 'yes' to proceed)" 
          if ($confirmation -ne "yes") {
            Write-Host "You must agree to the terms and conditions to proceed."
          }
          if ($confirmation -eq "yes") {
            Write-Host "Thank you for agreeing to the terms and conditions."
            "1" | Set-Content -Path "$atos"
            continue;
          }
        }
      }
    }
  }
else
{
  $file = $args
  if (!(Test-Path -Path $file -PathType Leaf)) {
      Write-Host "No file named: $args"
      exit 0
  }
}
function resize {
    param (
        [int]$width,
        [int]$height
    )
  $pshost = Get-Host
  $pswindow = $pshost.UI.RawUI
  $newsize = $pswindow.BufferSize
  $newsize.height = $height
  $newsize.width = $width
  $pswindow.buffersize = $newsize
  $newsize = $pswindow.windowsize
  $newsize.width = $width
  $pswindow.windowsize = $newsize
}
function hold 
{
    param (
        $key
    ) 
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
    }
  }
}
function release 
{
    param (
        $key
    ) 
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
}
function PageUp
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::PageUp)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::PageUp)
}
function PageDown
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::PageDown)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::PageDown)
}
function Space
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Space)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Space)
}
function PrtScrn
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::PrintScreen)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::PrintScreen)
}
function Num
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::NumLock)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::NumLock)
}
function Caps
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Capital)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Capital)
}
function ScrLk
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Scroll)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Scroll)
}
function Insert
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Insert)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Insert)
}
function Tab
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Tab)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Tab)
}
function Backspace
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Back)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Back)
}
function Delete
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Delete)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Delete)
}
function Escape
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Escape)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Escape)
}
function DownArrow
{ 
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Down)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Down)
}
function UpArrow
{ 
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Up)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Up)
}
function LeftArrow
{ 
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Left)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Left)
}
function RightArrow
{ 
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Right)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Right)
}
function Gui
{
    param (
        $key
    ) 
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::LWin)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::LWin)
}
function Alt
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Menu)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Menu)
}
function Ctrl
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ControlKey)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ControlKey)
}

function Shift
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ShiftKey)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ShiftKey)
}
function CtrlShift
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ControlKey)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ShiftKey)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ControlKey)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ShiftKey)
}
function CtrlAlt
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ControlKey)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Menu)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ControlKey)
}
function AltShift
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ShiftKey)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ShiftKey)
}
function AltTab
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Tab)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Tab)
}
function AltGui
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::LWin)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Menu)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::LWin)
}
function GuiShift
{
    param (
        $key
    )
  $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
  $chkKey = $specialKeys[$key]
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::LWin)
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::ShiftKey)
  if ( $key -ne '' -And $key -ne ' ' ) {
    if ($chkKey -in $specialKeys) {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
    else {
      [KeyboardSend.KeyboardSend]::KeyDown($key)
      [KeyboardSend.KeyboardSend]::KeyUp($key)
    }
  }
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::LWin)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::ShiftKey)
}
function SendKeys {
    param (
        $SENDKEYS
    )
  $wshell = New-Object -ComObject wscript.shell
  if ($SENDKEYS) {
    $wshell.SendKeys($SENDKEYS)
    if (!([string]::IsNullOrEmpty($delayDefault))) {
      Start-Sleep -Milliseconds $delayDefault
    }
    else
    {
      Start-Sleep -Milliseconds 10
    }
  }
}
function runPayload ($payload) {
  $filePath = "$file"
  if (Test-Path $filePath -PathType Leaf) {
    Get-Content -Path $filePath | ForEach-Object {
      $line = $_
      if ($line -match '^DEFAULT_DELAY (\d+)') {
        $global:delayDefault = [int]$matches[1]
      }
      if ($line -match '^DELAY (\d+)' -Or $line -match '^SLEEP (\d+)') {
        $delayValue = [int]$matches[1]
        Start-Sleep -Milliseconds $delayValue
      }
      if ($line -match '^F(.*)') {
        $char = $matches[1]
        SendKeys -SENDKEYS "{F${char}}"
      }
      if ($line -match '^ENTER(.*)') {
        SendKeys -SENDKEYS '{ENTER}'
      }
      if ($line -match '^CTRL-SHIFT(.*)' -Or $line -match '^CTRL\+SHIFT(.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          CtrlShift "$char"
        } else {
          CtrlShift
        }
      }
      if ($line -match '^CTRL-ALT (.*)' -Or $line -match '^CTRL\+ALT (.*)' -Or $line -match '^CTRL ALT (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          CtrlAlt "$char"
        } else {
          CtrlAlt
        } 
      }
      if ($line -match '^ALT-SHIFT (.*)' -Or $line -match '^ALT\+SHIFT (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          AltShift "$char"
        } else {
          AltShift
        }
      }
      if ($line -match '^ALT-TAB (.*)' -Or $line -match '^ALT\+TAB (.*)' -Or $line -match '^ALT-TAB(.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          AltTab "$char"
        } else {
          AltTab
        }
      }
      if ($line -match '^SHIFT (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          Shift "$char"
        } else {
          Shift
        }
      }
      if ($line -match '^ESC(.*)' -Or $line -match '^ESCAPE(.*)') {
        Escape
      }
      if ($line -match '^SPACE(.*)' -Or $line -match '^SPACEBAR(.*)') {
        Space
      }
      if ($line -match '^PRNTSCRN(.*)' -Or $line -match '^PRINTSCREEN(.*)') {
        PrtScrn
      }
      if ($line -match '^PAGEUP(.*)' -Or $line -match '^PGUP(.*)') {
        PageUp
      }
      if ($line -match '^PAGEDOWN(.*)' -Or $line -match '^PGD(.*)') {
        PageDown
      }
      if ($line -match '^CAPSLOCK (.*)' -Or $line -match '^CAPS (.*)') {
        Caps 
      }
      if ($line -match '^SCROLLLOCK (.*)' -Or $line -match '^SCROLL(.*)') {
        ScrLk
      }
      if ($line -match '^CTRL (.*)' -Or $line -match '^CONTROL (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          Ctrl "$char"
        } else {
          Ctrl
        }
      }
      if ($line -match '^HOLD (.*)' -Or $line -match '^HLD (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          hold "$char"
        }
      }
      if ($line -match '^RELEASE (.*)' -Or $line -match '^REL (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          release "$char"
        }
      }
      if ($line -match '^ALT (.*)' -Or $line -match '^ALT-(.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
        Alt "$char"
        } else {
          Alt
        }
      }
      if ($line -match '^INSERT (.*)') {
        Insert
      }
      if ($line -match '^BACKSPACE(.*)') {
        Backspace
      }
      if ($line -match '^DOWNARROW(.*)' -Or $line -match '^DOWN(.*)') {
        DownArrow
      }
      if ($line -match '^UPARROW(.*)' -Or $line -match '^UP(.*)') {
        UpArrow
      }
      if ($line -match '^LEFTARROW(.*)' -Or $line -match '^LEFT(.*)') {
        LeftArrow
      }
      if ($line -match '^RIGHTARROW(.*)' -Or $line -match '^RIGHT(.*)') {
        RightArrow
      }
      if ($line -match 'GUI (.*)' -Or $line -match 'GUI-(.*)' -Or $line -match 'GUI\+(.*)' -Or $line -match 'WIN\+(.*)' -Or $line -match 'WIN-(.*)' -Or $line -match 'WIN (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          $capChar = $char.ToUpper()
          Gui "$capChar"
        } else {
          Gui
        }
      }
      if ($line -match 'GUI-SHIFT (.*)' -Or $line -match 'GUI+SHIFT (.*)') {
        $char = $matches[1]
        if ($char -ne '' -Or $char -ne ' ') { 
          $charArray = $char.Split(' ')
          $result = $charArray[0]
          $char = "$result"
          $capChar = $char.ToUpper()
          GuiShift "$capChar"
        } else {
          GuiShift
        }
      }
      if ($line -match '^STRING (.*)' -Or $line -match '^ALTSTRING (.*)') {
        $textAfterString = $matches[1]
        foreach ($char in $textAfterString.ToCharArray()) {
          if ( $char -eq " " ) {
            SendKeys -SENDKEYS ' '
          } else {
            SendKeys -SENDKEYS "{$char}"
          }
        }
      }
    }
  } 
  else
  {
    Write-Host "File not found: $filePath"
  }
}
function runMenu {
  resize -height 800 -width 82 >$null 2>&1
  $Host.UI.RawUI.BackgroundColor = "Black"
  Clear-Host; Clear-Host
  $R = [char]27 + '[31m';$G = [char]27 + '[32m';$Y = [char]27 + '[33m';$B = [char]27 + '[34m';$M = [char]27 + '[35m';$C = [char]27 + '[36m';$W = [char]27 + '[37m';$Gy = [char]27 + '[90m';$BR = [char]27 + '[91m';$BG = [char]27 + '[92m';$BY = [char]27 + '[93m';$BB = [char]27 + '[94m';$BM = [char]27 + '[95m';$BC = [char]27 + '[96m';$BW = [char]27 + '[97m';$RST = [char]27 + '[0m'
  if ( $ChkRun -eq "0" ) {
    $preMenuText = @('Your time is limited, dont waste it living someone elses life.                                                                     - Steve Jobs','You are never too old to set another goal or to dream a new dream.','Its not whether you get knocked down, its whether you get up.','Success is not in what you have, but who you are.','Our greatest weakness lies in giving up. The most certain way                                                            to succeed is always to try just one more time.                                                                                       - Thomas Edison','It does not matter how slowly you go as long as you do not stop.','Just remember, youre here for a reason..','Today may feel impossible, but that too will fade...') | Get-Random
    Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n           ${BG}`"${G}$preMenuText${BG}`" `n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    $ChkRun = "1"
    Sleep 5
    Clear-Host; Clear-Host
  }
  do {
    Clear-Host
    $currentDirectory = Get-Location
    $txtFiles = Get-ChildItem -Path $currentDirectory -Filter *.txt
    Write-Host "`n`n`n${Gy}            :::::::::      :::     :::::::::  :::    :::  ::::::::  :::::::::    "
    Write-Host "           ${Gy}:${R}+${Gy}:    :${R}+${Gy}:   :${R}+${Gy}: :${R}+${Gy}:   :${R}+${Gy}:    :${R}+${Gy}: :${R}+${Gy}:    :${R}+${Gy}: :${R}+${Gy}:    :${R}+${Gy}: :${R}+${Gy}:    :${R}+${Gy}:    "
    Write-Host "          ${R}+${Gy}:${R}+    +${Gy}:${R}+  +${Gy}:${R}+   +${Gy}:${R}+  +${Gy}:${R}+    +${Gy}:${R}+ +${Gy}:${R}+    +${Gy}:${R}+ +${Gy}:${R}+        +${Gy}:${R}+    +${Gy}:${R}+     "
    Write-Host "         ${R}+${BR}#${R}++:${R}++${BR}#${R}+  +${BR}#${R}++:${R}++${BR}#${R}++: ${R}+${BR}#${R}+    +:${R}+ +${BR}#${R}+    +:${R}+ +${BR}#${R}++:${R}++${BR}#${R}++ +${BR}#${R}++:${R}++${BR}#${R}+       "
    Write-Host "        ${R}+${BR}#${R}+    +${BR}#${R}+ +${BR}#${R}+     +${BR}#${R}+ +${BR}#${R}+    +${BR}#${R}+ +${BR}#${R}+    +${BR}#${R}+        +${BR}#${R}+ +${BR}#${R}+    +${BR}#${R}+       "
    Write-Host "       ${BR}#${R}+${BR}#    #${R}+${BR}# #${R}+${BR}#     #${R}+${BR}# #${R}+${BR}#    #${R}+${BR}# #${R}+${BR}#    #${R}+${BR}# #${R}+${BR}#    #${R}+${BR}# #${R}+${BR}#    #${R}+${BR}#        "
    Write-Host "      ${BR}#########  ###     ### #########   ########   ########  #########          `n"
    Write-Host "${Gy}        :::::::::     :::   :::   ::: :::        ::::::::      :::     ::::::::: "
    Write-Host "       ${Gy}:${R}+${Gy}:    :${R}+${Gy}:  :${R}+${Gy}: :${R}+${Gy}: :${R}+${Gy}:   :${R}+${Gy}: :${R}+${Gy}:       :${R}+${Gy}:    :${R}+${Gy}:   :${R}+${Gy}: :${R}+${Gy}:   :${R}+${Gy}:    :${R}+${Gy}: "
    Write-Host "      ${R}+${Gy}:${R}+    +${Gy}:${R}+ +${Gy}:${R}+   +${Gy}:${R}+ +${Gy}:${R}+ +${Gy}:${R}+  +${Gy}:${R}+       +${Gy}:${R}+    +${Gy}:${R}+  +${Gy}:${R}+   +${Gy}:${R}+  +${Gy}:${R}+    +${Gy}:${R}+  "
    Write-Host "     ${R}+${BR}#${R}++${Gy}:${R}++${BR}#${R}+ +${BR}#${R}++${Gy}:${R}++${BR}#++${Gy}:${R} +${BR}#${R}++${Gy}:   ${R}+${BR}#${R}+       +${BR}#${R}+    +${Gy}:${R}+ +${BR}#${R}++${Gy}:${R}++${BR}#${R}++${Gy}: ${R}+${BR}#${R}+    +${Gy}:${R}+   "
    Write-Host "    ${R}+${BR}#${R}+       +${BR}#${R}+     +${BR}#${R}+  +${BR}#${R}+    +${BR}#${R}+       +${BR}#${R}+    +${BR}#${R}+ +${BR}#${R}+     +${BR}#${R}+ +${BR}#${R}+    +${BR}#${R}+    "
    Write-Host "   ${BR}#${R}+${BR}#       #${R}+${BR}#     #${R}+${BR}#  #${R}+${BR}#    #${R}+${BR}#       #${R}+${BR}#    #${R}+${BR}# #${R}+${BR}#     #${R}+${BR}# #${R}+${BR}#    #${R}+${BR}#     "
    Write-Host "  ${BR}###       ###     ###  ###    ########## ########  ###     ### #########       `n"
    Write-Host "                             ${BG}D${G}evelopment ${BG}L${G}auncher"
    Write-Host "                                By InfoSecREDD   `n                                Version: $version`n`n"
    Write-Host " ${C}-------------------------------------------------------------------------------"
    Write-Host "               ${BW}All TXT (${R}BadUSB${BW}) files in Current Directory${Gy}:"
    Write-Host " ${C}-------------------------------------------------------------------------------`n"
    for ($i = 0; $i -lt $txtFiles.Count; $i++) {
      Write-Host " ${BW}    $($i + 1). ${W}$($txtFiles[$i].Name)"
    }
    Write-Host "`n`n ${BW}    0. ${BR}Exit"
    Write-Host "`n"
    Write-Host "${C} -------------------------------------------------------------------------------`n"
    $userInput = Read-Host "  ${BW}Select ${BC}#${BW} and Press ENTER"
    if ($userInput -eq 'update' -or $userInput -eq 'u') {
      Write-Host "`n`nChecking GitHub for newer release..."
      $content = Invoke-RestMethod -Uri $url
      if ($content) {
        $lines = $content -split "`r`n"
        if ($lines.Count -ge 11) {
          $versionLine = $lines[10]
          $lineParts = $versionLine -split '\s+'
          if ($lineParts.Count -ge 2) {
            $versionNumber = $lineParts[-1]
            $versionNumber = $versionNumber -replace '"', ''
          }
        }
      }
      if (VersionNewer $version $versionNumber) {
        Write-Host "`n${BY}NEWER VERSION DETECTED`!`n`n${W}Github Version: $versionNumber`nLocal Version: $version`n"
        $updateConfirm = ""
        $updateConfirm = Read-Host "Are you sure you want to update? (y`/N)" 
        if ( $updateConfirm -eq "yes" -Or $updateConfirm -eq "y" -Or $updateConfirm -eq "Y" ) {
          if (Test-Path "UPDATE-$fileName") {
            Remove-Item -Path "UPDATE-$fileName" -Force -Recurse  >$null 2>&1
          }
          if (!(Test-Path "UPDATE-$fileName")) {
            New-Item -Path "$pwd" -Name "UPDATE-$fileName" -ItemType File  >$null 2>&1
          }
          "$content" | Out-File -FilePath "UPDATE-$fileName"
          if (Test-Path "OLD-$fileName")
          {
            Remove-Item -Path "OLD-$fileName" -Force -Recurse  >$null 2>&1
          }
          Write-Host "`n${BR}  --`> Updating now`!`n`n"
          sleep 3
          Rename-Item -Path "$pwd\$fileName" -NewName "OLD-$fileName"
          Remove-Item -Path "$fileName" -Force -Recurse  >$null 2>&1
          Rename-Item -Path "$pwd\UPDATE-$fileName" -NewName "$fileName"
          Remove-Item -Path "OLD-$fileName" -Force -Recurse  >$null 2>&1
          Write-Host "`n${BG}  --`> Finished Updating from $version to $versionNumber`!`n`n${BC}  --`> Closing old Version and starting new Version.. Please wait.."
          sleep 5
          Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -File $pwd\$fileName"
          Stop-Process -Id $BpPID -Force
        } 
      } else {
        Write-Host "Github Version: $versionNumber`nLocal Version: $version`n`nNo update needed.`n`n"
        Sleep 5
      } 
      Clear-Host
    }
  } while (-not [int]::TryParse($userInput, [ref]$null))
    $selectedIndex = [int]$userInput - 1 
    $totalFiles = $txtFiles.Count
    if ($selectedIndex -eq -1) {
      Clear-Host
      Write-Host "`n`nExiting the script... Please wait.`n`n"
      Write-Host "                                                                                                                                            `n             ${BW} `"I would personally like to Thank EVERYONE! It has been fun!`"`n                                                   ${W}-InfoSecREDD`n`n`n`n`n" 
      Sleep 5
      $Host.UI.RawUI.BackgroundColor = $initialBackgroundColor
      resize -height $windowHeight -width $windowWidth >$null 2>&1
      Clear-Host
      exit
    } elseif ($selectedIndex -ge 0 -and $selectedIndex -lt $txtFiles.Count) {
      $selectedFile = $txtFiles[$selectedIndex]
      $file = $($selectedFile.Name)
      Write-Host "`n`nUser selected: ${BY}$($selectedFile.Name)`n"
      $confirm = ""
      $confirm = Read-Host "You are about to run $($selectedFile.Name). Are you sure? (y`/N)" 
    if ( $confirm -eq "yes" -Or $confirm -eq "y" -Or $confirm -eq "Y" ) {
      Write-Host "`n   Running file now..."
      runPayload 
      Write-Host "`n   Payload completed.`n`n"
      Write-Host "`n   ${C}Returning to Main Menu in 10 seconds...`n`n"
      Sleep 10
    } else {
      Write-Host "`n   Returning to Menu."
      Sleep 4
    }
  } else {
    Clear-Host
    Write-Host "${R}ERROR${W} - Select # between${Y} 0 ${W}and${Y} $totalFiles ${W}and Press ENTER."
    sleep 4
  }

}
$initialBackgroundColor = $Host.UI.RawUI.BackgroundColor
$initialWindowSize = $Host.UI.RawUI.WindowSize
$ChkRun = "0"
while ($true) {
  if ( $args -ne '' -And $args -ne ' ' ) {
    $file = $args
    if (Test-Path "$atos") {
      $tos = Get-Content -Path $atos
      if ($tos -eq 1 ) {
        Write-Host "Attempting to Execute payload.."
        runPayload
        Write-Host "Completed."
        exit 0
      }
      else
      {
        Write-Host "Attempting to Execute payload in 10 seconds.."
        Sleep 10;
        runPayload
        Write-Host "Completed."
        exit 0
      }
    }
    else
    {
      Write-Host "Attempting to Execute payload in 10 seconds.."
      Sleep 10;
      runPayload
      Write-Host "Completed."
      exit 0
    }
      
  } else {
    runMenu
    $ChkRun = "1"
  }
}
