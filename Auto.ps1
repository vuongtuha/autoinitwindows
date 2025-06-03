#Standardize Settings
cd ([Environment]::GetFolderPath("MyDocuments"))
Set-TimeZone -Name "SE Asia Standard Time"
$RegKeyPath = "HKU:\Control Panel\International"
Import-Module International
Set-WinSystemLocale en-US
Set-WinHomeLocation -GeoId 0xF2
Set-WinUserLanguageList en-US -Force
Start-Sleep 1
Set-Culture en-GB
foreach ($c in Get-NetAdapter) { write-host 'Setting DNS for' $c.interfaceName ; Set-DnsClientServerAddress -InterfaceIndex $c.interfaceindex -ServerAddresses ('8.8.8.8', '8.8.4.4') }
$username = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split("\")[-1]
Set-LocalUser -Name $username -FullName UltraMagnus
net stop w32time
w32tm /unregister
w32tm /register
net start w32time
w32tm /resync /nowait

#Fix-100-disk-hdd-fck-up
# --- SYSTEM FILE CHECKER STARTED ---
Write-Host "--- SYSTEM FILE CHECKER STARTED ---"

sfc /scannow

Write-Host ""

# --- DISM SCAN STARTED ---
Write-Host "--- DISM SCAN STARTED ---"
Write-Host ""

DISM /Online /Cleanup-Image /ScanHealth

Write-Host ""
Write-Host ""

# --- DISM REPAIR STARTED ---
Write-Host "--- DISM REPAIR STARTED ---"
DISM /Online /Cleanup-Image /RestoreHealth
Write-Host "Done..."
Write-Host ""

# --- Temp File Removal Started ---
Write-Host "--- Temp File Removal Started ---"

Remove-Item -Path "c:\windows\temp\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\temp" -Force -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "c:\windows\temp" -Force | Out-Null

Remove-Item -Path "C:\WINDOWS\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:TEMP" -Force -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$env:TEMP" -Force | Out-Null

Remove-Item -Path "c:\windows\tempor~1" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\tempor~1\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\temp" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\temp\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\tmp" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\tmp\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\ff*.tmp" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\history" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\history\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\cookies" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\cookies\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\recent" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\recent\*" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\windows\spool\printers\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "c:\windows\spool\printers" -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item -Path "c:\WIN386.SWP" -Force -ErrorAction SilentlyContinue

Write-Host "Done!"
Write-Host ""

# --- Reset Windows Updates Starting ---
Write-Host "--- Reset Windows Updates Starting ---"
Write-Host ""

Stop-Service -Name "wuauserv" -Force
Read-Host "Press any key to continue..."
Start-Service -Name "wuauserv" -Force

Write-Host ""
Write-Host "Task completed successfully..."
Write-Host ""
###
#Pronounce check
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Repair-WinGetPackageManager -IncludePrerelease -AllUsers

# Check for Windows 10 based on major version number (no matter anymore)
#Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
#Set-ExecutionPolicy Bypass -Scope Process -Confirm:$False
#if ($null -eq (Get-Command "winget.exe" -ErrorAction SilentlyContinue)) 
#{ 
#    Write-Output "WinGet is not present on the system"
#    if (!(Get-Command -Verb Repair -Noun WinGetPackageManager)) {
#        Write-Output "Microsoft.WinGet.Client is not installed or is not on the latest version"
#        try
#        {
#            Write-Output "Attempting to uninstall an older version of Microsoft.WinGet.Client..."
#            Uninstall-Module -Name Microsoft.WinGet.Client -Confirm:$false -Force -Scope CurrentUser    
#        }
#        catch 
#        {
#            Write-Output "Microsoft.WinGet.Client was not installed."
#        }
#        Write-Output "Installing Microsoft.WinGet.Client..."
#        Install-PackageProvider -Name NuGet -Force -Confirm:$false -Scope CurrentUser
#        Install-Module -Name Microsoft.WinGet.Client -Confirm:$false -Force -Scope CurrentUser
#        Write-Output "Microsoft.WinGet.Client was installed successfully"
#    }
#
#    Write-Output "Checking for updates for Microsoft.WinGet.Client module..."
#    if ((Get-Module -Name Microsoft.WinGet.Client -ListAvailable).Version -ge '1.11.230')
#    {
#        Write-Output "Microsoft.WinGet.Client is up-to-date"
#    } else {
#        Write-Output "Updating Microsoft.WinGet.Client module..."
#        Update-Module -Name Microsoft.WinGet.Client -Confirm:$false -Force -Scope CurrentUser
#    }
#
#    Write-Output "Installing WinGet..."
#    Repair-WinGetPackageManager
#    Write-Output "WinGet was installed successfully"
#}


#office365 install
if (!(Test-Path office.exe)) {
curl -Uri "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA" -o office.exe
Start-Process -FilePath "office.exe" -WindowStyle Hidden
}

# Pretty useless stuff
Import-Module Appx
curl -Uri "https://github.com/vuongtuha/autoinitwindows/blob/main/xp.jpg?raw=true" -o "C:\ProgramData\Microsoft\User Account Pictures\xp.jpg"
curl -Uri "https://github.com/vuongtuha/autoinitwindows/blob/main/user-192.png?raw=true" -o "C:\ProgramData\Microsoft\User Account Pictures\user-192.png"
$uap = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"

$lsw = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

Set-Itemproperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -value 0

if (!(Test-Path -Path $uap)) {

  New-Item -Path $uap -Force | Out-Null

}

if (!(Test-Path -Path $lsw)) {

  New-Item -Path $lsw -Force | Out-Null

}

New-ItemProperty -Path $uap -Name "UseDefaultTile" -PropertyType "DWORD" -Value "1"

Set-ItemProperty -Path $lsw -Name LockScreenImagePath -value  "C:\ProgramData\Microsoft\User Account Pictures\xp.jpg"
#skip-bcoz-stupid-dependencies-loophole

#Driver-autotool

Start-Process PowerShell -ArgumentList "-Command", "& {
cd ([Environment]::GetFolderPath('Desktop'))
Invoke-WebRequest -uri https://github.com/vuongtuha/autoinitwindows/releases/download/12.4.0.585/Driver_B00ster_Pro_12.4.0.585.7z -o driver.tar.gz
}"



