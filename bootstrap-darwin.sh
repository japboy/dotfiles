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

DOTFILES_DARWIN_PATH="${HOME}/.dotfiles/darwin"


##
# Main process


echo "${TEXT_BOLD}Now starting Mac OS X optimisation...${TEXT_RESET}"

# Turn off local Time Machine snapshots
sudo tmutil disablelocal

# Enable `locate` command
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# Install LoginHook
if ! sudo defaults read com.apple.loginwindow LoginHook &> /dev/null
then
    sudo defaults write com.apple.loginwindow LoginHook ${DOTFILES_DARWIN_PATH}/hook.sh
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


echo "${TEXT_BOLD}Now installing fundamental applications...${TEXT_RESET}"

# Current directory to ~/Downloads
cd ${HOME}/Downloads

# Install XQuartz
if [ ! -d /Applications/Utilities/XQuartz.app ]
then
    curl -L -O http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.5.dmg
    hdiutil attach XQuartz-2.7.5.dmg
    sudo installer -pkg /Volumes/XQuartz-2.7.5/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.7.5
fi

# Install ClamXav
if [ ! -d /Applications/ClamXav.app ]
then
    curl -L -O http://www.clamxav.com/downloads/ClamXav_2.6.1.dmg
    hdiutil attach ClamXav_2.6.1.dmg
    cp -R /Volumes/ClamXav/ClamXav.app /Applications/
    hdiutil detach /Volumes/ClamXav
fi

# Install Asepsis
if ! which asepsisctl &> /dev/null
then
    curl -L -O http://downloads.binaryage.com/Asepsis-1.4.dmg
    hdiutil attach Asepsis-1.4.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# Install TotalTerminal
if [ ! -d /Applications/TotalTerminal.app ]
then
    curl -L -O http://downloads.binaryage.com/TotalTerminal-1.4.6.dmg
    hdiutil attach TotalTerminal-1.4.6.dmg
    sudo installer -pkg /Volumes/TotalTerminal/TotalTerminal.pkg -target /
    hdiutil detach /Volumes/TotalTerminal
fi

# Install XtraFinder
if [ ! -d /Applications/XtraFinder.app ]
then
    curl -L -O http://www.trankynam.com/xtrafinder/downloads/XtraFinder.dmg
    hdiutil attach XtraFinder.dmg
    sudo installer -pkg /Volumes/XtraFinder/XtraFinder.pkg -target /
    hdiutil detach /Volumes/XtraFinder
fi

# Check if QuickLook directory exists
if [ ! -d ${HOME}/Library/QuickLook ]
then
    mkdir -p ${HOME}/Library/QuickLook
fi

# Install QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/qlImageSize.qlgenerator ]
then
    curl -L -O http://repo.whine.fr/qlImageSize.qlgenerator-10.8.zip && \
    unzip qlImageSize.qlgenerator-10.8.zip -d ${HOME}/Library/QuickLook/
fi

# Install QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/QLStephen.qlgenerator ]
then
    curl -L -O https://github.com/downloads/whomwah/qlstephen/QLStephen.qlgenerator.zip && \
    unzip QLStephen.qlgenerator.zip -d ${HOME}/Library/QuickLook/
fi

# Restart QuickLook
qlmanage -r

# Reset current working directory
cd ${CWD}


echo "${TEXT_BOLD}Now setting up development environment...${TEXT_RESET}"

# Check if Xcode is installed
if [ ! -d /Applications/Xcode.app ] || ! xcrun -find gcc &> /dev/null
then
    echo "${TEXT_RED}Xcode not found. Aborted.${TEXT_RESET}"
    exit 1
fi

# Xcode license agreement
# TODO: Skip if already agreed
sudo xcodebuild -license

# Check if Command Line Tools are installed
if [ ! -d $(xcode-select --print-path) ]
then
    xcode-select --install
fi

# Install Homebrew if not exists
HOMEBREW="${HOME}/.homebrew"

if ! which brew &> /dev/null
then
    export PATH="${HOMEBREW}/bin:${PATH}"
fi

if [ ! -d ${HOMEBREW} ]
then
    mkdir -p ${HOMEBREW}
    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C ${HOMEBREW}

    brew tap homebrew/versions
    brew tap homebrew/dupes
    brew tap josegonzalez/homebrew-php
fi

unset HOMEBREW

# Install fundamental dependencies through Homebrew
brew update
brew upgrade

BREWS=(
    'autoconf'
    'automake'
    'cmake'
    'gcc48'
    'gettext'
    'git'
    'git-extras'
    'grc'
    'libjpeg'
    'libpng'
    'mcrypt'
    'mercurial'
    'openssl'
    'php-build'
    'pkg-config'
    're2c'
    'readline'
    'rmtrash'
    'ruby-build'
    'scons'
    'vim --with-lua --with-mzscheme --with-perl'
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

# Install PHP through `phpenv` if not exists
# MUST be done before `rbenv` installation
if ! which phpenv &> /dev/null
then
    PHPENV="${HOME}/.phpenv"

    if [ ! -d ${PHPENV} ]
    then
        git clone git://github.com/phpenv/phpenv.git ${PHPENV}
    else
        cd ${PHPENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${PHPENV}/bin:${PATH}"

    if [ ! -d ${PHPENV}/versions/5.4.10 ]
    then
        PHP_BUILD_CONFIGURE_OPTS="--with-jpeg-dir=$(brew --prefix libjpeg) \
                                  --with-png-dir=$(brew --prefix libpng) \
                                  --with-openssl=$(brew --prefix openssl) \
                                  --with-mcrypt=$(brew --prefix mcrypt) \
                                  --with-apxs2=/usr/sbin/apxs" \
        php-build 5.4.10 ${PHPENV}/versions/5.4.10
    fi

    phpenv rehash
    phpenv global 5.4.10

    unset PHPENV
fi

# Install Python through `pyenv` if not exists
if ! which pyenv &> /dev/null
then
    PYENV="${HOME}/.pyenv"

    if [ ! -d ${PYENV} ]
    then
        git clone git://github.com/yyuu/pyenv.git ${PYENV}
    else
        cd ${PYENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${PYENV}/bin:${PATH}"

    CFLAGS="-I$(brew --prefix readline)/include" \
    LDFLAGS="-L$(brew --prefix readline)/lib" \
    pyenv install 2.7.5

    pyenv rehash
    pyenv global 2.7.5

    unset PYENV
fi

# Install Ruby through `rbenv` if not exists
if ! which rbenv &> /dev/null
then
    RBENV="${HOME}/.rbenv"

    if [ ! -d ${RBENV} ]
    then
        git clone git://github.com/sstephenson/rbenv.git ${RBENV}
    else
        cd ${RBENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${RBENV}/bin:${PATH}"

    if [ ! -d ${RBENV}/versions/2.0.0-p195 ]
    then
        CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) \
                        --with-readline-dir=$(brew --prefix readline)" \
        ruby-build 2.0.0-p195 ${RBENV}/versions/2.0.0-p195
    fi

    rbenv rehash
    rbenv global 2.0.0-p195

    unset RBENV
fi

# Install Node.js through `nenv` if not exists
if ! which nenv &> /dev/null
then
    NENV="${HOME}/.nenv"

    if [ ! -d ${NENV} ]
    then
        git clone git://github.com/ryuone/nenv.git ${NENV}
    else
        cd ${NENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${NENV}/bin:${PATH}"

    nenv install 0.10.10
    nenv rehash
    nenv global 0.10.10

    unset NENV
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
