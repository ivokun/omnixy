#!/usr/bin/env bash

# OmniXY NixOS Installation Script
# This script helps install OmniXY on an existing NixOS system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
     ▄▄▄
 ▄█████▄     ▄████▄    ██▄   ▄██  ██▄  ▄██  ▄██   ▄██    ▄█  ▄█   █▄    ▄█   █▄
███   ███   ███  ███   ███▄ ▄███  ███  ███  ███   ███   ███ ███   ███  ███   ███
███   ███  ███    ███  ████▀████  ███▄▄███  ███▄  ███   ███ ███   ███  ███   ███
███   ███  ███    ███  ███   ███  ████████  █████████   ███ ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███    ███  ███   ███  ███  ███  ███ █████   ███ ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███    ███  ███   ███  ███  ███  ███  ████   ███  ███   ███  ▄██   ███
███   ███   ███  ███   ███   ███  ███  ███  ███   ███   ███  ███   ███  ███   ███
 ▀█████▀     ▀████▀    ███   ███  ███  ███  ███   ███    ▀█  ███   █▀    ▀█████▀

                            NixOS Edition
EOF
    echo -e "${NC}"
}

# Check if running on NixOS
check_nixos() {
    if [ ! -f /etc/NIXOS ]; then
        echo -e "${RED}Error: This installer must be run on a NixOS system${NC}"
        echo "Please install NixOS first: https://nixos.org/download.html"
        exit 1
    fi
}

# Check for root/sudo
check_permissions() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}Warning: Running as root. It's recommended to run as a regular user with sudo access.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Backup existing configuration
backup_config() {
    if [ -d /etc/nixos ]; then
        BACKUP_DIR="/etc/nixos.backup.$(date +%Y%m%d-%H%M%S)"
        echo -e "${BLUE}📦 Backing up existing configuration to $BACKUP_DIR...${NC}"
        sudo cp -r /etc/nixos "$BACKUP_DIR"
        echo -e "${GREEN}✓ Backup complete${NC}"
    fi
}

# Install Omarchy configuration
install_config() {
    echo -e "${BLUE}📝 Installing Omarchy configuration...${NC}"

    # Create nixos directory if it doesn't exist
    sudo mkdir -p /etc/nixos

    # Copy configuration files
    echo "Copying configuration files..."
    sudo cp -r ./* /etc/nixos/

    # Ensure proper permissions
    sudo chown -R root:root /etc/nixos
    sudo chmod 755 /etc/nixos

    echo -e "${GREEN}✓ Configuration files installed${NC}"
}

# Update user in configuration
update_user() {
    read -p "Enter your username (default: user): " USERNAME
    USERNAME=${USERNAME:-user}

    echo -e "${BLUE}👤 Configuring for user: $USERNAME${NC}"

    # Update configuration files with username
    sudo sed -i "s/user = \"user\"/user = \"$USERNAME\"/" /etc/nixos/configuration.nix
    sudo sed -i "s/home.username = \"user\"/home.username = \"$USERNAME\"/" /etc/nixos/home.nix
    sudo sed -i "s|home.homeDirectory = \"/home/user\"|home.homeDirectory = \"/home/$USERNAME\"|" /etc/nixos/home.nix

    echo -e "${GREEN}✓ User configuration updated${NC}"
}

# Select theme
select_theme() {
    echo -e "${BLUE}🎨 Select a theme:${NC}"
    echo "1) Tokyo Night (default)"
    echo "2) Catppuccin"
    echo "3) Gruvbox"
    echo "4) Nord"
    echo "5) Everforest"
    echo "6) Rose Pine"
    echo "7) Kanagawa"

    read -p "Enter choice (1-7): " THEME_CHOICE

    case $THEME_CHOICE in
        2) THEME="catppuccin" ;;
        3) THEME="gruvbox" ;;
        4) THEME="nord" ;;
        5) THEME="everforest" ;;
        6) THEME="rose-pine" ;;
        7) THEME="kanagawa" ;;
        *) THEME="tokyo-night" ;;
    esac

    echo -e "${BLUE}Setting theme to: $THEME${NC}"
    sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$THEME\"/" /etc/nixos/configuration.nix

    echo -e "${GREEN}✓ Theme configured${NC}"
}

# Enable features
configure_features() {
    echo -e "${BLUE}🚀 Configure features:${NC}"

    read -p "Enable Docker support? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sed -i 's/docker = false/docker = true/' /etc/nixos/configuration.nix
    fi

    read -p "Enable gaming support (Steam, Wine)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sed -i 's/gaming = false/gaming = true/' /etc/nixos/configuration.nix
    fi

    echo -e "${GREEN}✓ Features configured${NC}"
}

# Generate hardware configuration if needed
generate_hardware_config() {
    if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
        echo -e "${BLUE}🔧 Generating hardware configuration...${NC}"
        sudo nixos-generate-config --root /
        echo -e "${GREEN}✓ Hardware configuration generated${NC}"
    else
        echo -e "${YELLOW}Hardware configuration already exists, skipping...${NC}"
    fi
}

# Initialize git repository
# init_git() {
#     echo -e "${BLUE}📚 Initializing git repository...${NC}"
# 
#     cd /etc/nixos
# 
#     if [ ! -d .git ]; then
#         sudo git init
#         sudo git add .
#         sudo git commit -m "Initial Omarchy configuration"
#     fi
# 
#     echo -e "${GREEN}✓ Git repository initialized${NC}"
# }

# Build and switch to new configuration
build_system() {
    echo -e "${BLUE}🏗️  Building system configuration...${NC}"
    echo "This may take a while on first run..."

    # Build the system
    sudo nixos-rebuild switch --flake /etc/nixos#omnixy

    echo -e "${GREEN}✓ System built successfully!${NC}"
}

# Post-installation message
show_complete() {
    echo
    echo -e "${GREEN}╭──────────────────────────────────────────╮${NC}"
    echo -e "${GREEN}│     🎉 Omarchy Installation Complete!    │${NC}"
    echo -e "${GREEN}╰──────────────────────────────────────────╯${NC}"
    echo
    echo -e "${BLUE}Quick Start Guide:${NC}"
    echo "  • Run 'omnixy help' for available commands"
    echo "  • Run 'omnixy-theme-list' to see available themes"
    echo "  • Run 'omnixy update' to update your system"
    echo
    echo -e "${BLUE}Key Bindings (Hyprland):${NC}"
    echo "  • Super + Return: Open terminal"
    echo "  • Super + B: Open browser"
    echo "  • Super + D: Application launcher"
    echo "  • Super + Q: Close window"
    echo
    echo -e "${YELLOW}Note: You may need to reboot for all changes to take effect.${NC}"
    echo
    echo "For more information, visit: https://github.com/TheArctesian/omnixy"
}

# Main installation flow
main() {
    show_banner

    echo -e "${BLUE}Welcome to Omarchy NixOS Installer!${NC}"
    echo "This will install Omarchy configuration on your NixOS system."
    echo

    check_nixos
    check_permissions

    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    backup_config
    install_config
    generate_hardware_config
    update_user
    select_theme
    configure_features
    # init_git

    echo
    echo -e "${YELLOW}Ready to build the system. This may take 10-30 minutes.${NC}"
    read -p "Continue? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_system
        show_complete
    else
        echo -e "${YELLOW}Installation paused. To complete, run:${NC}"
        echo "  sudo nixos-rebuild switch --flake /etc/nixos#omnixy"
    fi
}

# Run main function
main "$@"
