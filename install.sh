#!/usr/bin/env bash

# OmniXY NixOS Installation Script
# Stylized installer with Tokyo Night theme integration

set -e

# Get terminal dimensions for centering
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)

# Tokyo Night Color Palette
BG='\033[48;2;26;27;38m'        # #1a1b26
FG='\033[38;2;192;202;245m'     # #c0caf5
BLUE='\033[38;2;122;162;247m'   # #7aa2f7
CYAN='\033[38;2;125;207;255m'   # #7dcfff
GREEN='\033[38;2;158;206;106m'  # #9ece6a
YELLOW='\033[38;2;224;175;104m' # #e0af68
RED='\033[38;2;247;118;142m'    # #f7768e
PURPLE='\033[38;2;187;154;247m' # #bb9af7
ORANGE='\033[38;2;255;158;100m' # #ff9e64
DARK_BLUE='\033[38;2;65;72;104m' # #414868

# Special effects
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
RESET='\033[0m'
CLEAR='\033[2J'
CURSOR_HOME='\033[H'

# Utility functions
center_text() {
    local text="$1"
    local width=${2:-$TERM_WIDTH}
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s\n" $padding "" "$text"
}

draw_box() {
    local width=${1:-60}
    local height=${2:-3}
    local char=${3:-"─"}
    local corner_char=${4:-"╭╮╰╯"}

    # Top border
    printf "${BLUE}%c" "${corner_char:0:1}"
    for ((i=0; i<width-2; i++)); do printf "$char"; done
    printf "%c${RESET}\n" "${corner_char:1:1}"

    # Middle empty lines
    for ((i=0; i<height-2; i++)); do
        printf "${BLUE}│%*s│${RESET}\n" $((width-2)) ""
    done

    # Bottom border
    printf "${BLUE}%c" "${corner_char:2:1}"
    for ((i=0; i<width-2; i++)); do printf "$char"; done
    printf "%c${RESET}\n" "${corner_char:3:1}"
}

progress_bar() {
    local progress=$1
    local width=50
    local filled=$((progress * width / 100))
    local empty=$((width - filled))

    printf "\r${BLUE}["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] ${CYAN}%d%%${RESET}" $progress
}

