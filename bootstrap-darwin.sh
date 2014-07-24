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
if ! sudo launchctl list | grep com.apple.locate &> /dev/null
then
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
fi

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

# Apply changes for Autofs
sudo automount -vc


echo "${TEXT_BOLD}Now installing fundamental applications...${TEXT_RESET}"

# Current directory to ~/Downloads
cd ${HOME}/Downloads

# Install ClamXav
if [ ! -d /Applications/ClamXav.app ] && [ 'C02GH2A9DV7M' != $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') ]
then
    curl -L -O http://www.clamxav.com/downloads/ClamXav_2.6.4.dmg
    hdiutil attach ClamXav_2.6.4.dmg
    cp -R /Volumes/ClamXav/ClamXav.app /Applications/
    hdiutil detach /Volumes/ClamXav
fi

# Install XQuartz
if [ ! -d /Applications/Utilities/XQuartz.app ]
then
    curl -L -O http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg
    hdiutil attach XQuartz-2.7.6.dmg
    sudo installer -pkg /Volumes/XQuartz-2.7.6/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.7.6
fi

# Install Asepsis
if ! which asepsisctl &> /dev/null
then
    curl -L -O http://downloads.binaryage.com/Asepsis-1.4.1.dmg
    hdiutil attach Asepsis-1.4.1.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.mpkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# Install TotalTerminal
if [ ! -d /Applications/TotalTerminal.app ]
then
    curl -L -O http://downloads.binaryage.com/TotalTerminal-1.4.11.dmg
    hdiutil attach TotalTerminal-1.4.11.dmg
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

# Install VirtualBox
if [ ! -d /Applications/VirtualBox.app ]
then
    curl -L -O http://download.virtualbox.org/virtualbox/4.3.14/VirtualBox-4.3.14-95030-OSX.dmg
    hdiutil attach VirtualBox-4.3.14-95030-OSX.dmg
    sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
    hdiutil detach /Volumes/VirtualBox
fi

# Install Vagrant
if [ ! -d /Applications/Vagrant ]
then
    curl -L -O https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.dmg
    hdiutil attach vagrant_1.6.3.dmg
    sudo installer -pkg /Volumes/Vagrant/Vagrant.pkg -target /
    hdiutil detach /Volumes/Vagrant
fi

# Install Xamarin Studio
if [ ! -d /Applications/Xamarin\ Studio.app ]
then
    curl -L -O http://download.xamarin.com/Installer/Mac/XamarinInstaller.dmg
    hdiutil attach XamarinInstaller.dmg
    open /Volumes/Xamarin\ Installer/Install\ Xamarin.app
    hdiutil detach /Volumes/Xamarin\ Installer
fi

# Install Unity
if [ ! -d /Applications/Unity ]
then
    curl -L -O http://netstorage.unity3d.com/unity/unity-4.5.2.dmg
    hdiutil attach unity-4.5.2.dmg
    sudo installer -pkg /Volumes/Unity\ Installer/Unity.pkg -target /
    hdiutil detach /Volumes/Unity\ Installer
fi

# Check if QuickLook directory exists
if [ ! -d ${HOME}/Library/QuickLook ]
then
    mkdir -p ${HOME}/Library/QuickLook
fi

# Install QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/qlImageSize.qlgenerator ]
then
    curl -L -O http://repo.whine.fr/qlImageSize.qlgenerator-10.8.zip
    unzip qlImageSize.qlgenerator-10.8.zip -d ${HOME}/Library/QuickLook/
fi

# Install QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/QLStephen.qlgenerator ]
then
    curl -L -O https://github.com/downloads/whomwah/qlstephen/QLStephen.qlgenerator.zip
    unzip QLStephen.qlgenerator.zip -d ${HOME}/Library/QuickLook/
fi

# Restart QuickLook
qlmanage -r

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
fi

unset HOMEBREW

# Add Homebrew 3rd party repositories
TAPS=(
    'homebrew/binary'
    'homebrew/completions'
    'homebrew/dupes'
    'homebrew/versions'
)

for TAP in "${TAPS[@]}"
do
    if ! brew tap | grep ${TAP} &> /dev/null
    then
        brew tap ${TAP}
    fi
done

unset TAP TAPS

# Install fundamental dependencies through Homebrew
brew update
brew upgrade

BREWS=(
    'apple-gcc42'
    'autoconf'
    'automake'
    'bison'
    'ccache'
    'cmake'
    'gem-completion'
    'gettext'
    'git'
    'git-extras'
    'grc'
    'libjpeg'
    'libpng'
    'mcrypt'
    'mercurial'
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

# Install Perl through `plenv` if not exists
if ! which plenv &> /dev/null
then
    PLENV="${HOME}/.plenv"

    if [ ! -d ${PLENV} ]
    then
        git clone git://github.com/tokuhirom/plenv.git ${PLENV}
    else
        cd ${PLENV}
        git pull
        cd ${CWD}
    fi

    export PATH="${PLENV}/bin:${PATH}"
    eval "$(plenv init -)"

    unset PLENV
fi

if ! plenv versions | grep 5.21.0 &> /dev/null
then
    plenv install 5.21.0
fi

plenv global 5.21.0
plenv rehash

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
    eval "$(phpenv init -)"

    unset PHPENV
fi

if ! phpenv versions | grep php-5.5.7 &> /dev/null
then
    CONFIGURE_OPTIONS="--with-jpeg-dir=$(brew --prefix libjpeg) \
                       --with-png-dir=$(brew --prefix libpng) \
                       --with-openssl=$(brew --prefix openssl) \
                       --with-mcrypt=$(brew --prefix mcrypt) \
                       --with-apxs2=/usr/sbin/apxs" \
    phpenv install php-5.5.7
fi

phpenv global system
phpenv rehash

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
    eval "$(pyenv init -)"

    unset PYENV
fi

if ! pyenv versions | grep 2.7.5 &> /dev/null
then
    CFLAGS="-I$(brew --prefix readline)/include" \
    LDFLAGS="-L$(brew --prefix readline)/lib" \
    pyenv install 2.7.5 3.3.2
fi

pyenv global 2.7.5
pyenv rehash

# Install PyPIs
if which pip &> /dev/null
then
    PIPS=(
        'ansible'
        'awscli'
        'fabric'
    )

    for PIP in "${PIPS[@]}"
    do
        FORMULA=$(echo ${PIP} | cut -d ' ' -f 1)
        pip install --upgrade ${FORMULA}
        unset FORMULA
    done

    pyenv rehash

    unset PIPS PIP
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
    eval "$(rbenv init -)"

    unset RBENV
fi

if ! rbenv versions | grep 2.1.2 &> /dev/null
then
    CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) \
                    --with-readline-dir=$(brew --prefix readline)" \
    rbenv install 2.1.2
fi

rbenv global 2.1.2
rbenv rehash

# Install RubyGems
if which gem &> /dev/null
then
    GEMS=(
        'bundler'
        'foreman'
        'gisty'
    )

    for GEM in "${GEMS[@]}"
    do
        FORMULA=$(echo ${GEM} | cut -d ' ' -f 1)
        gem install ${FORMULA}
        unset FORMULA
    done

    rbenv rehash

    unset GEMS
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
    eval "$(nenv init -)"

    unset NENV
fi

if ! nenv versions | grep 0.10.29 &> /dev/null
then
    nenv install 0.10.29
fi

nenv global 0.10.29
nenv rehash

# Install NPMs
if which npm &> /dev/null
then
    NPMS=(
        'bower'
        'coffee-script'
        'grunt-cli'
        'grunt-init'
        'gulp'
        'hubot'
        'LiveScript'
    )

    for NPM in "${NPMS[@]}"
    do
        FORMULA=$(echo ${NPM} | cut -d ' ' -f 1)
        npm install -g ${FORMULA}
        unset FORMULA
    done

    nenv rehash

    unset NPMS NPM
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
