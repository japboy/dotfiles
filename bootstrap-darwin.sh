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

DOTFILES_DARWIN_PATH="${HOME}/.dotfiles/darwin"


##
# Functions

function is_older_app () {
    TARGET_PATH="${1}"
    [ ! -d "${TARGET_PATH}" ] && return 0
    TARGET_VERSION=${2}
    ACTUAL_VERSION=$(mdls -name kMDItemVersion "${TARGET_PATH}" | sed -e 's/^kMDItemVersion = "\([0-9\.]*\)"$/\1/g')
    # TODO: should compare the version sizes
    [ ${TARGET_VERSION} != ${ACTUAL_VERSION} ] && return 0
    return 1
}

function is_older_os () {
    TARGET_VERSION=${1}
    ACTUAL_VERSION=$(system_profiler SPSoftwareDataType | grep 'System Version' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -c -5)
    [ $(echo "${TARGET_VERSION} >= ${ACTUAL_VERSION}" | bc) -eq 1 ] && return 0
    return 1
}

function is_specific_serial () {
    TARGET_SERIAL=${1}
    ACTUAL_SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
    [ ${TARGET_SERIAL} = ${ACTUAL_SERIAL} ] && return 0
    return 1
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
if ! which docker &> /dev/null || [[ '29.0.1' != $(docker --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}') ]]
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


# Check if QuickLook directory exists
if [ ! -d ${HOME}/Library/QuickLook ]
then
    mkdir -p ${HOME}/Library/QuickLook
fi

# QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/qlImageSize.qlgenerator ]
then
    curl -LO https://github.com/Nyx0uf/qlImageSize/releases/download/2.6.1/qlImageSize.qlgenerator.zip
    unzip qlImageSize.qlgenerator.zip -d ${HOME}/Library/QuickLook/
fi

# QuickLook qlstephen
if [ ! -d ${HOME}/Library/QuickLook/QLStephen.qlgenerator ]
then
    curl -LO https://github.com/whomwah/qlstephen/releases/download/1.5.1/QLStephen.qlgenerator.1.5.1.zip
    unzip QLStephen.qlgenerator.1.5.1.zip -d ${HOME}/Library/QuickLook/
fi

# Restart QuickLook
qlmanage -r
qlmanage -r cache

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

# Check if JDK is installed
if ! javac -version &> /dev/null
then
    open "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
    echo "${TEXT_RED}JDK must be installed first. Aborted.${TEXT_RESET}"
    exit 1
fi

# Homebrew if not exists
HOMEBREW="${HOME}/.homebrew"

if ! which brew &> /dev/null
then
    export HOMEBREW_CELLAR="${HOMEBREW}/Cellar"
    export HOMEBREW_PREFIX=${HOMEBREW}
    export PATH="${HOMEBREW}/bin:${PATH}"
fi

if [ ! -d ${HOMEBREW} ]
then
    mkdir -p ${HOMEBREW}
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
fi

unset HOMEBREW

# Add Homebrew 3rd party repositories
TAPS=(
    'universal-ctags/universal-ctags'
    'tkengo/highway'
)

for TAP in "${TAPS[@]}"
do
    if ! brew tap | grep ${TAP} &> /dev/null
    then
        brew tap ${TAP}
    fi
done

unset TAP TAPS

# fundamental dependencies through Homebrew
brew update
brew upgrade

BREWS=(
    'autoconf'
    'automake'
    'cairo'
    'ccache'
    'cmake'
    'direnv'
    'gettext'
    'gh'
    'giflib'
    'git-extras'
    'git'
    'grc'
    'highway'
    'jpeg'
    'libjpeg'
    'libpng'
    'librsvg'
    'libtiff'
    'lua'
    'mcrypt'
    'mise'
    'neovim'
    'ngrok'
    'openssl@1.1'
    'pango'
    'pcre'
    'pkg-config'
    're2c'
    'readline'
    'scons'
    'the_platinum_searcher'
    'the_silver_searcher'
    'trash'
    'universal-ctags --HEAD'
    'webp'
    'xz'
    'zsh-autosuggestions'
    'zsh-completions'
    'zsh-syntax-highlighting'
)

for BREW in "${BREWS[@]}"
do
    FORMULA=$(echo ${BREW} | cut -d ' ' -f 1)

    if ! brew list | grep ${FORMULA} &> /dev/null
    then
        brew install ${BREW}
    fi

    unset FORMULA
done

unset BREW BREWS

brew cleanup

# `mise` for **env
mise use -g deno@latest
mise use -g golang@latest
mise use -g node@latest
mise use -g python@latest
mise use -g ruby@latest
mise use -g rust@latest

##
# Aikido Safe Chain
# @see https://github.com/AikidoSec/safe-chain

curl -fsSL https://raw.githubusercontent.com/AikidoSec/safe-chain/main/install-scripts/install-safe-chain.sh | sh -s -- --include-python
npm install safe-chain-test
pip install safe-chain-pi-test

# Node.js NPMs
if ! which corepack &> /dev/null
then
    npm install -g corepack
fi
# @see https://pnpm.io/installation
# @see https://yarnpkg.com/getting-started/install
corepack enable
corepack prepare pnpm@latest --activate
corepack prepare yarn@stable --activate

# Python PyPIs
if which pip &> /dev/null
then
    PIPS=(
        'neovim'
        'pip'
        'uv'
        'wheel'
    )

    for PIP in "${PIPS[@]}"
    do
        pip install --upgrade ${PIP}
    done

    unset PIPS PIP
fi

# RubyGems
if which gem &> /dev/null
then
    GEMS=(
        'bundler'
        'neovim'
    )

    for GEM in "${GEMS[@]}"
    do
        if ! gem list --local | grep ${GEM} &> /dev/null
        then
            gem install ${GEM}
        else
            gem update ${GEM}
        fi
    done

    gem cleanup

    unset GEMS
fi

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
    DOTFILES_DARWIN_PATH

unset -f \
    is_older_app \
    is_older_os \
    is_specific_serial
