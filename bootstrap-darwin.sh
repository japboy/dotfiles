#!/bin/zsh

#
# MAC OS X BOOTSTRAP
#
# This script will be run from `bootstrap.sh` if using Mac OS X


##
# Variables

ARCH=$(uname -a | awk '{print $NF}')

CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_PATH="${HOME}/.dotfiles"
DOTFILES_REAL_PATH=$(cd "${DOTFILES_PATH}" 2>/dev/null && pwd -P)
[ -z "${DOTFILES_REAL_PATH}" ] && DOTFILES_REAL_PATH="${DOTFILES_PATH}"
DOTFILES_DARWIN_PATH="${DOTFILES_PATH}/darwin"
DOTFILES_DARWIN_FLAKE="path:${DOTFILES_REAL_PATH}?dir=darwin"


##
# Functions

function is_older_version () {
    local target_version="${1}"
    local actual_version="${2}"

    [ -z "${actual_version}" ] && return 0

    autoload -Uz is-at-least
    is-at-least "${target_version}" "${actual_version}" && return 1

    return 0
}

function is_older_app () {
    local target_path="${1}"
    local target_version="${2}"
    local actual_version

    [ ! -d "${target_path}" ] && return 0

    actual_version=$(mdls -raw -name kMDItemVersion "${target_path}" 2>/dev/null)
    [ "${actual_version}" = "(null)" ] && return 0

    is_older_version "${target_version}" "${actual_version}"
}

function is_older_os () {
    local target_version="${1}"
    local actual_version

    actual_version=$(sw_vers --productVersion 2>/dev/null)
    is_older_version "${target_version}" "${actual_version}"
}

function is_specific_serial () {
    TARGET_SERIAL=${1}
    ACTUAL_SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
    [ ${TARGET_SERIAL} = ${ACTUAL_SERIAL} ] && return 0
    return 1
}

function source_nix () {
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]
    then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]
    then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    fi
}


##
# Main process

echo "${TEXT_BOLD}Now customizing default configuration...${TEXT_RESET}"

# Key repeat speed up
defaults write NSGlobalDomain InitialKeyRepeat -int 35
defaults write NSGlobalDomain KeyRepeat -int 2

# Enable `locate` command
if ! sudo launchctl list | grep com.apple.locate &> /dev/null
then
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
fi

# Disable `.DS_Store` on network drives
if ! defaults read com.apple.desktopservices DSDontWriteNetworkStores &> /dev/null
then
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

# Apply changes for Autofs
sudo automount -vc

# Make hidden files visible
if ! defaults read com.apple.finder AppleShowAllFiles &> /dev/null
then
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
fi

# Make Kotoeri use only single width space
defaults write com.apple.inputmethod.Kotoeri zhsy -dict-add " " -bool no
killall Kotoeri

# Disable the shadow from the screenshots
if ! defaults read com.apple.screencapture disable-shadow &> /dev/null
then
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi

# Create `Applications` directory under the home directory if it doesn't exist
[ ! -d "${HOME}/Applications" ] && mkdir ${HOME}/Applications

# Create `Developer` directory if it doesn't exist
[ ! -d "${HOME}/Developer" ] && mkdir ${HOME}/Developer


echo "${TEXT_BOLD}Now installing fundamental applications...${TEXT_RESET}"

# Current directory to ~/Downloads
cd ${HOME}/Downloads

# AppCleaner
if is_older_app ~/Applications/AppCleaner.app '3.6.8'
then
    curl -LO https://freemacsoft.net/downloads/AppCleaner_3.6.8.zip
    unzip -o -d ~/Applications/ ./AppCleaner_3.6.8.zip
fi

# Docker
if ! command -v docker &> /dev/null || is_older_version '29.0.1' "$(docker version --format '{{.Client.Version}}' 2>/dev/null)"
then
    if [[ "${ARCH}" = 'arm64' ]]
    then
        curl -LO https://desktop.docker.com/mac/main/arm64/Docker.dmg
    elif [[ "${ARCH}" = 'x86_64' ]]
    then
        curl -LO https://desktop.docker.com/mac/stable/amd64/Docker.dmg
    fi
    hdiutil attach Docker.dmg
    cp -R /Volumes/Docker/Docker.app /Applications/
    hdiutil detach /Volumes/Docker
    open /Applications/Docker.app
fi

# iTerm2
if is_older_app ~/Applications/iTerm.app '3.6.6'
then
    curl -LO https://iterm2.com/downloads/stable/iTerm2-3_6_6.zip
    unzip -o -d ~/Applications/ ./iTerm2-3_6_6.zip
fi

# MonitorControl
if is_older_app ~/Applications/MonitorControl.app '4.3.3'
then
    curl -LO https://github.com/MonitorControl/MonitorControl/releases/download/v4.3.3/MonitorControl.4.3.3.dmg
    hdiutil attach ./MonitorControl.4.3.3.dmg
    cp -a /Volumes/MonitorControl.app ~/Applications/
    hdiutil detach /Volumes/MonitorControl.4.3.3.dmg
fi

