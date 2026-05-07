#!/bin/bash

#
# WSL BOOTSTRAP
#
# This script installs Nix and sets up the environment using Flakes.

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_PATH="${HOME}/.dotfiles"
LINUX_DOTFILES_PATH="${DOTFILES_PATH}/linux"

echo "${TEXT_BOLD}Starting WSL Bootstrap with Nix Flakes...${TEXT_RESET}"

# 1. Install Nix (Official Single-user installation)
# @see https://nixos.org/manual/nix/stable/#sect-single-user-installation

# Try to source existing Nix first to avoid redundant installation attempts
if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]
then
    source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

if ! command -v nix &> /dev/null
then
    echo "${TEXT_BOLD}Installing Nix via official installer...${TEXT_RESET}"
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

    # Source nix for the current session
    if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]
    then
        source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    fi
fi

if ! command -v nix &> /dev/null
then
    echo "${TEXT_RED}Nix installation failed or not in PATH. Aborted.${TEXT_RESET}"
    exit 1
fi

# 2. Configure Nix (Enable Flakes and nix-command)
echo "${TEXT_BOLD}Configuring Nix (enabling Flakes)...${TEXT_RESET}"
mkdir -p "${HOME}/.config/nix"
if ! grep -q "experimental-features" "${HOME}/.config/nix/nix.conf" 2>/dev/null
then
    echo "experimental-features = nix-command flakes" >> "${HOME}/.config/nix/nix.conf"
fi

# 3. Install packages via Nix Flake
echo "${TEXT_BOLD}Installing packages via Nix Flake from ${LINUX_DOTFILES_PATH}...${TEXT_RESET}"

# We install or upgrade the default package from the flake located in the linux directory
if [ -d "${LINUX_DOTFILES_PATH}" ]
then
    if nix profile list --extra-experimental-features "nix-command flakes" | grep -q 'Name:.*linux'
    then
        echo "Flake already added. Upgrading..."
        nix profile upgrade linux --extra-experimental-features "nix-command flakes"
    else
        nix profile add "${LINUX_DOTFILES_PATH}" --extra-experimental-features "nix-command flakes"
    fi
else
    echo "${TEXT_RED}Linux dotfiles path not found at ${LINUX_DOTFILES_PATH}. Skipping package installation.${TEXT_RESET}"
fi

echo "${TEXT_BOLD}${TEXT_GREEN}WSL Nix Bootstrap completed.${TEXT_RESET}"
