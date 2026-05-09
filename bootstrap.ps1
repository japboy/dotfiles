#
# WINDOWS 11 BOOTSTRAP
#
# This script links files under WSL's ~/.dotfiles/windows/ directory into the
# Windows user profile. It expects the repository to exist in WSL and does not
# clone or download repository files into Windows. Linux symlinks under windows/
# are resolved in WSL before Windows symlinks are created.
#
# From PowerShell:
# & ([scriptblock]::Create((
#     wsl.exe --distribution Ubuntu --exec bash -lc 'cat ~/.dotfiles/bootstrap.ps1'
# ) -join [Environment]::NewLine))

[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion -lt [Version]'5.1')
{
    throw 'PowerShell 5.1 or later is required.'
}

# Windows PowerShell 5.1's New-Item -ItemType SymbolicLink does not honor
# Developer Mode, so call CreateSymbolicLinkW with the unprivileged flag directly.
if (-not ('DotfilesSymbolicLink' -as [type]))
{
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class DotfilesSymbolicLink
{
    private const int SYMBOLIC_LINK_FLAG_DIRECTORY = 0x1;
    private const int SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE = 0x2;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, EntryPoint = "CreateSymbolicLinkW", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.I1)]
    private static extern bool CreateSymbolicLink(string linkPath, string targetPath, int flags);

    public static void Create(string linkPath, string targetPath, bool isDirectory)
    {
        int flags = SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE;

        if (isDirectory)
        {
            flags |= SYMBOLIC_LINK_FLAG_DIRECTORY;
        }

        if (!CreateSymbolicLink(linkPath, targetPath, flags))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error());
        }
    }
}
'@
}

function Get-ErrorMessage ([Exception] $exception)
{
    $currentException = $exception

    while (($null -ne $currentException) -and ($null -ne $currentException.InnerException))
    {
        $currentException = $currentException.InnerException
    }

    if ($null -eq $currentException)
    {
        return ''
    }

    return $currentException.Message
}

function Join-TargetPath ([string] $basePath, [string] $relativePath)
{
    $targetPath = $basePath

    foreach ($relativePathSegment in ($relativePath -split '/'))
    {
        if ([string]::IsNullOrWhiteSpace($relativePathSegment))
        {
            continue
        }

        $targetPath = Join-Path -Path $targetPath -ChildPath $relativePathSegment
    }

    return $targetPath
}

function Test-CopyRelativePath ([string] $relativePath, [string[]] $prefixes)
{
    foreach ($prefix in $prefixes)
    {
        if ($relativePath.StartsWith($prefix, [StringComparison]::Ordinal))
        {
            return $true
        }
    }

    return $false
}

Write-Host 'Starting Windows bootstrap...'

$homePath = [Environment]::GetFolderPath('UserProfile')

if ([string]::IsNullOrWhiteSpace($homePath))
{
    throw 'Windows user profile path could not be resolved.'
}

$wslDistribution = 'Ubuntu'

Write-Host "Resolving dotfiles path from WSL distribution: $wslDistribution..."

if (-not (Get-Command 'wsl.exe' -ErrorAction SilentlyContinue))
{
    throw "wsl.exe was not found. This bootstrap expects the $wslDistribution WSL distribution with ~/.dotfiles."
}

$wslListScript = @'
set -eu

dotfiles_path="$(cd "$HOME/.dotfiles" 2>/dev/null && pwd -P)"
windows_path="$dotfiles_path/windows"

[ -d "$windows_path" ]

printf 'ROOT\t%s\n' "$(wslpath -w "$dotfiles_path")"

cd "$windows_path"

find . \( -type f -o -type l \) -print | sort | while IFS= read -r source_path
do
    relative_path="${source_path#./}"
    resolved_path="$(readlink -f "$source_path")"
    if [ -d "$resolved_path" ]; then source_type='Directory'; else source_type='File'; fi
    source_windows_path="$(wslpath -w "$resolved_path")"
    printf 'ENTRY\t%s\t%s\t%s\n' "$relative_path" "$source_type" "$source_windows_path"
done
'@

# Windows PowerShell writes CRLF to native command stdin; remove CR before Bash parses the script.
$wslOutput = $wslListScript | & wsl.exe --distribution $wslDistribution --exec bash -c "tr -d '\r' | bash -s"

if ($LASTEXITCODE -ne 0)
{
    throw "Windows dotfiles could not be listed from the $wslDistribution distribution. Ensure ~/.dotfiles/windows exists in WSL."
}

$dotfilesPath = ''
$linkEntries = @()

foreach ($wslOutputLine in $wslOutput)
{
    if ([string]::IsNullOrWhiteSpace($wslOutputLine))
    {
        continue
    }

    $wslOutputFields = $wslOutputLine.Replace("`r", "") -split "`t", 4

    if ($wslOutputFields[0] -eq 'ROOT')
    {
        if ($wslOutputFields.Count -ne 2)
        {
            throw "Invalid WSL root output: $wslOutputLine"
        }

        $dotfilesPath = $wslOutputFields[1]
        continue
    }

    if ($wslOutputFields[0] -eq 'ENTRY')
    {
        if ($wslOutputFields.Count -ne 4)
        {
            throw "Invalid WSL entry output: $wslOutputLine"
        }

        if (($wslOutputFields[2] -ne 'File') -and ($wslOutputFields[2] -ne 'Directory'))
        {
            throw "Invalid WSL entry type: $wslOutputLine"
        }

        $linkEntries += [PSCustomObject] @{
            RelativePath = $wslOutputFields[1]
            IsDirectory = ($wslOutputFields[2] -eq 'Directory')
            SourcePath = $wslOutputFields[3]
        }
        continue
    }

    throw "Unexpected WSL output: $wslOutputLine"
}