# PowerShell
if is_older_app /Applications/PowerShell.app '7.5.4'
then
    cd ${HOME}/Downloads
    if [[ "${ARCH}" = 'arm64' ]]
    then
        curl -LO https://github.com/PowerShell/PowerShell/releases/download/v7.5.4/powershell-7.5.4-osx-arm64.pkg
        sudo installer -pkg ./powershell-7.5.4-osx-arm64.pkg -target /
    elif [[ "${ARCH}" = 'x86_64' ]]
    then
        curl -LO https://github.com/PowerShell/PowerShell/releases/download/v7.5.4/powershell-7.5.4-osx-x64.pkg
        sudo installer -pkg ./powershell-7.5.4-osx-x64.pkg -target /
    fi
    cd ${CWD}
fi

# XQuartz
if is_older_app /Applications/Utilities/XQuartz.app '2.8.5'
then
    curl -LO https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.5/XQuartz-2.8.5.pkg
    hdiutil attach XQuartz-2.8.5.pkg
    sudo installer -pkg /Volumes/XQuartz-2.8.5/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.8.5
fi

# Reset current working directory
cd ${CWD}


if [ -d ~/Library/Fonts/powerline-fonts ]
then
    cd ~/Library/Fonts/powerline-fonts
    git pull origin master
    cd ${CWD}
else
    git clone https://github.com/powerline/fonts.git ~/Library/Fonts/powerline-fonts
fi


echo "${TEXT_BOLD}Now setting up development environment...${TEXT_RESET}"

# Check if Xcode is installed
if [ ! -d /Applications/Xcode.app ] || ! xcrun --find gcc &> /dev/null
then
    echo "${TEXT_RED}Xcode not found. Aborted.${TEXT_RESET}"
    exit 1
fi

# Setup Xcode
xcodebuild -checkFirstLaunchStatus
sudo xcodebuild -license accept

# Check if Command Line Tools are installed
if [ ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &> /dev/null ]
then
    # sudo rm -rf /Library/Developer/CommandLineTools
    xcode-select --install
    echo "${TEXT_RED}Xcode Command Line Tools must be installed first. Aborted.${TEXT_RESET}"
    exit 1
fi

# Rosetta (x86_64 compatibility layer)
if [ "${ARCH}" = 'arm64' ]
then
    softwareupdate --install-rosetta
fi

# Nix if not exists
source_nix

if ! command -v nix &> /dev/null
then
    echo "${TEXT_BOLD}Installing Nix via official installer...${TEXT_RESET}"
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    source_nix
fi

if ! command -v nix &> /dev/null
then
    echo "${TEXT_RED}Nix installation failed or not in PATH. Aborted.${TEXT_RESET}"
    exit 1
fi

# Enable Flakes and nix-command for the current user profile.
mkdir -p "${HOME}/.config/nix"
if ! grep -q '^experimental-features = .*nix-command.*flakes' "${HOME}/.config/nix/nix.conf" 2>/dev/null
then
    echo 'experimental-features = nix-command flakes' >> "${HOME}/.config/nix/nix.conf"
fi

NIX_FLAKE_FLAGS=(
    --extra-experimental-features
    'nix-command flakes'
)

echo "${TEXT_BOLD}Installing packages via Nix Flake from ${DOTFILES_DARWIN_FLAKE}...${TEXT_RESET}"

if [ -d "${DOTFILES_DARWIN_PATH}" ]
then
    echo "Validating flake package..."
    if ! nix build "${DOTFILES_DARWIN_FLAKE}" --no-link "${NIX_FLAKE_FLAGS[@]}"
    then
        echo "${TEXT_RED}Nix package evaluation failed. Aborted.${TEXT_RESET}"
        exit 1
    fi

    for PROFILE_NAME in darwin darwin-packages
    do
        echo "Removing existing profile entry if present: ${PROFILE_NAME}"
        nix profile remove "${PROFILE_NAME}" "${NIX_FLAKE_FLAGS[@]}" > /dev/null 2>&1 || true
    done
    unset PROFILE_NAME

    if ! nix profile add "${DOTFILES_DARWIN_FLAKE}" "${NIX_FLAKE_FLAGS[@]}"
    then
        echo "${TEXT_RED}Failed to add Nix flake profile. Aborted.${TEXT_RESET}"
        exit 1
    fi
else
    echo "${TEXT_RED}Darwin dotfiles path not found at ${DOTFILES_DARWIN_PATH}. Skipping package installation.${TEXT_RESET}"
fi

##
# Aikido Safe Chain
# @see https://github.com/AikidoSec/safe-chain

curl -fsSL https://github.com/AikidoSec/safe-chain/releases/latest/download/install-safe-chain.sh | sh

# Setup default lagunage
#sudo languagesetup

# Done
unset \
    ARCH \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_PATH \
    DOTFILES_REAL_PATH \
    DOTFILES_DARWIN_PATH \
    DOTFILES_DARWIN_FLAKE \
    NIX_FLAKE_FLAGS

unset -f \
    is_older_app \
    is_older_version \
    is_older_os \
    is_specific_serial \
    source_nix
