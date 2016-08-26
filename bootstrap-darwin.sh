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

echo "${TEXT_BOLD}Now installing login & logout hook scripts...${TEXT_RESET}"

# Install LoginHook
#if ! sudo defaults read com.apple.loginwindow LoginHook &> /dev/null
#then
#    chmod +x ${DOTFILES_DARWIN_PATH}/loginhook.sh
#    sudo defaults write com.apple.loginwindow LoginHook ${DOTFILES_DARWIN_PATH}/loginhook.sh
#fi

# Install LogoutHook
#if ! sudo defaults read com.apple.loginwindow LogoutHook &> /dev/null
#then
#    chmod +x ${DOTFILES_DARWIN_PATH}/logouthook.sh
#    sudo defaults write com.apple.loginwindow LogoutHook ${DOTFILES_DARWIN_PATH}/logouthook.sh
#fi

# Install login scripts using LaunchAgents
if ! [ -L ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist ]
then
    ln -s ${DOTFILES_DARWIN_PATH}/Library/LaunchAgents/com.github.japboy.ramdisk.plist ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist
    launchctl load ${HOME}/Library/LaunchAgents/com.github.japboy.ramdisk.plist
fi

echo "${TEXT_BOLD}Now customizing default configuration...${TEXT_RESET}"

# Turn off local Time Machine snapshots
sudo tmutil disablelocal

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