###
function Install-RequiredPackage {
  param(
    [string[]] $StringList
  )

  # Loop through each string in the list
  foreach ($item in $StringList) {
    Write-Host "Installing package: $item"
    winget install --id $item --accept-source-agreements --accept-package-agreements
    # Add your logic here to process each string item ($item)
    # For example, you could call another function or perform some operation on the string
  }
}
###
function Install-OptionalPackage {
  param(
    [string] $PackageName
  )
  $confirmation = Read-Host "Do you want to install the optional package: $PackageName ? "

  if ($confirmation -like 'y*') {
    winget install $PackageName
    Write-Host "Installing optional package: $PackageName"
  } else {
    Write-Host "Skipping optional package: $PackageName"
  }
}
###

# Call function to install required package
$listOfStrings = "Giorgiotani.Peazip", "Microsoft.DotNet.Framework.DeveloperPack_4", "Microsoft.VCRedist.2015+.x64", "Microsoft.DirectX", "CocCoc.CocCoc", "lamquangminh.EVKey", "Daum.PotPlayer", "PeterPawlowski.foobar2000", "Faststone.Viewer", "SumatraPDF.SumatraPDF", "CodeSector.TeraCopy", "HiBitSoftware.HiBitUninstaller"
Install-RequiredPackage -StringList $listOfStrings

# Call function for optional packages
#Install-OptionalPackage "CrystalDewWorld.CrystalDiskInfo.AoiEdition"
#Install-OptionalPackage "CrystalDewWorld.CrystalDiskMark"
Install-OptionalPackage "Bitdefender.Bitdefender"
Install-OptionalPackage "Guru3D.Afterburner"
Install-OptionalPackage "Guru3D.RTSS"
Install-OptionalPackage "StartIsBack.StartAllBack"
Install-OptionalPackage "TeamViewer.TeamViewer"
# Open PowerShell instance
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://christitus.com/win | iex }" -WindowStyle Hidden
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://massgrave.dev/get | iex }" -WindowStyle Hidden
Start-Process "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\lamquangminh.EVKey_Microsoft.Winget.Source_8wekyb3d8bbwe\EVKey64" -WindowStyle Hidden
Get-ChildItem -Path ([Environment]::GetFolderPath("MyDocuments")) -Recurse -dir | foreach { Remove-Item -Force -Recurse -Path $_}
Get-ChildItem -Path ([Environment]::GetFolderPath("MyDocuments")) -file | Where-Object {$_.Name -NotContains "office.exe"} | Remove-Item -Force -Recurse
regsvr32 "$env:ProgramFiles\TeraCopy\TeraCopy.dll"
$l = @'
 "ROFL:ROFL:ROFL:ROFL"   /$$$$$$$$ /$$           /$$           /$$                       /$$
         _^___          | $$_____/|__/          |__/          | $$                      | $$
 L    __/   [] \        | $$       /$$ /$$$$$$$  /$$  /$$$$$$$| $$$$$$$   /$$$$$$   /$$$$$$$
LOL===__        \       | $$$$$   | $$| $$__  $$| $$ /$$_____/| $$__  $$ /$$__  $$ /$$__  $$
 L      \________]      | $$__/   | $$| $$  \ $$| $$|  $$$$$$ | $$  \ $$| $$$$$$$$| $$  | $$
         I   I          | $$      | $$| $$  | $$| $$ \____  $$| $$  | $$| $$_____/| $$  | $$
        --------/       | $$      | $$| $$  | $$| $$ /$$$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$$
(,(,(,(,(,(,(,(, ")     |__/      |__/|__/  |__/|__/|_______/ |__/  |__/ \_______/ \_______/
'@
Write-Host $l
