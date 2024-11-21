#Standardize Settings
cd ([Environment]::GetFolderPath("MyDocuments"))
Set-TimeZone -Name "SE Asia Standard Time"
$RegKeyPath = "HKU:\Control Panel\International"
Import-Module International
Set-WinSystemLocale en-US
Set-WinHomeLocation -GeoId 0xF2
Set-WinUserLanguageList en-US -Force
Set-Culture en-GB
foreach ($c in Get-NetAdapter) { write-host 'Setting DNS for' $c.interfaceName ; Set-DnsClientServerAddress -InterfaceIndex $c.interfaceindex -ServerAddresses ('8.8.8.8', '8.8.4.4') }
$username = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split("\")[-1]
Set-LocalUser -Name $username -FullName UltraMagnus

#office365 install
if (!(Test-Path office.exe)) {
curl -Uri "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=en-us&version=O16GA" -o office.exe
Start-Process -FilePath "office.exe"
}

# Get Chocolatey clean
Import-Module Appx
#skip-bcoz-stupid-dependencies-loophole

#Driver-autotool

Start-Process PowerShell -ArgumentList "-Command", "& {
cd ([Environment]::GetFolderPath('Desktop'))
Invoke-WebRequest -uri https://github.com/vuongtuha/autoinitwindows/releases/download/12.1.0.469/Driver_B00ster_Pro_12.1.0.469.7z -o driver.tar.gz
}"

# Check for Windows 10 based on major version number (modify if needed)
if ($osVersion -match "^10\.") {
  $Manifest = (Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation + '\appxmanifest.xml'; Add-AppxPackage -DisableDevelopmentMode -Register $Manifest
} else {
  irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex
}

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
$listOfStrings = "Giorgiotani.Peazip", "Microsoft.DotNet.Framework.DeveloperPack_4", "Microsoft.VCRedist.2015+.x64", "Microsoft.DirectX", "Alex313031.Thorium.AVX2", "CocCoc.CocCoc", "lamquangminh.EVKey", "MPC-BE.MPC-BE", "MusicBee.MusicBee", "Faststone.Viewer", "Gyan.FFmpeg"
Install-RequiredPackage -StringList $listOfStrings

# Call function for optional packages
Install-OptionalPackage "CrystalDewWorld.CrystalDiskInfo.AoiEdition"
Install-OptionalPackage "CrystalDewWorld.CrystalDiskMark"
Install-OptionalPackage "Bitdefender.Bitdefender"
Install-OptionalPackage "Guru3D.Afterburner"
Install-OptionalPackage "Guru3D.RTSS"
Install-OptionalPackage "TeamViewer.TeamViewer.Host"
# Open PowerShell instance
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://christitus.com/win | iex }" -WindowStyle Hidden
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://massgrave.dev/get | iex }" -WindowStyle Hidden
Start-Process "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\lamquangminh.EVKey_Microsoft.Winget.Source_8wekyb3d8bbwe\EVKey64" -WindowStyle Hidden
Get-ChildItem -Path ([Environment]::GetFolderPath("MyDocuments")) -Recurse -dir | foreach { Remove-Item -Force -Recurse -Path $_}
Get-ChildItem -Path ([Environment]::GetFolderPath("MyDocuments")) -file | Where-Object {$_.Name -NotContains "office.exe"} | Remove-Item -Force -Recurse
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
