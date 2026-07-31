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
if [ -d "${DOTFILES_REAL_PATH}/.git" ]
then
    DOTFILES_DARWIN_FLAKE="git+file://${DOTFILES_REAL_PATH}?dir=darwin"
else
    DOTFILES_DARWIN_FLAKE="path:${DOTFILES_REAL_PATH}?dir=darwin"
fi

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

function source_nix () {
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]
    then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]
    then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    fi
}

function download_file () {
    local source_url="${1}"
    local destination_path="${2}"
    local expected_sha256="${3}"

    curl --fail --location --output "${destination_path}" "${source_url}" || return 1

    if [ -n "${expected_sha256}" ]
    then
        printf '%s  %s\n' "${expected_sha256}" "${destination_path}" | shasum -a 256 -c - || return 1
    fi
}

function replace_app_bundle () {
    local source_app_path="${1}"
    local app_name="${2}"
    local destination_directory="${3}"
    local destination_path="${destination_directory}/${app_name}"
    local staging_directory
    local staged_app_path
    local previous_app_path
    local exit_status=0

    if ! mkdir -p "${destination_directory}"
    then
        echo "${TEXT_RED}Failed to create application directory: ${destination_directory}.${TEXT_RESET}"
        return 1
    fi

    # Stage alongside the destination, rather than modifying a running app
    # bundle in place.  The final moves are on the same filesystem, so a
    # process using the old bundle cannot leave the new bundle partially copied.
    if [ "${exit_status}" -eq 0 ]
    then
        staging_directory=$(mktemp -d "${destination_directory}/.${app_name}.bootstrap.XXXXXX") || exit_status=1
        staged_app_path="${staging_directory}/${app_name}"
        previous_app_path="${staging_directory}/previous-${app_name}"
    fi

    # A signed app bundle must not retain Finder metadata or resource forks.
    # The DMG can contain those attributes, so do not copy them into staging.
    if [ "${exit_status}" -eq 0 ] && ! ditto --norsrc "${source_app_path}" "${staged_app_path}"
    then
        echo "${TEXT_RED}Failed to stage ${app_name}.${TEXT_RESET}"
        exit_status=1
    fi

    if [ "${exit_status}" -eq 0 ] && ! codesign --verify --deep --strict "${staged_app_path}"
    then
        echo "${TEXT_RED}Code signature verification failed for ${app_name}.${TEXT_RESET}"
        exit_status=1
    fi

    if [ "${exit_status}" -eq 0 ] && { [ -e "${destination_path}" ] || [ -L "${destination_path}" ]; }
    then
        if ! mv "${destination_path}" "${previous_app_path}"
        then
            echo "${TEXT_RED}Failed to prepare the existing ${app_name} for replacement.${TEXT_RESET}"
            exit_status=1
        elif ! mv "${staged_app_path}" "${destination_path}"
        then
            echo "${TEXT_RED}Failed to replace ${app_name}; restoring the previous version.${TEXT_RESET}"
            if ! mv "${previous_app_path}" "${destination_path}"
            then
                echo "${TEXT_RED}Previous ${app_name} is preserved at ${previous_app_path}.${TEXT_RESET}"
            fi
            exit_status=1
        elif ! rm -rf "${previous_app_path}"
        then
            echo "${TEXT_RED}Installed ${app_name}, but could not remove ${previous_app_path}.${TEXT_RESET}"
        fi
    elif [ "${exit_status}" -eq 0 ] && ! mv "${staged_app_path}" "${destination_path}"
    then
        echo "${TEXT_RED}Failed to install ${app_name}.${TEXT_RESET}"
        exit_status=1
    fi

    if [ -n "${staging_directory:-}" ] && [ -d "${staging_directory}" ] && ! rmdir "${staging_directory}"
    then
        # Retain a non-empty staging directory after a failed replacement so
        # the previous application remains recoverable.
        echo "${TEXT_RED}Retained staging directory: ${staging_directory}.${TEXT_RESET}"
    fi

    return "${exit_status}"
}

function install_dmg_app () {
    local disk_image_path="${1}"
    local app_name="${2}"
    local destination_directory="${3}"
    local install_method="${4}"
    local mount_point
    local source_app_path
    local installer_path
    local exit_status=0

    mount_point=$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-darwin.XXXXXX") || return 1

    if ! hdiutil attach -nobrowse -readonly -mountpoint "${mount_point}" "${disk_image_path}"
    then
        rmdir "${mount_point}"
        return 1
    fi

    if [ -d "${mount_point}/${app_name}" ]
    then
        source_app_path="${mount_point}/${app_name}"
    elif [ -d "${mount_point}/Contents" ]
    then
        # Some DMGs expose the application bundle itself as the mounted volume.
        source_app_path="${mount_point}"
    else
        echo "${TEXT_RED}${app_name} was not found in the mounted disk image.${TEXT_RESET}"
        exit_status=1
    fi

    case "${install_method}" in
        replace)
            if [ "${exit_status}" -eq 0 ] && ! replace_app_bundle "${source_app_path}" "${app_name}" "${destination_directory}"
            then
                exit_status=1
            fi
            ;;
        installer)
            installer_path="${source_app_path}/Contents/MacOS/install"
            if [ "${exit_status}" -eq 0 ] && [ ! -x "${installer_path}" ]
            then
                echo "${TEXT_RED}${app_name} installer was not found in the mounted disk image.${TEXT_RESET}"
                exit_status=1
            elif [ "${exit_status}" -eq 0 ] && ! sudo "${installer_path}"
            then
                exit_status=1
            fi
            ;;
        *)
            echo "${TEXT_RED}Unsupported DMG installation method: ${install_method}.${TEXT_RESET}"
            exit_status=1
            ;;
    esac

    hdiutil detach "${mount_point}" || exit_status=1
    rmdir "${mount_point}" || exit_status=1
    return "${exit_status}"
}

