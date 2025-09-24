#!/usr/bin/env bash

# OmniXY NixOS Bootstrap Script
# Downloads and installs OmniXY on a fresh NixOS system

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

    echo -e "${BLUE}Welcome to OmniXY NixOS Bootstrap!${NC}"
    echo
    check_nixos

    # Install git if not present
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Installing git...${NC}"
        nix-shell -p git --run true
    fi

    # Use custom repo if specified, otherwise default
    OMNIXY_REPO="${OMNIXY_REPO:-TheArctesian/omnixy}"
    OMNIXY_REF="${OMNIXY_REF:-main}"

    echo -e "${BLUE}Cloning OmniXY from: https://github.com/${OMNIXY_REPO}.git${NC}"

    # Remove existing directory
    rm -rf ~/.local/share/omnixy/

    # Clone repository
    git clone "https://github.com/${OMNIXY_REPO}.git" ~/.local/share/omnixy

    # Use custom branch if specified
    if [[ $OMNIXY_REF != "main" ]]; then
        echo -e "${GREEN}Using branch: $OMNIXY_REF${NC}"
        cd ~/.local/share/omnixy
        git fetch origin "${OMNIXY_REF}" && git checkout "${OMNIXY_REF}"
    fi

    cd ~/.local/share/omnixy

    echo -e "${BLUE}Starting installation...${NC}"
    ./install.sh
}

main "$@"