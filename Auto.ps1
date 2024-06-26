#Standardize Settings
cd ([Environment]::GetFolderPath("MyDocuments"))
Set-TimeZone -Name "SE Asia Standard Time"
$RegKeyPath = "HKU:\Control Panel\International"
Import-Module International
Set-WinSystemLocale en-US
Set-WinHomeLocation -GeoId 0xF2
Set-Culture en-GB
Set-WinUserLanguageList en-US -Force
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
Invoke-WebRequest -uri https://github.com/vuongtuha/autoinitwindows/releases/download/11.4.0.60/Driver_B00ster_Pro_11.4.0.60.tar.gz -o driver.tar.gz
}"
# Fetch the URI of the latest version of the winget-cli from GitHub releases
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith('.msixbundle') }

# Extract the name of the .msixbundle file from the URI
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split('/')[-1]

# Show a progress message for the first download step
Write-Progress -Activity 'Installing Winget CLI' -Status 'Downloading Step 1 of 2'

# Temporarily set the ProgressPreference variable to SilentlyContinue to suppress progress bars
Set-Variable ProgressPreference SilentlyContinue

Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml -OutFile .\microsoft.ui.xaml.nupkg.zip
Expand-Archive -Path .\microsoft.ui.xaml.nupkg.zip -Force

# Get the .appx file in the directory
$appxFile = Get-ChildItem -Path .\microsoft.ui.xaml.nupkg\tools\AppX\x64\Release -Filter "*.appx" | Select-Object -First 1

# Install the .appx file
Try { Add-AppxPackage -Path $appxFile.FullName -ErrorAction Stop } Catch {}

# Download the latest .msixbundle file of winget-cli from GitHub releases
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"

# Reset the ProgressPreference variable to Continue to allow progress bars
Set-Variable ProgressPreference Continue

# Show a progress message for the second download step
Write-Progress -Activity 'Installing Winget CLI' -Status 'Downloading Step 2 of 2'

Set-Variable ProgressPreference SilentlyContinue

# Download the VCLibs .appx package from Microsoft
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx

# Try to install the VCLibs .appx package, suppressing any error messages
Try { Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction Stop } Catch {}

# Install the latest .msixbundle file of winget-cli
Try { Add-AppxPackage $latestWingetMsixBundle -ErrorAction Stop} Catch {}
Write-Progress -Activity 'Installing Winget CLI' -Status 'Install Complete' -Completed
Set-Variable ProgressPreference Continue
# Get Windows version information
$osVersion = (Get-WmiObject Win32_OperatingSystem).Version

# Check for Windows 10 based on major version number (modify if needed)
if ($osVersion -match "^10\.") {
  $Manifest = (Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation + '\appxmanifest.xml'; Add-AppxPackage -DisableDevelopmentMode -Register $Manifest
} else {
  Get-AppxPackage Windows.ImmersiveControlPanel | Reset-AppxPackage
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
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/winutil.ps1 | iex }" -WindowStyle Hidden
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm https://massgrave.dev/get | iex }" -WindowStyle Hidden
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { EVKey64 | cmd }" -WindowStyle Hidden
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