function install_app_cleaner () {
    local version='3.6.8'
    local url="https://freemacsoft.net/downloads/AppCleaner_${version}.zip"
    local archive_path="./AppCleaner_${version}.zip"

    if ! is_older_app ~/Applications/AppCleaner.app "${version}"
    then
        return 0
    fi

    if ! download_file "${url}" "${archive_path}" '' || ! unzip -o -d ~/Applications/ "${archive_path}"
    then
        echo "${TEXT_RED}AppCleaner installation failed.${TEXT_RESET}"
        return 1
    fi
}

function install_docker_desktop () {
    local version='4.84.0'
    local minimum_macos_version='14.0'
    local build='234817'
    local arm64_url="https://desktop.docker.com/mac/main/arm64/${build}/Docker.dmg"
    local arm64_sha256='ed9e93bf2b71c53492eb80ef35e722e131222018cba8157973dfe3bb717952dd'
    local amd64_url="https://desktop.docker.com/mac/main/amd64/${build}/Docker.dmg"
    local amd64_sha256='5e42979b75b13d516e3bfe69b93f134c3a48c76943cba068fd814007f922bf87'
    local url
    local sha256
    local disk_image_path='./Docker.dmg'

    if is_older_os "${minimum_macos_version}"
    then
        echo "${TEXT_RED}Docker Desktop ${version} requires macOS ${minimum_macos_version} or later. Skipping.${TEXT_RESET}"
        return 0
    fi

    if ! is_older_app /Applications/Docker.app "${version}"
    then
        return 0
    fi

    case "${ARCH}" in
        arm64)
            url="${arm64_url}"
            sha256="${arm64_sha256}"
            ;;
        x86_64)
            url="${amd64_url}"
            sha256="${amd64_sha256}"
            ;;
        *)
            echo "${TEXT_RED}Unsupported Docker Desktop architecture: ${ARCH}.${TEXT_RESET}"
            return 1
            ;;
    esac

    # Docker supplies an installer that safely replaces Docker.app.  Copying an
    # active application bundle with ditto can be interrupted by processes
    # using Docker and leaves the existing bundle only partially updated.
    if ! download_file "${url}" "${disk_image_path}" "${sha256}" || ! install_dmg_app "${disk_image_path}" Docker.app /Applications installer
    then
        echo "${TEXT_RED}Docker Desktop installation failed.${TEXT_RESET}"
        return 1
    fi

    open /Applications/Docker.app
}

function install_iterm2 () {
    local version='3.6.11'
    local minimum_macos_version='12.4'
    local url="https://iterm2.com/downloads/stable/iTerm2-${version//./_}.zip"
    local sha256='36e78c5049560eaa8e122224f6652eb4b229c61cd5e7332d6d25b5c36f7398e7'
    local archive_path="./iTerm2-${version//./_}.zip"

    if is_older_os "${minimum_macos_version}"
    then
        echo "${TEXT_RED}iTerm2 ${version} requires macOS ${minimum_macos_version} or later. Skipping.${TEXT_RESET}"
        return 0
    fi

    if ! is_older_app ~/Applications/iTerm.app "${version}"
    then
        return 0
    fi

    if ! download_file "${url}" "${archive_path}" "${sha256}" || ! unzip -o -d ~/Applications/ "${archive_path}"
    then
        echo "${TEXT_RED}iTerm2 installation failed.${TEXT_RESET}"
        return 1
    fi
}

function install_monitor_control () {
    local version='4.3.3'
    local url="https://github.com/MonitorControl/MonitorControl/releases/download/v${version}/MonitorControl.${version}.dmg"
    local disk_image_path="./MonitorControl.${version}.dmg"

    if ! is_older_app ~/Applications/MonitorControl.app "${version}"
    then
        return 0
    fi

    if ! download_file "${url}" "${disk_image_path}" '' || ! install_dmg_app "${disk_image_path}" MonitorControl.app "${HOME}/Applications" replace
    then
        echo "${TEXT_RED}MonitorControl installation failed.${TEXT_RESET}"
        return 1
    fi
}

function install_xquartz () {
    local version='2.8.6'
    local minimum_macos_version='10.13'
    local url="https://github.com/XQuartz/XQuartz/releases/download/XQuartz-${version}/XQuartz-${version}.pkg"
    local sha256='9ac35a505095bfbd3009c3b4772f0c6421e2f79c4210ab908459270d1c447909'
    local package_path="./XQuartz-${version}.pkg"

    if is_older_os "${minimum_macos_version}"
    then
        echo "${TEXT_RED}XQuartz ${version} requires macOS ${minimum_macos_version} or later. Skipping.${TEXT_RESET}"
        return 0
    fi

    if ! is_older_app /Applications/Utilities/XQuartz.app "${version}"
    then
        return 0
    fi

    if ! download_file "${url}" "${package_path}" "${sha256}" || ! sudo installer -pkg "${package_path}" -target /
    then
        echo "${TEXT_RED}XQuartz installation failed.${TEXT_RESET}"
        return 1
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

install_app_cleaner || exit 1
install_docker_desktop || exit 1
install_iterm2 || exit 1
install_monitor_control || exit 1
install_xquartz || exit 1

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
    source_nix \
    download_file \
    replace_app_bundle \
    install_dmg_app \
    install_app_cleaner \
    install_docker_desktop \
    install_iterm2 \
    install_monitor_control \
    install_xquartz
