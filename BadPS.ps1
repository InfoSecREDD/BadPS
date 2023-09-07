# Title: BadPS - BadPowerShell BadUSB Payload Development Launcher
# Description: This tool was created to give people the ability to develop
#     BadUSB payloads without plugging in a device, loading the device, loading
#     the dev payload, then executing on device. This allows the BadUSB script 
#     to be simulated as if a BadUSB Device was running the attack. More 
#     features will be added later. This project is meant for development
#     and education purposes only. 
# AUTHOR: InfoSecREDD
# Version: 2.2.9
# Target: Windows
$version = "2.2.9"
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
    'APPS'     = [System.Windows.Forms.Keys]::Applications
    'MENU'     = [System.Windows.Forms.Keys]::Applications
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
$atos = "$pwd/setting.db"
$core = "1"
$hosted = "https://raw.githubusercontent.com"
$author = "InfoSecREDD"
$projectName = "BadPS"
$projectFileType = "ps1"
$BpPID = $PID
$UChk = "${hosted}/${author}/${projectName}/main/${projectName}.${projectFileType}"
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
function Changelog {
    param (
        [string]$startVersion,
        [string]$endVersion
    )
  $allChangelogs = @()
  function Get-LiElements {
        param (
            [string]$version
        )
    $url = "https://github.com/InfoSecREDD/BadPS/releases/tag/v$version"
    try {
      $response = Invoke-WebRequest -Uri $url
      $html = $response.ParsedHtml
      if ($html) {
        $divElement = $html.querySelector('div[data-pjax="true"][data-test-selector="body-content"][data-view-component="true"].markdown-body.my-3')
        if ($divElement) {
          $ulElement = $divElement.querySelector('ul')
          if ($ulElement) {
            $liElements = $ulElement.getElementsByTagName('li') | Select-Object -ExpandProperty innerText
            $changelogString = "      --> " + ($liElements -join "`n      --> ")
            if ($changelogString -notlike "Error*") {
              return "`nChangelog for version $version :`n$changelogString`n"
            }
          }
        }
      }
    }
    catch {
      return
    }
  }
  $userVersionParts = $startVersion.Split('.')
  $currentVersionParts = $endVersion.Split('.')
  $userMajor = [int]$userVersionParts[0]
  $currentMajor = [int]$currentVersionParts[0]
  $userMinor = [int]$userVersionParts[1]
  $currentMinor = [int]$currentVersionParts[1]
  $userPatch = [int]$userVersionParts[2]
  $currentPatch = [int]$currentVersionParts[2]
  for ($major = $currentMajor; $major -ge $userMajor; $major--) {
    for ($minor = $currentMinor; $minor -ge $userMinor; $minor--) {
      for ($patch = $currentPatch; $patch -ge $userPatch; $patch--) {
        $version = "$major.$minor.$patch"
        $changelog = Get-LiElements -version $version
        if ($changelog) {
          $allChangelogs += $changelog
        }
      }
    }
  }
  $global:Changelogs = $allChangelogs
}
if ($args.Count -gt 0) {
  if ($args -eq '--help' -Or $args -eq '-help' -Or $args -eq 'help') {
    Write-Host "`n`nBadPS Examples:"
    Write-Host ".`\$fileName `<badusb_file.txt`>        - Launch a BadUSB payload"
    Write-Host ".`\$fileName --update                 - Update BadPS to current Version"
    Write-Host ".`\$fileName --version                - Show local Version of BadPS"
    Write-Host ".`\$fileName                          - Launch BadPS in Dev Mode"
    Write-Host "`n"
    Write-Host "Supported Flipper BadUSB Core Commands:"
    Write-Host "DELAY, DEFAULT_DELAY, BACKSPACE, ENTER, PRINTSCREEN, GUI, ALT, CTRL, SHIFT, ESCAPE, "
    Write-Host "CTRL-SHIFT, SHIFT-ALT, SHIFT-GUI, CTRL-ALT, F1-12, UP, DOWN, LEFT, RIGHT, STRING,"
    Write-Host "TAB, SCROLLLOCK, CAPSLOCK, INSERT, SPACE, RELEASE, HOLD, PAUSE, REPEAT, ALTCHAR, ALTSTRING`n"
    Write-Host "Un-Supported BadUSB Commands:"
    Write-Host " CTRL-ALT DELETE (due to Windows Limits), Unknown`n`n`n"
    exit 0
  }
  if ($args -eq '--version' -Or $args -eq '-version' -Or $args -eq '-v' -Or $args -eq 'version') {
    Write-Host "`nCurrent Version: $version`n`n"
    exit 0
  }
  if ($args -eq '--update' -Or $args -eq '-update' -Or $args -eq 'update') {
    Write-Host "Checking GitHub for newer release..."
    $content = Invoke-RestMethod -Uri $UChk
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
      Changelog "$version" "$versionNumber"
      Write-Host "`nNEWER VERSION DETECTED`!`n`nGithub Version: $versionNumber`n`n"
      Write-Host " $global:Changelogs`n"
      Write-Host "Local Version: $version`n"
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
function KeyPress {
    param (
        [System.Windows.Forms.Keys]$vKey
    )
    [KeyboardSend.KeyboardSend]::KeyDown($vKey)
    [KeyboardSend.KeyboardSend]::KeyUp($vKey)
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
function kPause
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Pause)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Pause)
}
function Insert
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Insert)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Insert)
}
function Applications
{
  [KeyboardSend.KeyboardSend]::KeyDown([System.Windows.Forms.Keys]::Applications)
  [KeyboardSend.KeyboardSend]::KeyUp([System.Windows.Forms.Keys]::Applications)
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
function AltChar {
    param (
        [string]$inputCode,
        [string]$AltString
    )
  $inputCode = $inputCode.Trim()
  $altCodeMapping = @{
    "1" = [char]0x263A; "2" = [char]0x263B; "3" = [char]0x2665; "4" = [char]0x2666; "5" = [char]0x2663;
    "6" = [char]0x2660; "7" = [char]0x2022; "8" = [char]0x25D8; "9" = [char]0x25CB; "10" = [char]0x25D9;
    "11" = [char]0x2642; "12" = [char]0x2640; "13" = [char]0x266A; "14" = [char]0x266B; "15" = [char]0x263C;
    "16" = [char]0x25BA; "17" = [char]0x25C4; "18" = [char]0x2195; "19" = [char]0x203C; "20" = [char]0x00B6;
    "21" = [char]0x00A7; "22" = [char]0x25AC; "23" = [char]0x21A8; "24" = [char]0x2191; "25" = [char]0x2193;
    "26" = [char]0x2192; "27" = [char]0x2190; "28" = [char]0x221F; "29" = [char]0x2194; "30" = [char]0x25B2;
    "31" = [char]0x25BC; "32" = [char]0x0020; "33" = [char]0x0021; "34" = [char]0x0022; "35" = [char]0x0023;
    "36" = [char]0x0024; "37" = [char]0x0025; "38" = [char]0x0026; "39" = [char]0x0027; "40" = [char]0x0028;
    "41" = [char]0x0029; "42" = [char]0x002A; "43" = [char]0x002B; "44" = [char]0x002C; "45" = [char]0x002D;
    "46" = [char]0x002E; "47" = [char]0x002F; "48" = [char]0x0030; "49" = [char]0x0031; "50" = [char]0x0032;
    "51" = [char]0x0033; "52" = [char]0x0034; "53" = [char]0x0035; "54" = [char]0x0036; "55" = [char]0x0037;
    "56" = [char]0x0038; "57" = [char]0x0039; "58" = [char]0x003A; "59" = [char]0x003B; "60" = [char]0x003C;
    "61" = [char]0x003D; "62" = [char]0x003E; "63" = [char]0x003F; "64" = [char]0x0040; "65" = [char]0x0041;
    "66" = [char]0x0042; "67" = [char]0x0043; "68" = [char]0x0044; "69" = [char]0x0045; "70" = [char]0x0046;
    "71" = [char]0x0047; "72" = [char]0x0048; "73" = [char]0x0049; "74" = [char]0x004A; "75" = [char]0x004B;
    "76" = [char]0x004C; "77" = [char]0x004D; "78" = [char]0x004E; "79" = [char]0x004F; "80" = [char]0x0050;
    "81" = [char]0x0051; "82" = [char]0x0052; "83" = [char]0x0053; "84" = [char]0x0054; "85" = [char]0x0055;
    "86" = [char]0x0056; "87" = [char]0x0057; "88" = [char]0x0058; "89" = [char]0x0059; "90" = [char]0x005A;
    "91" = [char]0x005B; "92" = [char]0x005C; "93" = [char]0x005D; "94" = [char]0x005E; "95" = [char]0x005F;
    "96" = [char]0x0060; "97" = [char]0x0061; "98" = [char]0x0062; "99" = [char]0x0063; "100" = [char]0x0064;
    "101" = [char]0x0065; "102" = [char]0x0066; "103" = [char]0x0067; "104" = [char]0x0068; "105" = [char]0x0069;
    "106" = [char]0x006A; "107" = [char]0x006B; "108" = [char]0x006C; "109" = [char]0x006D; "110" = [char]0x006E;
    "111" = [char]0x006F; "112" = [char]0x0070; "113" = [char]0x0071; "114" = [char]0x0072; "115" = [char]0x0073;
    "116" = [char]0x0074; "117" = [char]0x0075; "118" = [char]0x0076; "119" = [char]0x0077; "120" = [char]0x0078;
    "121" = [char]0x0079; "122" = [char]0x007A; "123" = [char]0x007B; "124" = [char]0x007C; "125" = [char]0x007D;
    "126" = [char]0x007E; "127" = [char]0x2302; "128" = [char]0x00C7; "129" = [char]0x00FC; "130" = [char]0x00E9;
    "131" = [char]0x00E2; "132" = [char]0x00E4; "133" = [char]0x00E0; "134" = [char]0x00E5; "135" = [char]0x00E7;
    "136" = [char]0x00EA; "137" = [char]0x00EB; "138" = [char]0x00E8; "139" = [char]0x00EF; "140" = [char]0x00EE;
    "141" = [char]0x00EC; "142" = [char]0x00C4; "143" = [char]0x00C5; "144" = [char]0x00C9; "145" = [char]0x00E6;
    "146" = [char]0x00C6; "147" = [char]0x00F4; "148" = [char]0x00F6; "149" = [char]0x00F2; "150" = [char]0x00FB;
    "151" = [char]0x00F9; "152" = [char]0x00FF; "153" = [char]0x00D6; "154" = [char]0x00DC; "155" = [char]0x00A2;
    "156" = [char]0x00A3; "157" = [char]0x00A5; "158" = [char]0x20A7; "159" = [char]0x0192; "160" = [char]0x00E1;
    "161" = [char]0x00ED; "162" = [char]0x00F3; "163" = [char]0x00FA; "164" = [char]0x00F1; "165" = [char]0x00D1;
    "166" = [char]0x00AA; "167" = [char]0x00BA; "168" = [char]0x00BF; "169" = [char]0x2310; "170" = [char]0x00AC;
    "171" = [char]0x00BD; "172" = [char]0x00BC; "173" = [char]0x00A1; "174" = [char]0x00AB; "175" = [char]0x00BB;
    "176" = [char]0x2591; "177" = [char]0x2592; "178" = [char]0x2593; "179" = [char]0x2502; "180" = [char]0x2524;
    "181" = [char]0x2561; "182" = [char]0x2562; "183" = [char]0x2556; "184" = [char]0x2555; "185" = [char]0x2563;
    "186" = [char]0x2551; "187" = [char]0x2557; "188" = [char]0x255D; "189" = [char]0x255C; "190" = [char]0x255B;
    "191" = [char]0x2510; "192" = [char]0x2514; "193" = [char]0x2534; "194" = [char]0x252C; "195" = [char]0x251C;
    "196" = [char]0x2500; "197" = [char]0x253C; "198" = [char]0x2522; "199" = [char]0x2521; "200" = [char]0x255A;
    "201" = [char]0x2554; "202" = [char]0x2569; "203" = [char]0x2566; "204" = [char]0x2560; "205" = [char]0x2550;
    "206" = [char]0x256C; "207" = [char]0x2567; "208" = [char]0x2568; "209" = [char]0x2564; "210" = [char]0x2565;
    "211" = [char]0x2559; "212" = [char]0x2558; "213" = [char]0x2552; "214" = [char]0x2553; "215" = [char]0x256B;
    "216" = [char]0x256A; "217" = [char]0x2518; "218" = [char]0x251C; "219" = [char]0x2588; "220" = [char]0x2584;
    "221" = [char]0x258C; "222" = [char]0x2590; "223" = [char]0x2580; "224" = [char]0x03B1; "225" = [char]0x00DF;
    "226" = [char]0x0393; "227" = [char]0x03C0; "228" = [char]0x03A3; "229" = [char]0x03C3; "230" = [char]0x00B5;
    "231" = [char]0x03C4; "232" = [char]0x03A6; "233" = [char]0x0398; "234" = [char]0x03A9; "235" = [char]0x03B4;
    "236" = [char]0x221E; "237" = [char]0x03C6; "238" = [char]0x03B5; "239" = [char]0x2229; "240" = [char]0x2261;
    "241" = [char]0x00B1; "242" = [char]0x2265; "243" = [char]0x2264; "244" = [char]0x2320; "245" = [char]0x2321;
    "246" = [char]0x00F7; "247" = [char]0x2248; "248" = [char]0x00B0; "249" = [char]0x2219; "250" = [char]0x00B7;
    "251" = [char]0x221A; "252" = [char]0x207F; "253" = [char]0x00B2; "254" = [char]0x25A0; "255" = [char]0x00A0;
  }
  if (!([string]::IsNullOrEmpty($inputCode))) {
    if ($altCodeMapping.ContainsKey($inputCode)) {
      $character = $altCodeMapping[$inputCode]
      [System.Windows.Forms.SendKeys]::SendWait($character)
    }
  }
  if (!([string]::IsNullOrEmpty($altString))) {
    foreach ($char in $altString.ToCharArray()) {
      $altCode = [int][char]$char
      $character = $altCodeMapping["$altCode"]
      [System.Windows.Forms.SendKeys]::SendWait($character)
    }
  }
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
function runFlipper {
    param (
        [string]$payload,
        [string]$command
    )
  $filePath = "$file"
  $lastLine = $null  # Initialize the last line variable
  $repeatCount = 1
  if (!([string]::IsNullOrEmpty($command))) {
    $line = $command
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
    if ($line -match '^INSERT(.*)') {
      Insert
    }
    if ($line -match '^MENU(.*)' -Or $line -match '^APPS(.*)') {
      Applications
    }
    if ($line -match '^PAUSE(.*)' -Or $line -match '^BREAK(.*)') {
      kPause
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
    if ($line -match '^STRING (.*)') {
      $textAfterString = $matches[1]
      foreach ($char in $textAfterString.ToCharArray()) {
        if ( $char -eq " " ) {
          SendKeys -SENDKEYS ' '
        } else {
          SendKeys -SENDKEYS "{$char}"
        }
      }
    }
    if ($line -match '^ALTCHAR (.*)') {
      $char = $matches[1]
      if ($char -ne '' -Or $char -ne ' ') { 
        $charArray = $char.Split(' ')
        $result = $charArray[0]
        $char = "$result"
        AltChar -inputCode "$char"
      }
    }
    if ($line -match '^ALTSTRING (.*)') {
      $char = $matches[1]
      if ($char -ne '' -Or $char -ne ' ') { 
        $charArray = $char.Split(' ')
        $result = $charArray[0]
        $char = "$result"
        AltChar -AltString "$char"
      }
    }
  } 
  if (!([string]::IsNullOrEmpty($payload))) {
    if (Test-Path $filePath -PathType Leaf) {
      Get-Content -Path $filePath | ForEach-Object {
        $line = $_
        if ($line -match '^REPEAT (\d+)') {
            $repeatCount = [int]$matches[1]
            $repeatCountFix = [int]$repeatCount + 1
            $repeatCount = $repeatCountFix
              } else {
           $lastLine = $line
        }
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
        if ($line -match '^INSERT(.*)') {
          Insert
        }
        if ($line -match '^MENU(.*)' -Or $line -match '^APPS(.*)') {
          Applications
        }
        if ($line -match '^PAUSE(.*)' -Or $line -match '^BREAK(.*)') {
          kPause
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
        if ($line -match '^STRING (.*)') {
          $textAfterString = $matches[1]
          foreach ($char in $textAfterString.ToCharArray()) {
            if ( $char -eq " " ) {
              SendKeys -SENDKEYS ' '
            } else {
              SendKeys -SENDKEYS "{$char}"
            }
          }
        }
        if ($line -match '^ALTCHAR (.*)') {
          $char = $matches[1]
          if ($char -ne '' -Or $char -ne ' ') { 
            $charArray = $char.Split(' ')
            $result = $charArray[0]
            $char = "$result"
            AltChar -inputCode "$char"
          }
        }
        if ($line -match '^ALTSTRING (.*)') {
          $char = $matches[1]
          if ($char -ne '' -Or $char -ne ' ') { 
            $charArray = $char.Split(' ')
            $result = $charArray[0]
            $char = "$result"
            AltChar -AltString "$char"
          }
        }
      }
      for ($i = 1; $i -le $repeatCount; $i++) {
        runFlipper -COMMAND "$lastLine"
      }
    } 
    else
    {
      Write-Host "File not found: $filePath"
    }
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
  if ( $core -eq "1" ) {
    $coreDesc = 'Flipper Zero  '
  }
  if ( $core -eq "2" ) {
    $coreDesc = 'DuckyScript v1'
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
    Write-Host "                                By InfoSecREDD   `n                                Version: $version`n`n                           ${BR}B${R}ad${BR}USB CORE: ${W}$coreDesc"
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
      $content = Invoke-RestMethod -Uri $UChk
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
        Changelog "$version" "$versionNumber"
        Write-Host "`n${BY}NEWER VERSION DETECTED`!`n`n${W}Github Version: $versionNumber`n`n"
        Write-Host " ${Gy}$global:Changelogs`n"
        Write-Host "`n${W}Local Version: $version`n"
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
    if ( $userInput -eq 'core' -Or $userInput -eq 'cores' ) {
      Write-Host "`n`n${BR}This feature is still being implemented. Try again later.`n`n"
      sleep 5
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
      if ( $core -eq "1" ) {
        runFlipper -PAYLOAD "$file"
      }
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
        if ( $core -eq "1" ) {
          runFlipper "$file"
        }
        Write-Host "Completed."
        exit 0
      }
      else
      {
        Write-Host "Attempting to Execute payload in 10 seconds.."
        Sleep 10;
        if ( $core -eq "1" ) {
          runFlipper "$file"
        }
        Write-Host "Completed."
        exit 0
      }
    }
    else
    {
      Write-Host "Attempting to Execute payload in 10 seconds.."
      Sleep 10;
      if ( $core -eq "1" ) {
        runFlipper "$file"
      }
      Write-Host "Completed."
      exit 0
    }
      
  } else {
    runMenu
    $ChkRun = "1"
  }
}
