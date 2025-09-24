#!/usr/bin/env bash

# Omarchy NixOS Bootstrap Script
# Downloads and installs Omarchy on a fresh NixOS system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
     ▄▄▄
 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀
                                       ███   █▀

                            NixOS Edition
                        Bootstrap Installer
EOF
    echo -e "${NC}"
}

check_nixos() {
    if [ ! -f /etc/NIXOS ]; then
        echo -e "${RED}Error: This script must be run on NixOS${NC}"
        exit 1
    fi
}

main() {
    show_banner

    echo -e "${BLUE}Welcome to Omarchy NixOS Bootstrap!${NC}"
    echo
    check_nixos

    # Install git if not present
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Installing git...${NC}"
        nix-shell -p git --run true
    fi

    # Use custom repo if specified, otherwise default
    OMARCHY_REPO="${OMARCHY_REPO:-yourusername/omarchy-nixos}"
    OMARCHY_REF="${OMARCHY_REF:-main}"

    echo -e "${BLUE}Cloning Omarchy from: https://github.com/${OMARCHY_REPO}.git${NC}"

    # Remove existing directory
    rm -rf ~/.local/share/omarchy-nixos/

    # Clone repository
    git clone "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy-nixos

    # Use custom branch if specified
    if [[ $OMARCHY_REF != "main" ]]; then
        echo -e "${GREEN}Using branch: $OMARCHY_REF${NC}"
        cd ~/.local/share/omarchy-nixos
        git fetch origin "${OMARCHY_REF}" && git checkout "${OMARCHY_REF}"
    fi

    cd ~/.local/share/omarchy-nixos

    echo -e "${BLUE}Starting installation...${NC}"
    ./install.sh
}

main "$@"