if ([string]::IsNullOrWhiteSpace($dotfilesPath))
{
    throw "WSL returned an empty dotfiles path. Ensure ~/.dotfiles exists in the $wslDistribution distribution."
}

$sourceRoot = "$dotfilesPath\windows"

Write-Host "Using WSL dotfiles path: $dotfilesPath"
Write-Host "Link source: $sourceRoot"
Write-Host "Link target: $homePath"

# Codex Desktop may read files through WSL's /mnt/c path. That path can fail
# on Windows symlinks whose targets are WSL UNC paths, so materialize .codex.
# @see https://github.com/openai/codex/issues/18506
$copyRelativePathPrefixes = @(
    '.codex/'
)

$linkPreflightEntries = @($linkEntries | Where-Object { -not (Test-CopyRelativePath $_.RelativePath $copyRelativePathPrefixes) })

if ($linkPreflightEntries.Count -gt 0)
{
    $preflightDirectory = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath "dotfiles-bootstrap-$([Guid]::NewGuid().ToString('N'))"
    $preflightEntries = @()
    $preflightEntries += @($linkPreflightEntries | Where-Object { -not $_.IsDirectory } | Select-Object -First 1)
    $preflightEntries += @($linkPreflightEntries | Where-Object { $_.IsDirectory } | Select-Object -First 1)

    New-Item -ItemType Directory -Path $preflightDirectory -Force | Out-Null

    try
    {
        $preflightIndex = 0

        foreach ($preflightEntry in $preflightEntries)
        {
            if ($null -eq $preflightEntry)
            {
                continue
            }

            $preflightLinkPath = Join-Path -Path $preflightDirectory -ChildPath "symlink-test-$preflightIndex"
            $preflightSourcePath = $preflightEntry.SourcePath
            $preflightIsDirectory = $preflightEntry.IsDirectory
            [DotfilesSymbolicLink]::Create($preflightLinkPath, $preflightSourcePath, $preflightIsDirectory)
            $preflightIndex += 1
        }
    }
    catch
    {
        $preflightErrorMessage = Get-ErrorMessage $_.Exception
        throw "Symbolic link preflight failed before modifying files. Enable Developer Mode or run PowerShell as Administrator. Source: $preflightSourcePath. Error: $preflightErrorMessage"
    }
    finally
    {
        Remove-Item -LiteralPath $preflightDirectory -Force -Recurse -ErrorAction SilentlyContinue
    }
}

foreach ($linkEntry in $linkEntries)
{
    $relativePath = $linkEntry.RelativePath
    $sourcePath = $linkEntry.SourcePath
    $isDirectory = $linkEntry.IsDirectory
    $shouldCopy = Test-CopyRelativePath $relativePath $copyRelativePathPrefixes
    $targetPath = Join-TargetPath $homePath $relativePath

    $targetParentPath = Split-Path -Path $targetPath -Parent

    if ((-not [string]::IsNullOrWhiteSpace($targetParentPath)) -and (-not (Test-Path -LiteralPath $targetParentPath -PathType Container)))
    {
        New-Item -ItemType Directory -Path $targetParentPath -Force | Out-Null
    }

    $targetItem = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue

    if ($shouldCopy)
    {
        if ($null -ne $targetItem)
        {
            $isTargetLink = (($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)

            if ($isTargetLink)
            {
                Remove-Item -LiteralPath $targetPath -Force -Recurse
                Write-Host "Existing symlink removed: $targetPath"
            }
            elseif ($isDirectory)
            {
                if ($targetItem.PSIsContainer)
                {
                    Remove-Item -LiteralPath $targetPath -Force -Recurse
                    Write-Host "Existing directory removed: $targetPath"
                }
                else
                {
                    $backupPath = "$targetPath.orig"

                    if (Test-Path -LiteralPath $backupPath)
                    {
                        Remove-Item -LiteralPath $targetPath -Force
                    }
                    else
                    {
                        Move-Item -LiteralPath $targetPath -Destination $backupPath
                        Write-Host "Existing item moved: $targetPath -> $backupPath"
                    }
                }
            }
            elseif ($targetItem.PSIsContainer)
            {
                throw "Directory exists where file should be copied: $targetPath"
            }
        }

        if ($isDirectory)
        {
            Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force -Recurse
            Write-Host "Directory copied: $targetPath <- $sourcePath"
        }
        else
        {
            Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
            Write-Host "File copied: $targetPath <- $sourcePath"
        }

        continue
    }

    if ($null -ne $targetItem)
    {
        $isTargetLink = (($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)

        if ((-not $targetItem.PSIsContainer) -and (-not $isTargetLink))
        {
            $backupPath = "$targetPath.orig"

            if (Test-Path -LiteralPath $backupPath)
            {
                throw "Backup path already exists: $backupPath"
            }

            Move-Item -LiteralPath $targetPath -Destination $backupPath
            Write-Host "Existing item moved: $targetPath -> $backupPath"
        }
        else
        {
            continue
        }
    }

    try
    {
        [DotfilesSymbolicLink]::Create($targetPath, $sourcePath, $isDirectory)
        Write-Host "Symlink created: $targetPath -> $sourcePath"
    }
    catch
    {
        $linkErrorMessage = Get-ErrorMessage $_.Exception
        throw "Failed to create symbolic link: $targetPath -> $sourcePath. Error: $linkErrorMessage"
    }
}

Write-Host 'Windows bootstrap completed.'