# Install ClamXav
if [[ ! -d /Applications/ClamXav.app || 'kMDItemVersion = "2.9.2"' != $(mdls -name kMDItemVersion /Applications/ClamXav.app) ]] && [ 'C02NN0VDG3QR' != $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') ]
then
    curl -LO https://www.clamxav.com/downloads/ClamXav_2.9.2_2478.zip
    unzip -o -d /Applications/ ./ClamXav_2.9.2_2478.zip
fi

# Install XQuartz
if [[ ! -d /Applications/Utilities/XQuartz.app || 'kMDItemVersion = "2.7.8"' != $(mdls -name kMDItemVersion /Applications/Utilities/XQuartz.app) ]]
then
    curl -LO http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.8.dmg
    hdiutil attach XQuartz-2.7.8.dmg
    sudo installer -pkg /Volumes/XQuartz-2.7.8/XQuartz.pkg -target /
    hdiutil detach /Volumes/XQuartz-2.7.8
fi

# Install Asepsis
if ! which asepsisctl &> /dev/null || [[ 'asepsisctl 1.5.2' != $(asepsisctl --version) ]]
then
    curl -LO http://downloads.binaryage.com/Asepsis-1.5.2.dmg
    hdiutil attach Asepsis-1.5.2.dmg
    sudo installer -pkg /Volumes/Asepsis/Asepsis.pkg -target /
    hdiutil detach /Volumes/Asepsis
fi

# Install XtraFinder
if [[ ! -d /Applications/XtraFinder.app || 'kMDItemVersion = "0.25.9"' != $(mdls -name kMDItemVersion /Applications/XtraFinder.app) ]]
then
    curl -LO http://www.trankynam.com/xtrafinder/downloads/XtraFinder.dmg
    hdiutil attach XtraFinder.dmg
    sudo installer -pkg /Volumes/XtraFinder/XtraFinder.pkg -target /
    hdiutil detach /Volumes/XtraFinder
fi

# Install Native Docker
if ! which docker &> /dev/null || [[ '1.12.0' != $(docker --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}') ]]
then
    curl -LO https://download.docker.com/mac/stable/Docker.dmg
    hdiutil attach Docker.dmg
    cp -R /Volumes/Docker/Docker.app /Applications/
    hdiutil detach /Volumes/Docker
fi
if [ ! -f ${HOME}/Developer/etc/bash_completion.d/docker ]
then
    DEST=${HOME}/Developer/etc/bash_completion.d
    mkdir -p ${DEST}
    DOCKER_VERSION=$(docker --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}')
    DOCKER_COMPOSE_VERSION=$(docker-compose --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}')
    DOCKER_MACHINE_VERSION=$(docker-machine --version | tr -ds ',' ' ' | awk 'NR==1{print $(3)}')
    curl -L https://raw.githubusercontent.com/docker/docker/v${DOCKER_VERSION}/contrib/completion/bash/docker > ${DEST}/docker
    curl -L https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose > ${DEST}/docker-compose
    curl -L https://raw.githubusercontent.com/docker/machine/v${DOCKER_MACHINE_VERSION}/contrib/completion/bash/docker-machine.bash > ${DEST}/docker-machine
    curl -L https://raw.githubusercontent.com/docker/machine/v${DOCKER_MACHINE_VERSION}/contrib/completion/bash/docker-machine-wrapper.bash > ${DEST}/docker-machine-wrapper
    curl -L https://raw.githubusercontent.com/docker/machine/v${DOCKER_MACHINE_VERSION}/contrib/completion/bash/docker-machine-prompt.bash > ${DEST}/docker-machine-prompt
    unset DEST DOCKER_VERSION DOCKER_COMPOSE_VERSION DOCKER_MACHINE_VERSION
fi

# Install iTerm2
if [[ ! -d ~/Applications/iTerm.app || 'kMDItemVersion = "3.0.7"' != $(mdls -name kMDItemVersion ~/Applications/iTerm.app) ]]
then
    curl -LO https://iterm2.com/downloads/stable/iTerm2-3_0_7.zip
    unzip -o -d ~/Applications/ ./iTerm2-3_0_7.zip
fi

# Install Visual Studio Code
if [[ ! -d ~/Applications/Visual\ Studio\ Code.app || 'kMDItemVersion = "1.4.0"' != $(mdls -name kMDItemVersion ~/Applications/Visual\ Studio\ Code.app) ]]
then
    curl -L -o ./VSCode-darwin-stable.zip https://go.microsoft.com/fwlink/?LinkID=620882
    unzip -o -d ~/Applications/ ./VSCode-darwin-stable.zip
fi

# Install AppCleaner
if [[ ! -d ~/Applications/AppCleaner.app || 'kMDItemVersion = "3.3"' != $(mdls -name kMDItemVersion ~/Applications/AppCleaner.app) ]]
then
    curl -LO https://freemacsoft.net/downloads/AppCleaner_3.3.zip
    unzip -o -d ~/Applications/ ./AppCleaner_3.3.zip
fi

# Install f.lux
if [[ ! -d ~/Applications/Flux.app || 'kMDItemVersion = "37.7"' != $(mdls -name kMDItemVersion ~/Applications/Flux.app) ]]
then
    curl -LO https://justgetflux.com/mac/Flux.zip
    unzip -o -d ~/Applications/ ./Flux.zip
fi

# Check if QuickLook directory exists
if [ ! -d ${HOME}/Library/QuickLook ]
then
    mkdir -p ${HOME}/Library/QuickLook
fi

# Install QuickLook qlImageSize
if [ ! -d /Library/QuickLook/qlImageSize.qlgenerator ]
then
    curl -LO http://repo.whine.fr/qlImageSize.pkg
    sudo installer -pkg ${HOME}/Downloads/qlImageSize.pkg -target /
fi

# Install QuickLook qlImageSize
if [ ! -d ${HOME}/Library/QuickLook/QLStephen.qlgenerator ]
then
    curl -LO https://github.com/whomwah/qlstephen/releases/download/1.4.2/QLStephen.qlgenerator.1.4.2.zip
    unzip QLStephen.qlgenerator.1.4.2.zip -d ${HOME}/Library/QuickLook/
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

# Install fundamental dependencies through Homebrew
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

# Install `anyenv` for **env
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
    exec ${SHELL} -l
else
    anyenv update
fi

unset ANYENV

# Install Perl through `plenv` if not exists
PLVER='5.23.3'

if ! plenv versions | grep ${PLVER} &> /dev/null
then
    plenv install ${PLVER}
fi

plenv global ${PLVER}
plenv rehash

unset PLVER

# Install PHP through `phpenv` if not exists
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

# Install Python through `pyenv` if not exists
PYVER='2.7.12'

if ! pyenv versions | grep ${PYVER} &> /dev/null
then
    CFLAGS="-I$(brew --prefix readline)/include" \
    LDFLAGS="-L$(brew --prefix readline)/lib" \
    pyenv install ${PYVER}
fi

pyenv global ${PYVER}
pyenv rehash

unset PYVER

# Install PyPIs
if which pip &> /dev/null
then
    PIPS=(
        'pip'
        'awscli'
        'fabric'
        'flake8'
        'neovim'
        'sphinx'
        'virtualenv'
    )

    for PIP in "${PIPS[@]}"
    do
        pip install --upgrade ${PIP}
    done

    pyenv rehash

    unset PIPS PIP
fi

# Install Ruby through `rbenv` if not exists
RBVER='2.3.1'

if ! rbenv versions | grep ${RBVER} &> /dev/null
then
    CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) \
                    --with-readline-dir=$(brew --prefix readline)" \
    rbenv install ${RBVER}
fi

rbenv global ${RBVER}
rbenv rehash

unset RBVER

# Install RubyGems
if which gem &> /dev/null
then
    GEMS=(
        'bundler'
        'foreman'
        'gisty'
        'mdl'
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

# Install Node.js through `ndenv` if not exists
NDVER='v6.4.0'

if ! ndenv versions | grep ${NDVER} &> /dev/null
then
    ndenv install ${NDVER}
fi

ndenv global ${NDVER}
ndenv rehash

unset NDVER

# Install NPMs
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

# Install .NET Core
if ! which dotnet &> /dev/null || [[ '1.0.0-preview2-003121' != $(dotnet --version) ]]
then
    cd ${HOME}/Downloads
    curl -L -o ./dotnet-dev-osx-x64.1.0.0-preview2-003121.pkg https://go.microsoft.com/fwlink/?LinkID=809124
    sudo installer -pkg ./dotnet-dev-osx-x64.1.0.0-preview2-003121.pkg -target /
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