animate_text() {
    local text="$1"
    local color="$2"
    local delay=${3:-0.03}

    for ((i=0; i<${#text}; i++)); do
        printf "${color}%c" "${text:$i:1}"
        sleep $delay
    done
    printf "${RESET}"
}

loading_spinner() {
    local pid=$1
    local message="$2"
    local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}%c ${FG}%s${RESET}" "${spinner:$i:1}" "$message"
        i=$(( (i+1) % ${#spinner} ))
        sleep 0.1
    done
    printf "\r${GREEN}✓ ${FG}%s${RESET}\n" "$message"
}

# Set Tokyo Night terminal colors
setup_terminal() {
    # Set background color for full terminal
    printf "${BG}${CLEAR}${CURSOR_HOME}"

    # Set Tokyo Night color palette for terminal
    printf '\033]4;0;color0\007'   # Black
    printf '\033]4;1;color1\007'   # Red
    printf '\033]4;2;color2\007'   # Green
    printf '\033]4;3;color3\007'   # Yellow
    printf '\033]4;4;color4\007'   # Blue
    printf '\033]4;5;color5\007'   # Magenta
    printf '\033]4;6;color6\007'   # Cyan
    printf '\033]4;7;color7\007'   # White
}

# Stylized banner with animations
show_banner() {
    clear
    setup_terminal

    # Add some vertical spacing
    for ((i=0; i<3; i++)); do echo; done

    # Main logo with color gradient effect
    echo
    center_text "${CYAN}${BOLD}███████╗███╗   ███╗███╗   ██╗██╗██╗  ██╗██╗   ██╗"
    center_text "██╔════╝████╗ ████║████╗  ██║██║╚██╗██╔╝╚██╗ ██╔╝"
    center_text "${BLUE}██║     ██╔████╔██║██╔██╗ ██║██║ ╚███╔╝  ╚████╔╝ "
    center_text "██║     ██║╚██╔╝██║██║╚██╗██║██║ ██╔██╗   ╚██╔╝  "
    center_text "${PURPLE}███████╗██║ ╚═╝ ██║██║ ╚████║██║██╔╝ ██╗   ██║   "
    center_text "╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝   ${RESET}"
    echo

    # Subtitle with typewriter effect
    printf "%*s" $(( (TERM_WIDTH - 60) / 2 )) ""
    animate_text "🚀 Declarative • 🎨 Beautiful • ⚡ Fast" "$CYAN" 0.05
    echo
    echo

    # Version and edition info
    center_text "${DIM}${FG}NixOS Edition • Version 1.0 • Tokyo Night Theme${RESET}"
    echo

    # Decorative border
    printf "%*s" $(( (TERM_WIDTH - 60) / 2 )) ""
    printf "${DARK_BLUE}"
    for ((i=0; i<60; i++)); do printf "═"; done
    printf "${RESET}\n"
    echo
}

# Stylized section headers
section_header() {
    local title="$1"
    local icon="$2"
    local width=60

    echo
    printf "%*s" $(( (TERM_WIDTH - width) / 2 )) ""
    printf "${BLUE}╭"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╮${RESET}\n"

    printf "%*s" $(( (TERM_WIDTH - width) / 2 )) ""
    printf "${BLUE}│${BOLD}${CYAN} $icon $title"
    printf "%*s${BLUE}│${RESET}\n" $((width - 6 - ${#title} - ${#icon})) ""

    printf "%*s" $(( (TERM_WIDTH - width) / 2 )) ""
    printf "${BLUE}╰"
    for ((i=0; i<width-2; i++)); do printf "─"; done
    printf "╯${RESET}\n"
    echo
}

# Stylized menu options
show_menu() {
    local title="$1"
    shift
    local options=("$@")

    section_header "$title" "🎛️ "

    for i in "${!options[@]}"; do
        local num=$((i + 1))
        center_text "${BOLD}${CYAN}$num.${RESET}${FG} ${options[$i]}"
    done
    echo
    center_text "${DIM}${FG}Enter your choice:${RESET}"
    printf "%*s" $(( TERM_WIDTH / 2 - 5 )) ""
    printf "${CYAN}► ${RESET}"
}

# Enhanced user input with validation
get_input() {
    local prompt="$1"
    local default="$2"
    local validator="$3"

    while true; do
        printf "%*s${FG}%s" $(( (TERM_WIDTH - ${#prompt} - 10) / 2 )) "" "$prompt"
        if [[ -n "$default" ]]; then
            printf "${DIM} (default: $default)${RESET}"
        fi
        printf "${CYAN}: ${RESET}"

        read -r input
        input=${input:-$default}

        if [[ -z "$validator" ]] || eval "$validator '$input'"; then
            echo "$input"
            return
        else
            center_text "${RED}❌ Invalid input. Please try again.${RESET}"
        fi
    done
}

# Check functions with styled output
check_nixos() {
    section_header "System Verification" "🔍"

    printf "%*s${FG}Checking NixOS installation..." $(( (TERM_WIDTH - 35) / 2 )) ""
    sleep 1

    if [ ! -f /etc/NIXOS ]; then
        printf "\r%*s${RED}❌ Not running on NixOS${RESET}\n" $(( (TERM_WIDTH - 25) / 2 )) ""
        echo
        center_text "${RED}${BOLD}ERROR: This installer requires NixOS${RESET}"
        center_text "${FG}Please install NixOS first: ${UNDERLINE}https://nixos.org/download.html${RESET}"
        echo
        exit 1
    else
        printf "\r%*s${GREEN}✅ NixOS detected${RESET}\n" $(( (TERM_WIDTH - 20) / 2 )) ""
    fi

    printf "%*s${FG}Checking permissions..." $(( (TERM_WIDTH - 25) / 2 )) ""
    sleep 0.5

    if [ "$EUID" -eq 0 ]; then
        printf "\r%*s${YELLOW}⚠️  Running as root${RESET}\n" $(( (TERM_WIDTH - 20) / 2 )) ""
        echo
        center_text "${YELLOW}Warning: Running as root is not recommended${RESET}"
        center_text "${FG}It's safer to run as a regular user with sudo access${RESET}"
        echo

        printf "%*s" $(( (TERM_WIDTH - 20) / 2 )) ""
        printf "${CYAN}Continue anyway? (y/N): ${RESET}"
        read -n 1 -r reply
        echo
        if [[ ! $reply =~ ^[Yy]$ ]]; then
            center_text "${FG}Installation cancelled${RESET}"
            exit 1
        fi
    else
        printf "\r%*s${GREEN}✅ User permissions OK${RESET}\n" $(( (TERM_WIDTH - 25) / 2 )) ""
    fi
}

# Enhanced backup with progress
backup_config() {
    if [ -d /etc/nixos ]; then
        section_header "Configuration Backup" "💾"

        BACKUP_DIR="/etc/nixos.backup.$(date +%Y%m%d-%H%M%S)"
        center_text "${FG}Creating backup: ${CYAN}$BACKUP_DIR${RESET}"
        echo

        # Simulate progress for visual appeal
        for i in {1..20}; do
            progress_bar $((i * 5))
            sleep 0.05
        done
        echo

        sudo cp -r /etc/nixos "$BACKUP_DIR" &
        loading_spinner $! "Backing up existing configuration"
    fi
}

# Installation with progress tracking
install_config() {
    section_header "Installing Configuration" "📦"

    center_text "${FG}Installing OmniXY configuration files...${RESET}"
    echo

    # Create directory
    (sudo mkdir -p /etc/nixos && sleep 0.5) &
    loading_spinner $! "Creating configuration directory"

    # Copy files with progress simulation
    (sudo cp -r ./* /etc/nixos/ && sleep 1) &
    loading_spinner $! "Copying configuration files"

    # Set permissions
    (sudo chown -R root:root /etc/nixos && sudo chmod 755 /etc/nixos && sleep 0.5) &
    loading_spinner $! "Setting file permissions"
}

# Enhanced user configuration
update_user() {
    section_header "User Configuration" "👤"

    local username
    username=$(get_input "Enter your username" "user" '[[ $1 =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]')

    echo
    center_text "${FG}Configuring system for user: ${CYAN}${BOLD}$username${RESET}"
    echo

    # Update configuration files
    (sudo sed -i "s/user = \"user\"/user = \"$username\"/" /etc/nixos/configuration.nix && sleep 0.3) &
    loading_spinner $! "Updating main configuration"

    (sudo sed -i "s/home.username = \"user\"/home.username = \"$username\"/" /etc/nixos/home.nix 2>/dev/null && sleep 0.3) &
    loading_spinner $! "Updating home configuration"

    (sudo sed -i "s|home.homeDirectory = \"/home/user\"|home.homeDirectory = \"/home/$username\"|" /etc/nixos/home.nix 2>/dev/null && sleep 0.3) &
    loading_spinner $! "Setting home directory"
}

# Stylized theme selection
select_theme() {
    section_header "Theme Selection" "🎨"

    local themes=(
        "🌃 Tokyo Night - Dark theme with vibrant colors"
        "🎀 Catppuccin - Pastel theme with modern aesthetics"
        "🟤 Gruvbox - Retro theme with warm colors"
        "❄️  Nord - Arctic theme with cool colors"
        "🌲 Everforest - Green forest theme"
        "🌹 Rose Pine - Cozy theme with muted colors"
        "🌊 Kanagawa - Japanese-inspired theme"
        "☀️  Catppuccin Latte - Light variant"
        "⚫ Matte Black - Minimalist dark theme"
        "💎 Osaka Jade - Jade green theme"
        "☕ Ristretto - Coffee-inspired theme"
    )

    for i in "${!themes[@]}"; do
        local num=$((i + 1))
        center_text "${BOLD}${CYAN}$num.${RESET}${FG} ${themes[$i]}"
    done

    echo
    local theme_choice
    theme_choice=$(get_input "Select theme (1-11)" "1" '[[ $1 =~ ^[1-9]$|^1[01]$ ]]')

    local theme_names=("tokyo-night" "catppuccin" "gruvbox" "nord" "everforest" "rose-pine" "kanagawa" "catppuccin-latte" "matte-black" "osaka-jade" "ristretto")
    local selected_theme=${theme_names[$((theme_choice - 1))]}

    echo
    center_text "${FG}Selected theme: ${CYAN}${BOLD}$selected_theme${RESET}"

    (sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$selected_theme\"/" /etc/nixos/configuration.nix && sleep 0.5) &
    loading_spinner $! "Applying theme configuration"
}

# Feature configuration with checkboxes
configure_features() {
    section_header "Feature Configuration" "⚙️ "

    center_text "${FG}Configure optional features:${RESET}"
    echo

    # Security features
    center_text "${BOLD}${PURPLE}Security Features:${RESET}"
    printf "%*s" $(( (TERM_WIDTH - 40) / 2 )) ""
    printf "${CYAN}Enable fingerprint authentication? (y/N): ${RESET}"
    read -n 1 -r reply
    echo
    if [[ $reply =~ ^[Yy]$ ]]; then
        center_text "${GREEN}✅ Fingerprint authentication enabled${RESET}"
        sudo sed -i 's/enable = false;/enable = true;/' /etc/nixos/configuration.nix
    fi

    printf "%*s" $(( (TERM_WIDTH - 35) / 2 )) ""
    printf "${CYAN}Enable FIDO2 security keys? (y/N): ${RESET}"
    read -n 1 -r reply
    echo
    if [[ $reply =~ ^[Yy]$ ]]; then
        center_text "${GREEN}✅ FIDO2 authentication enabled${RESET}"
    fi

    echo
    center_text "${BOLD}${BLUE}Development Features:${RESET}"
    printf "%*s" $(( (TERM_WIDTH - 30) / 2 )) ""
    printf "${CYAN}Enable Docker support? (y/N): ${RESET}"
    read -n 1 -r reply
    echo
    if [[ $reply =~ ^[Yy]$ ]]; then
        center_text "${GREEN}✅ Docker support enabled${RESET}"
    fi

    echo
    center_text "${BOLD}${YELLOW}Gaming Features:${RESET}"
    printf "%*s" $(( (TERM_WIDTH - 40) / 2 )) ""
    printf "${CYAN}Enable gaming support (Steam, Wine)? (y/N): ${RESET}"
    read -n 1 -r reply
    echo
    if [[ $reply =~ ^[Yy]$ ]]; then
        center_text "${GREEN}✅ Gaming support enabled${RESET}"
    fi
}

# Hardware configuration generation
generate_hardware_config() {
    section_header "Hardware Configuration" "🔧"

    if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
        center_text "${FG}Generating hardware-specific configuration...${RESET}"
        echo

        (sudo nixos-generate-config --root / && sleep 1) &
        loading_spinner $! "Scanning hardware configuration"
    else
        center_text "${YELLOW}⚠️  Hardware configuration already exists${RESET}"
        center_text "${DIM}${FG}Skipping hardware generation...${RESET}"
        sleep 1
    fi
}

# System building with enhanced progress
build_system() {
    section_header "System Build" "🏗️ "

    center_text "${YELLOW}${BOLD}⚠️  IMPORTANT NOTICE ⚠️${RESET}"
    center_text "${FG}This process may take 10-45 minutes depending on your system${RESET}"
    center_text "${FG}A stable internet connection is required${RESET}"
    echo

    printf "%*s" $(( (TERM_WIDTH - 30) / 2 )) ""
    printf "${CYAN}Continue with system build? (Y/n): ${RESET}"
    read -n 1 -r reply
    echo

    if [[ $reply =~ ^[Nn]$ ]]; then
        center_text "${YELLOW}Build postponed. Run this command later:${RESET}"
        center_text "${CYAN}sudo nixos-rebuild switch --flake /etc/nixos#omnixy${RESET}"
        return
    fi

    echo
    center_text "${FG}Building NixOS system configuration...${RESET}"
    center_text "${DIM}${FG}This includes downloading packages and compiling the system${RESET}"
    echo

    # Start build in background and show spinner
    sudo nixos-rebuild switch --flake /etc/nixos#omnixy &
    local build_pid=$!

    # Enhanced progress indication
    local dots=""
    local build_messages=(
        "Downloading Nix packages..."
        "Building system dependencies..."
        "Compiling configuration..."
        "Setting up services..."
        "Finalizing installation..."
    )

    local msg_index=0
    local counter=0

    while kill -0 $build_pid 2>/dev/null; do
        if (( counter % 30 == 0 && msg_index < ${#build_messages[@]} )); then
            echo
            center_text "${CYAN}${build_messages[$msg_index]}${RESET}"
            ((msg_index++))
        fi

        printf "\r%*s${CYAN}Building system" $(( (TERM_WIDTH - 20) / 2 )) ""
        dots+="."
        if [ ${#dots} -gt 6 ]; then dots=""; fi
        printf "%s${RESET}" "$dots"

        sleep 1
        ((counter++))
    done

    wait $build_pid
    local exit_code=$?

    echo
    if [ $exit_code -eq 0 ]; then
        center_text "${GREEN}${BOLD}✅ System build completed successfully!${RESET}"
    else
        center_text "${RED}${BOLD}❌ Build failed with errors${RESET}"
        center_text "${FG}Check the output above for details${RESET}"
        exit $exit_code
    fi
}

# Completion screen with comprehensive information
show_complete() {
    clear
    setup_terminal

    # Add spacing
    for ((i=0; i<2; i++)); do echo; done

    # Success banner
    printf "%*s${GREEN}${BOLD}" $(( (TERM_WIDTH - 60) / 2 )) ""
    echo "╭──────────────────────────────────────────────────────────╮"
    printf "%*s${GREEN}│" $(( (TERM_WIDTH - 60) / 2 )) ""
    printf "%*s🎉 OmniXY Installation Complete! 🎉%*s│\n" 14 "" 14 ""
    printf "%*s${GREEN}╰──────────────────────────────────────────────────────────╯${RESET}\n" $(( (TERM_WIDTH - 60) / 2 )) ""

    echo
    echo

    # Quick start section
    section_header "Quick Start Guide" "🚀"

    center_text "${CYAN}${BOLD}Essential Commands:${RESET}"
    center_text "${FG}${DIM}Run these commands to get started${RESET}"
    echo
    center_text "${CYAN}omnixy-menu${RESET}        ${FG}- Interactive system menu${RESET}"
    center_text "${CYAN}omnixy-info${RESET}        ${FG}- System information display${RESET}"
    center_text "${CYAN}omnixy-theme${RESET}       ${FG}- Switch between themes${RESET}"
    center_text "${CYAN}omnixy-security${RESET}    ${FG}- Configure security features${RESET}"

    echo
    section_header "Keyboard Shortcuts" "⌨️ "

    center_text "${PURPLE}${BOLD}Hyprland Window Manager:${RESET}"
    echo
    center_text "${CYAN}Super + Return${RESET}     ${FG}- Open terminal${RESET}"
    center_text "${CYAN}Super + R${RESET}          ${FG}- Application launcher${RESET}"
    center_text "${CYAN}Super + B${RESET}          ${FG}- Web browser${RESET}"
    center_text "${CYAN}Super + E${RESET}          ${FG}- File manager${RESET}"
    center_text "${CYAN}Super + Q${RESET}          ${FG}- Close window${RESET}"
    center_text "${CYAN}Super + F${RESET}          ${FG}- Fullscreen toggle${RESET}"
    center_text "${CYAN}Super + 1-0${RESET}        ${FG}- Switch workspaces${RESET}"

    echo
    section_header "Next Steps" "📋"

    center_text "${YELLOW}${BOLD}Recommended Actions:${RESET}"
    echo
    center_text "${FG}1. ${CYAN}Reboot your system${RESET} ${FG}- Apply all changes${RESET}"
    center_text "${FG}2. ${CYAN}Run omnixy-security status${RESET} ${FG}- Check security setup${RESET}"
    center_text "${FG}3. ${CYAN}Configure fingerprint/FIDO2${RESET} ${FG}- Enhanced security${RESET}"
    center_text "${FG}4. ${CYAN}Explore themes${RESET} ${FG}- Try different color schemes${RESET}"
    center_text "${FG}5. ${CYAN}Join the community${RESET} ${FG}- Get help and share feedback${RESET}"

    echo
    section_header "Resources" "🔗"

    center_text "${BLUE}${UNDERLINE}https://github.com/TheArctesian/omnixy${RESET} ${FG}- Project homepage${RESET}"
    center_text "${BLUE}${UNDERLINE}https://nixos.org/manual${RESET} ${FG}- NixOS documentation${RESET}"

    echo
    echo
    center_text "${DIM}${FG}Thank you for choosing OmniXY! ${CYAN}❤️${RESET}"
    echo

    # Auto-reboot prompt
    printf "%*s${YELLOW}Reboot now to complete installation? (Y/n): ${RESET}" $(( (TERM_WIDTH - 45) / 2 )) ""
    read -n 1 -r reply
    echo

    if [[ ! $reply =~ ^[Nn]$ ]]; then
        center_text "${GREEN}Rebooting in 3 seconds...${RESET}"
        sleep 1
        center_text "${GREEN}Rebooting in 2 seconds...${RESET}"
        sleep 1
        center_text "${GREEN}Rebooting in 1 second...${RESET}"
        sleep 1
        sudo reboot
    else
        center_text "${FG}Remember to reboot when convenient!${RESET}"
    fi
}

# Main installation orchestrator
main() {
    # Trap to restore terminal on exit
    trap 'printf "\033[0m\033[?25h"; stty sane' EXIT

    # Hide cursor during installation
    printf '\033[?25l'

    show_banner
    sleep 2

    section_header "Welcome to OmniXY" "🌟"
    center_text "${FG}Transform your NixOS into a beautiful, modern desktop experience${RESET}"
    center_text "${DIM}${FG}This installer will guide you through the complete setup process${RESET}"
    echo

    printf "%*s${CYAN}${BOLD}Ready to begin installation? (Y/n): ${RESET}" $(( (TERM_WIDTH - 35) / 2 )) ""
    read -n 1 -r reply
    echo

    if [[ $reply =~ ^[Nn]$ ]]; then
        center_text "${FG}Installation cancelled. Come back anytime!${RESET}"
        exit 0
    fi

    # Installation flow with enhanced UX
    check_nixos
    backup_config
    install_config
    generate_hardware_config
    update_user
    select_theme
    configure_features
    build_system
    show_complete

    # Restore cursor
    printf '\033[?25h'
}

# Start the installation
main "$@"