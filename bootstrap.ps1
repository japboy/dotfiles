#!/usr/local/bin/powershell
#Requires -Version 5.0

#
# WINDOWS 10 BOOTSTRAP
#
# This script will be run directly if using Windows 10

# TODO: Run as administrator
#Set-ExecutionPolicy RemoteSigned
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

#
# Functions

function SetUserEnv ($key, $value)
{
    Write-Host "Setting $key as user-level environment variable"
    [Environment]::SetEnvironmentVariable($key, $value, 'User')
}

function Download ([string] $url, [string] $dest, [string] $filename = $null)
{
    # Follow redirect
    Write-Host "Requesting to $url"
    $req = Invoke-WebRequest `
        -Uri $url `
        -MaximumRedirection 0 `
        -ErrorAction Ignore `
        -UserAgent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.59 Safari/537.36'
    If ($req.StatusDescription -eq 'Moved Temporarily') { $url = $req.Headers.Location }
    # Download if not exist
    If (!$filename) { $filename = Split-Path $url -Leaf }
    $destFile = "$dest\$filename"
    If (!(Test-Path -Path $destFile -PathType Leaf)) {
        Write-Host "Downloading $filename"
        Invoke-WebRequest -Uri $url -OutFile $destFile
    }
}

function Run ([string] $path, [string] $argv = $null)
{
    $filename = Split-Path $path -Leaf
    Write-Output "Running $filename"
    If (!$argv)
    {
        Start-Process -FilePath $path -Wait
        Return    
    }
    Start-Process -FilePath $path -ArgumentList $($argv -split '; ') -Wait
    #Invoke-Expression -Command "$path [string]$argv"
}

function Mklink ([string] $src, [string] $dst)
{
    Write-Host "Creating symbolic link $dst"
    Start-Process `
        -FilePath 'powershell' `
        -ArgumentList $("New-Item -Path $dst -ItemType SymbolicLink -Value $src" -split '; ') `
        -Verb runas `
        -Wait
}

function Extract ([string] $inpath, [string] $outpath)
{
    Write-Host "Extracting to $outpath"
    Expand-Archive -Path $inpath -DestinationPath $outpath
}


#
# Set common variables

$cwd = Get-Location
$develPath = "$env:USERPROFILE\Developer"
$downloadPath = "$env:HOMEPATH\Downloads"
#Set-Location -Path $cwd


#
# Create ~/Developer directory for common use cases

If (!(Test-Path -Path $develPath -PathType Container))
{
    New-Item -ItemType Directory -Path $develPath
    New-Item -ItemType Directory -Path "$develPath\bin"
    New-Item -ItemType Directory -Path "$develPath\opt"
}
SetUserEnv 'Path' "$env:Path;$develPath\bin"


#
# Software installation

If (!(Test-Path -Path $downloadPath -PathType Container))
{
    New-Item -ItemType Directory -Path $downloadPath
}

# .NET Core SDK for Windows
#Download `
#    'https://go.microsoft.com/fwlink/?LinkID=827524' `
#    $downloadPath `
#    'DotNetCore.1.0.1-SDK.1.0.0.Preview2-003133-x64.exe'
#Run "$downloadPath\DotNetCore.1.0.1-SDK.1.0.0.Preview2-003133-x64.exe"

# 7-Zip
#Download 'http://www.7-zip.org/a/7z1604-x64.msi' $downloadPath
#Run "$downloadPath\7z1604-x64.msi" '/promptrestart'

# Git for Windows
Download `
    'https://github.com/git-for-windows/git/releases/download/v2.10.1.windows.1/Git-2.10.1-64-bit.exe' `
    $downloadPath
Run "$downloadPath\Git-2.10.1-64-bit.exe"

# ConEmu
# FIXME: Impossible to download
#Download 'https://www.fosshub.com/ConEmu.html/ConEmuSetup.161009a.exe' $downloadPath 'ConEmuSetup.161009a.exe'
#Run "$downloadPath\ConEmuSetup.161009a.exe"
$conemuXml = "$env:APPDATA\ConEmu.xml"
If (Test-Path -Path $conemuXml -PathType Leaf) { Remove-Item $conemuXml }
Mklink "$cwd\windows\AppData\Roaming\ConEmu.xml" $conemuXml

# Visual Studio Code
Download 'https://go.microsoft.com/fwlink/?LinkID=623230' $downloadPath 'VSCodeSetup-stable.exe'
Run "$downloadPath\VSCodeSetup-stable.exe"
$vscodeSettingJson = "$env:APPDATA\Code\User\settings.json"
If (Test-Path -Path $vscodeSettingJson -PathType Leaf) { Remove-Item $vscodeSettingJson }
Mklink "$cwd\windows\AppData\Roaming\Code\User\settings.json" $vscodeSettingJson
Run 'code' @"
    --install-extension
    christian-kohler.path-intellisense
    dbaeumer.vscode-eslint
    EditorConfig.EditorConfig
    ilich8086.classic-asp
    ms-vscode.csharp
    ms-vscode.PowerShell
    vscodevim.vim
"@

# Selenium
Download `
    'http://selenium-release.storage.googleapis.com/3.0/selenium-server-standalone-3.0.0.jar' `
    "$develPath\opt"
Mklink "$cwd\windows\Developer\bin\selenium.bat" "$develPath\bin\selenium.bat"
Download 'http://chromedriver.storage.googleapis.com/2.24/chromedriver_win32.zip' $downloadPath
Extract "$downloadPath\chromedriver_win32.zip" "$develPath\bin"