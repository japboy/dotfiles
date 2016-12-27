#!/bin/bash

#
# MAC OS X BOOTSTRAP
#
# This script will be run from `bootstrap.sh` if using Mac OS X


##
# Variables

CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

MAC_SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

DOTFILES_DARWIN_PATH="${HOME}/.dotfiles/darwin"


##
# Functions

function is_older_app () {
    TARGET_PATH="${1}"
    ! [ -d "${TARGET_PATH}" ] && return 1
    TARGET_VERSION=${2}
    ACTUAL_VERSION=$(mdls -name kMDItemVersion "${TARGET_PATH}" | sed -e 's/^kMDItemVersion = "\([0-9\.]*\)"$/\1/g')
    [ ${TARGET_VERSION} != ${ACTUAL_VERSION} ] && return 0
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

echo "${TEXT_BOLD}Now installing login & logout hook scripts...${TEXT_RESET}"

# LoginHook
#if ! sudo defaults read com.apple.loginwindow LoginHook &> /dev/null
#then
#    chmod +x ${DOTFILES_DARWIN_PATH}/loginhook.sh
#    sudo defaults write com.apple.loginwindow LoginHook ${DOTFILES_DARWIN_PATH}/loginhook.sh
#fi

# LogoutHook
#if ! sudo defaults read com.apple.loginwindow LogoutHook &> /dev/null
#then
#    chmod +x ${DOTFILES_DARWIN_PATH}/logouthook.sh
#    sudo defaults write com.apple.loginwindow LogoutHook ${DOTFILES_DARWIN_PATH}/logouthook.sh
#fi

# login scripts using LaunchAgents
if ! [ -L ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist ]
then
    ln -s ${DOTFILES_DARWIN_PATH}/Library/LaunchAgents/com.github.japboy.ramdisk.plist ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist
    launchctl load ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist
fi

echo "${TEXT_BOLD}Now customizing default configuration...${TEXT_RESET}"

# Turn off local Time Machine snapshots
sudo tmutil disablelocal

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

# Apply changes for Autofs
sudo automount -vc

# Create `Applications` directory under the home directory if it doesn't exist
[ ! -d "${HOME}/Applications" ] && mkdir ${HOME}/Applications

# Create `Developer` directory if it doesn't exist
[ ! -d "${HOME}/Developer" ] && mkdir -p ${HOME}/Developer/bin ${HOME}/Developer/etc ${HOME}/Developer/share/man


echo "${TEXT_BOLD}Now installing fundamental applications...${TEXT_RESET}"

# Current directory to ~/Downloads
cd ${HOME}/Downloads

# ClamXav
if is_older_app /Applications/ClamXav.app '2.11' && is_specific_serial 'C02N93B6G3QR'
then
    curl -LO https://www.clamxav.com/downloads/ClamXav_2.11_2835.zip
    unzip -o -d /Applications/ ./ClamXav_2.11_2835.zip
fi

# XQuartz
if is_older_app /Applications/Utilities/XQuartz.app '2.7.11'
then
    curl -LO https://dl.bintray.com/xquartz/downloads/XQuartz-2.7.11.dmg
    hdiutil attach XQuartz-2.7.11.dmg
    sudo installer -pkg /Volumes/XQuartz-2.7.11/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.7.11
fi

# Asepsis
if ! which asepsisctl &> /dev/null || [[ 'asepsisctl 1.5.2' != $(asepsisctl --version) ]]
then
    curl -LO http://downloads.binaryage.com/Asepsis-1.5.2.dmg
    hdiutil attach Asepsis-1.5.2.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.pkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# XtraFinder
if is_older_app /Applications/XtraFinder.app '0.25.9' && is_specific_serial 'C02N93B6G3QR'
then
    curl -LO http://www.trankynam.com/xtrafinder/downloads/XtraFinder.dmg
    hdiutil attach XtraFinder.dmg
    sudo installer -pkg /Volumes/XtraFinder/XtraFinder.pkg -target /
    hdiutil detach /Volumes/XtraFinder
fi

# Docker
if ! which docker &> /dev/null || [[ '1.12.5' != $(docker --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}') ]]
then
    curl -LO https://download.docker.com/mac/stable/Docker.dmg
    hdiutil attach Docker.dmg
    cp -R /Volumes/Docker/Docker.app /Applications/
    hdiutil detach /Volumes/Docker
    open /Applications/Docker.app
fi

# iTerm2
if is_older_app ~/Applications/iTerm.app '3.0.13'
then
    curl -LO https://iterm2.com/downloads/stable/iTerm2-3_0_13.zip
    unzip -o -d ~/Applications/ ./iTerm2-3_0_13.zip
fi

# Visual Studio Code & the plugins
if is_older_app ~/Applications/Visual\ Studio\ Code.app '1.8.1'
then
    curl -L -o ./VSCode-darwin-stable.zip https://go.microsoft.com/fwlink/?LinkID=620882
    unzip -o -d ~/Applications/ ./VSCode-darwin-stable.zip
fi
if which code &> /dev/null
then
    VSCODE_PLUGINS=(
        'EditorConfig.EditorConfig'
        'christian-kohler.path-intellisense'
        'dbaeumer.vscode-eslint'
        'ilich8086.classic-asp'
        'jaydenlin.ctags-support'
        'mrmlnc.vscode-stylefmt'
        'ms-vscode.PowerShell'
        'ms-vscode.csharp'
        'ricard.PostCSS'
        'shinnn.stylelint'
        'vscodevim.vim'
    )
    for PLUGIN in "${VSCODE_PLUGINS[@]}"
    do
        if ! code --list-extensions | grep ${PLUGIN} &> /dev/null
        then
            code --install-extension ${PLUGIN}
        fi
    done
    unset VSCODE_PLUGINS PLUGIN
fi

# AppCleaner
if is_older_app ~/Applications/AppCleaner.app '3.4'
then
    curl -LO https://freemacsoft.net/downloads/AppCleaner_3.4.zip
    unzip -o -d ~/Applications/ ./AppCleaner_3.4.zip
fi

# f.lux
if is_older_app ~/Applications/Flux.app '37.7'
then
    curl -LO https://justgetflux.com/mac/Flux.zip
    unzip -o -d ~/Applications/ ./Flux.zip
fi

# Check if QuickLook directory exists
if [ ! -d ${HOME}/Library/QuickLook ]
then
    mkdir -p ${HOME}/Library/QuickLook
fi

# QuickLook qlImageSize
if [ ! -d /Library/QuickLook/qlImageSize.qlgenerator ]
then
    curl -LO http://repo.whine.fr/qlImageSize.pkg
    sudo installer -pkg ${HOME}/Downloads/qlImageSize.pkg -target /
fi

# QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/QLStephen.qlgenerator ]
then
    curl -LO https://github.com/whomwah/qlstephen/releases/download/1.4.3/QLStephen.qlgenerator.1.4.3.zip
    unzip QLStephen.qlgenerator.1.4.3.zip -d ${HOME}/Library/QuickLook/
fi

# Restart QuickLook
qlmanage -r
qlmanage -r cache

# Reset current working directory
cd ${CWD}


echo "${TEXT_BOLD}Now setting up development environment...${TEXT_RESET}"

# Check if Xcode is installed
if [ ! -d /Applications/Xcode.app ] || ! xcrun --find gcc &> /dev/null
then
    echo "${TEXT_RED}Xcode not found. Aborted.${TEXT_RESET}"
    exit 1
fi

# Setup Xcode
xcodebuild -checkFirstLaunchStatus

# Check if Command Line Tools are installed
if ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &> /dev/null
then
    xcode-select --install
    echo "${TEXT_RED}Xcode Command Line Tools must be installed first. Aborted.${TEXT_RESET}"
    exit 1
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
    export PATH="${HOMEBREW}/bin:${PATH}"
fi

if [ ! -d ${HOMEBREW} ]
then
    mkdir -p ${HOMEBREW}
    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}
fi

unset HOMEBREW

# Add Homebrew 3rd party repositories
TAPS=(
    'homebrew/binary'
    'homebrew/completions'
    'homebrew/dupes'
    'homebrew/versions'
    'neovim/neovim'
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
    'bison'
    'ccache'
    'cmake'
    'gem-completion'
    'gettext'
    'gibo'
    'giflib'
    'git'
    'git-extras'
    'grc'
    'libjpeg'
    'libpng'
    'libtiff'
    'lua --with-completion'
    'mcrypt'
    'mercurial'
    'mono'
    'neovim'
    'openssl'
    'packer'
    'perl-build'
    'pip-completion'
    'pkg-config'
    're2c'
    'readline'
    'rmtrash'
    'ruby-build'
    'scons'
    'vagrant-completion'
    'webp'
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

# `anyenv` for **env
ANYENV="${HOME}/.anyenv"

if ! which anyenv &> /dev/null
then
    if [ ! -d ${ANYENV} ]
    then
        git clone https://github.com/riywo/anyenv ${ANYENV}
        git clone https://github.com/znz/anyenv-update.git ${ANYENV}/plugins/anyenv-update
    fi
    export PATH="${ANYENV}/bin:${PATH}"
    eval "$(anyenv init -)"
    anyenv install plenv
    anyenv install phpenv
    anyenv install pyenv
    anyenv install rbenv
    anyenv install ndenv
    #exec ${SHELL} -l
else
    anyenv update
fi

unset ANYENV

# Perl through `plenv` if not exists
PLVER='5.23.3'

if ! plenv versions | grep ${PLVER} &> /dev/null
then
    plenv install ${PLVER}
fi

plenv global ${PLVER}
plenv rehash

unset PLVER

# PHP through `phpenv` if not exists
PHPVER='system'

if ! phpenv versions | grep php-5.5.7 &> /dev/null
then
    CONFIGURE_OPTIONS="--with-jpeg-dir=$(brew --prefix libjpeg) \
                       --with-png-dir=$(brew --prefix libpng) \
                       --with-openssl=$(brew --prefix openssl) \
                       --with-mcrypt=$(brew --prefix mcrypt) \
                       --with-apxs2=/usr/sbin/apxs" \
    phpenv install php-5.5.7
fi

phpenv global ${PHPVER}
phpenv rehash

unset PHPVER

# Python through `pyenv` if not exists
PYVER='3.6.0'

if ! pyenv versions | grep ${PYVER} &> /dev/null
then
    CFLAGS="-I$(brew --prefix readline)/include" \
    LDFLAGS="-L$(brew --prefix readline)/lib" \
    pyenv install ${PYVER}
fi

pyenv global ${PYVER}
pyenv rehash

unset PYVER

# PyPIs
if which pip &> /dev/null
then
    PIPS=(
        'pip'
        'flake8'
        'neovim'
        'virtualenv'
    )

    for PIP in "${PIPS[@]}"
    do
        pip install --upgrade ${PIP}
    done

    pyenv rehash

    unset PIPS PIP
fi

# Ruby through `rbenv` if not exists
RBVER='2.4.0'

if ! rbenv versions | grep ${RBVER} &> /dev/null
then
    CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) \
                    --with-readline-dir=$(brew --prefix readline)" \
    rbenv install ${RBVER}
fi

rbenv global ${RBVER}
rbenv rehash

unset RBVER

# RubyGems
if which gem &> /dev/null
then
    GEMS=(
        'bundler'
        'gisty'
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
    rbenv rehash

    unset GEMS
fi

# Node.js through `ndenv` if not exists
NDVER='v6.9.2'

if ! ndenv versions | grep ${NDVER} &> /dev/null
then
    ndenv install ${NDVER}
fi

ndenv global ${NDVER}
ndenv rehash

unset NDVER

# NPMs
if which npm &> /dev/null
then
    NPMS=(
        'npm'
        'yo'
    )

    for NPM in "${NPMS[@]}"
    do
        if ! npm list -g | grep ${NPM} &> /dev/null
        then
            npm install -g ${NPM}
        else
            npm update -g ${NPM}
        fi
    done

    ndenv rehash

    unset NPMS NPM
fi

# .NET Core
if ! which dotnet &> /dev/null || [[ '1.0.0-preview2-003177' != $(dotnet --version) ]]
then
    cd ${HOME}/Downloads
    curl -L -o ./dotnet-dev-osx-x64.1.0.0-preview2-003177.pkg https://go.microsoft.com/fwlink/?LinkID=835011
    sudo installer -pkg ./dotnet-dev-osx-x64.1.0.0-preview2-003177.pkg -target /
    cd ${CWD}
fi

# Setup default lagunage
#sudo languagesetup

# Done
unset \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_DARWIN_PATH

unset -f \
    is_older_app \
    is_specific_serial
