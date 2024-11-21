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
Invoke-WebRequest -uri https://github.com/vuongtuha/autoinitwindows/releases/download/12.1.0.469/Driver_B00ster_Pro_12.1.0.469.7z -o driver.tar.gz
}"
if ($osVersion -match "^10\.") {
$progressPreference = 'silentlyContinue'
# Set the environment variable for the root of the temp folder
$LogPath = $env:TEMP

# Set the XML Dependency
$UIXAMLDependency = "Microsoft.UI.Xaml"
$UIXAMLAPPXDependency = $env:ProgramFiles + "\PackageManagement\NuGet\Packages\Microsoft.UI.Xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"
$VCDependency = "Microsoft.VCLibs.x64.14.00.Desktop.appx"

# Configure download location for Winget
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]

# Download Microsoft binaries.
Write-Information "Downloading winget to current directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx

# Workaround for Microsoft.UI.Xaml dependency.
# Creates an additional dependency on Microsoft.Web.Webview2
# Detection logic was breaking the silent install. Just installing NuGet's package provider.
Write-Information "Install Nuget..."
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -Confirm:$false

# Install Winget PowerShell Module
# Check if Nuget Module is installed
Write-Information "Checking for Nuget Powershell Module..."
if(-not (Get-Module -ListAvailable -Name NuGet)) {
    # Install the Nuget PowerShell Module
    Write-Information "Nuget Powershell Module not found. Installing..."
    Install-Module -Name NuGet -Force
}
Write-Information "Nuget Powershell Module found."

# Configure Nuget.org repository
# Check if Nuget.org repository is registered
Write-Information "Check if Nuget.org repository is registered..."
if(-not (Get-PackageSource | Where-Object { $_.Name -eq 'nuget.org' })) 
{
    # Register the Nuget.org repository
    Write-Information "Nuget.org repository not found. Registering..."
    Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet
}
Write-Information "Nuget.org repository found."

# Install Microsoft.UI.Xaml
# Check if UI Xaml is installed
Write-Information "Checking for Microsoft UI XAML..."
if (-not (Get-Package -Name $UIXAMLDependency -RequiredVersion 2.7 -ErrorAction SilentlyContinue)) 
{
    Write-Information "Installing Microsoft UI XAML..."
    Install-Package $UIXAMLDependency -RequiredVersion 2.7 -Force
    Add-AppxPackage $UIXAMLAPPXDependency
}
Write-Information "Microsoft UI XAML found."

# Install VC++ Libs
# Check if VC++ Libs  is installed
Write-Information "Checking for VC dependency..."
if (-not (Get-AppxPackage -Name $VCDependency -ErrorAction SilentlyContinue)) 
{
    # Install VC++
    Write-Information "Installing VC dependency..."
    Add-AppxPackage "./$VCDependency" -ErrorAction SilentlyContinue
}
Write-Information "VC dependency installed."

# Install winget
# Check if winget is installed
Write-Information "Checking for Winget..."
$wingetPackageName = $latestWingetMsixBundle.Split(".")[0]
if (-not (Get-AppxPackage -Name $wingetPackageName -ErrorAction SilentlyContinue)) 
{
    Write-Information "Installing winget..."
    Add-AppxPackage "./$latestWingetMsixBundle"
}
Write-Information "Winget installed."
}
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
Start-Process PowerShell.exe -ArgumentList "-NoExit", "-Command", "& { irm "https://christitus.com/win" | iex }" -WindowStyle Hidden
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
