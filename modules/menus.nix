{ config, pkgs, lib, ... }:

# Interactive menu system for OmniXY
# Terminal-based menus for system management and productivity

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Interactive menu scripts
    environment.systemPackages = [
      # Main OmniXY menu
      (omnixy.makeScript "omnixy-menu" "Interactive OmniXY system menu" ''
        #!/bin/bash

        # Colors for terminal output
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        CYAN='\033[0;36m'
        WHITE='\033[1;37m'
        NC='\033[0m' # No Color

        show_header() {
          clear
          echo -e "''${CYAN}"
          echo "  ███████╗███╗   ███╗███╗   ██╗██╗██╗  ██╗██╗   ██╗"
          echo "  ██╔════╝████╗ ████║████╗  ██║██║╚██╗██╔╝╚██╗ ██╔╝"
          echo "  ██║     ██╔████╔██║██╔██╗ ██║██║ ╚███╔╝  ╚████╔╝"
          echo "  ██║     ██║╚██╔╝██║██║╚██╗██║██║ ██╔██╗   ╚██╔╝"
          echo "  ███████╗██║ ╚═╝ ██║██║ ╚████║██║██╔╝ ██╗   ██║"
          echo "  ╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝"
          echo -e "''${NC}"
          echo -e "''${WHITE}           🚀 Declarative • 🎨 Beautiful • ⚡ Fast''${NC}"
          echo
          echo -e "''${BLUE}═══════════════════════════════════════════════════════''${NC}"
          echo -e "''${WHITE}  Theme: ''${YELLOW}${cfg.theme}''${WHITE}  │  User: ''${GREEN}${cfg.user}''${WHITE}  │  Preset: ''${PURPLE}${cfg.preset or "custom"}''${NC}"
          echo -e "''${BLUE}═══════════════════════════════════════════════════════''${NC}"
          echo
        }

        show_main_menu() {
          show_header
          echo -e "''${WHITE}🎛️  Main Menu''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 📦 System Management"
          echo -e "''${GREEN}2.''${NC} 🎨 Theme & Appearance"
          echo -e "''${GREEN}3.''${NC} ⚙️  Configuration"
          echo -e "''${GREEN}4.''${NC} 🔧 Development Tools"
          echo -e "''${GREEN}5.''${NC} 📊 System Information"
          echo -e "''${GREEN}6.''${NC} 🛠️  Maintenance & Utilities"
          echo -e "''${GREEN}7.''${NC} 📋 Help & Documentation"
          echo
          echo -e "''${RED}0.''${NC} Exit"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_system_menu() {
          show_header
          echo -e "''${WHITE}📦 System Management''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 🔄 Update System"
          echo -e "''${GREEN}2.''${NC} 🔨 Rebuild Configuration"
          echo -e "''${GREEN}3.''${NC} 🧪 Test Configuration"
          echo -e "''${GREEN}4.''${NC} 🧹 Clean System"
          echo -e "''${GREEN}5.''${NC} 📊 Service Status"
          echo -e "''${GREEN}6.''${NC} 💾 Create Backup"
          echo -e "''${GREEN}7.''${NC} 🔍 Search Packages"
          echo
          echo -e "''${YELLOW}8.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_theme_menu() {
          show_header
          echo -e "''${WHITE}🎨 Theme & Appearance''${NC}"
          echo
          echo -e "''${WHITE}Current Theme: ''${YELLOW}${cfg.theme}''${NC}"
          echo
          echo -e "''${GREEN}Available Themes:''${NC}"
          echo -e "''${GREEN}1.''${NC} 🌃 tokyo-night    - Dark theme with vibrant colors"
          echo -e "''${GREEN}2.''${NC} 🎀 catppuccin     - Pastel theme with modern aesthetics"
          echo -e "''${GREEN}3.''${NC} 🟤 gruvbox        - Retro theme with warm colors"
          echo -e "''${GREEN}4.''${NC} ❄️  nord           - Arctic theme with cool colors"
          echo -e "''${GREEN}5.''${NC} 🌲 everforest     - Green forest theme"
          echo -e "''${GREEN}6.''${NC} 🌹 rose-pine      - Cozy theme with muted colors"
          echo -e "''${GREEN}7.''${NC} 🌊 kanagawa       - Japanese-inspired theme"
          echo -e "''${GREEN}8.''${NC} ☀️  catppuccin-latte - Light catppuccin variant"
          echo -e "''${GREEN}9.''${NC} ⚫ matte-black    - Minimalist dark theme"
          echo -e "''${GREEN}a.''${NC} 💎 osaka-jade     - Jade green accent theme"
          echo -e "''${GREEN}b.''${NC} ☕ ristretto      - Coffee-inspired warm theme"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select theme or option: ''${NC}"
        }

        show_config_menu() {
          show_header
          echo -e "''${WHITE}⚙️  Configuration''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 📝 Edit Main Configuration"
          echo -e "''${GREEN}2.''${NC} 🪟 Edit Hyprland Configuration"
          echo -e "''${GREEN}3.''${NC} 🎨 Edit Theme Configuration"
          echo -e "''${GREEN}4.''${NC} 📦 Edit Package Configuration"
          echo -e "''${GREEN}5.''${NC} 🔒 Security Settings"
          echo -e "''${GREEN}6.''${NC} 📂 Open Configuration Directory"
          echo -e "''${GREEN}7.''${NC} 🔗 View Git Status"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_dev_menu() {
          show_header
          echo -e "''${WHITE}🔧 Development Tools''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 💻 Open Terminal"
          echo -e "''${GREEN}2.''${NC} 📝 Open Code Editor"
          echo -e "''${GREEN}3.''${NC} 🌐 Open Browser"
          echo -e "''${GREEN}4.''${NC} 📁 Open File Manager"
          echo -e "''${GREEN}5.''${NC} 🚀 Launch Applications"
          echo -e "''${GREEN}6.''${NC} 🐙 Git Operations"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_info_menu() {
          show_header
          echo -e "''${WHITE}📊 System Information''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 🖥️  System Overview"
          echo -e "''${GREEN}2.''${NC} 💻 Hardware Information"
          echo -e "''${GREEN}3.''${NC} 📈 Performance Monitor"
          echo -e "''${GREEN}4.''${NC} 🔧 Service Status"
          echo -e "''${GREEN}5.''${NC} 💾 Disk Usage"
          echo -e "''${GREEN}6.''${NC} 🌐 Network Information"
          echo -e "''${GREEN}7.''${NC} 📊 OmniXY About"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_maintenance_menu() {
          show_header
          echo -e "''${WHITE}🛠️  Maintenance & Utilities''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 🧹 System Cleanup"
          echo -e "''${GREEN}2.''${NC} 🔄 Restart Services"
          echo -e "''${GREEN}3.''${NC} 📋 View Logs"
          echo -e "''${GREEN}4.''${NC} 💾 Backup Configuration"
          echo -e "''${GREEN}5.''${NC} 🔧 System Diagnostics"
          echo -e "''${GREEN}6.''${NC} 🖼️  Screenshot Tools"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        show_help_menu() {
          show_header
          echo -e "''${WHITE}📋 Help & Documentation''${NC}"
          echo
          echo -e "''${GREEN}1.''${NC} 📖 OmniXY Commands"
          echo -e "''${GREEN}2.''${NC} 🔑 Keyboard Shortcuts"
          echo -e "''${GREEN}3.''${NC} 🌐 Open GitHub Repository"
          echo -e "''${GREEN}4.''${NC} 📧 Report Issue"
          echo -e "''${GREEN}5.''${NC} ℹ️  About OmniXY"
          echo
          echo -e "''${YELLOW}0.''${NC} ← Back to Main Menu"
          echo
          echo -ne "''${CYAN}Select an option: ''${NC}"
        }

        handle_system_menu() {
          case "$1" in
            1) echo -e "''${GREEN}Updating system...''${NC}"; omnixy-update ;;
            2) echo -e "''${GREEN}Rebuilding configuration...''${NC}"; omnixy-rebuild ;;
            3) echo -e "''${GREEN}Testing configuration...''${NC}"; omnixy-test ;;
            4) echo -e "''${GREEN}Cleaning system...''${NC}"; omnixy-clean ;;
            5) echo -e "''${GREEN}Checking service status...''${NC}"; omnixy-services status ;;
            6) echo -e "''${GREEN}Creating backup...''${NC}"; omnixy-backup ;;
            7)
              echo -ne "''${CYAN}Enter package name to search: ''${NC}"
              read -r package
              if [ -n "$package" ]; then
                omnixy-search "$package"
              fi
              ;;
            8) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_theme_menu() {
          case "$1" in
            1) omnixy-theme tokyo-night ;;
            2) omnixy-theme catppuccin ;;
            3) omnixy-theme gruvbox ;;
            4) omnixy-theme nord ;;
            5) omnixy-theme everforest ;;
            6) omnixy-theme rose-pine ;;
            7) omnixy-theme kanagawa ;;
            8) omnixy-theme catppuccin-latte ;;
            9) omnixy-theme matte-black ;;
            a|A) omnixy-theme osaka-jade ;;
            b|B) omnixy-theme ristretto ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_config_menu() {
          case "$1" in
            1) omnixy-config main ;;
            2) omnixy-config hyprland ;;
            3) omnixy-config theme ;;
            4) omnixy-config packages ;;
            5)
              echo -e "''${CYAN}Security Settings:''${NC}"
              echo -e "''${WHITE}1. Security Status  2. Fingerprint Setup  3. FIDO2 Setup''${NC}"
              echo -ne "''${CYAN}Select: ''${NC}"
              read -r security_choice
              case "$security_choice" in
                1) omnixy-security status ;;
                2) omnixy-fingerprint setup ;;
                3) omnixy-fido2 setup ;;
              esac
              ;;
            6) cd /etc/nixos && ''${TERMINAL:-ghostty} ;;
            7) cd /etc/nixos && git status ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_dev_menu() {
          case "$1" in
            1) ''${TERMINAL:-ghostty} ;;
            2) code ;;
            3) ''${BROWSER:-firefox} ;;
            4) thunar ;;
            5) walker ;;
            6)
              echo -e "''${CYAN}Git Operations:''${NC}"
              echo -e "''${WHITE}1. Status  2. Log  3. Commit  4. Push''${NC}"
              echo -ne "''${CYAN}Select: ''${NC}"
              read -r git_choice
              cd /etc/nixos
              case "$git_choice" in
                1) git status ;;
                2) git log --oneline -10 ;;
                3) echo -ne "''${CYAN}Commit message: ''${NC}"; read -r msg; git add -A && git commit -m "$msg" ;;
                4) git push ;;
              esac
              ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_info_menu() {
          case "$1" in
            1) omnixy-sysinfo ;;
            2) omnixy-hardware ;;
            3) htop ;;
            4) omnixy-services status ;;
            5) df -h && echo && du -sh /nix/store ;;
            6) ip addr show ;;
            7) omnixy-about ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_maintenance_menu() {
          case "$1" in
            1) omnixy-clean ;;
            2)
              echo -ne "''${CYAN}Enter service name: ''${NC}"
              read -r service
              if [ -n "$service" ]; then
                omnixy-services restart "$service"
              fi
              ;;
            3)
              echo -ne "''${CYAN}Enter service name for logs: ''${NC}"
              read -r service
              if [ -n "$service" ]; then
                omnixy-services logs "$service"
              fi
              ;;
            4) omnixy-backup ;;
            5) echo -e "''${GREEN}Running diagnostics...''${NC}"; journalctl -p 3 -xb ;;
            6) grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot_$(date +'%Y-%m-%d-%H%M%S.png') ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        handle_help_menu() {
          case "$1" in
            1)
              echo -e "''${WHITE}OmniXY Commands:''${NC}"
              echo -e "''${GREEN}omnixy-menu''${NC}     - This interactive menu"
              echo -e "''${GREEN}omnixy-info''${NC}     - System information display"
              echo -e "''${GREEN}omnixy-about''${NC}    - About screen"
              echo -e "''${GREEN}omnixy-theme''${NC}    - Switch themes"
              echo -e "''${GREEN}omnixy-rebuild''${NC}  - Rebuild configuration"
              echo -e "''${GREEN}omnixy-update''${NC}   - Update system"
              echo -e "''${GREEN}omnixy-clean''${NC}    - Clean system"
              echo -e "''${GREEN}omnixy-search''${NC}   - Search packages"
              ;;
            2)
              echo -e "''${WHITE}Hyprland Keyboard Shortcuts:''${NC}"
              echo -e "''${GREEN}Super + Return''${NC}   - Open terminal"
              echo -e "''${GREEN}Super + R''${NC}        - Open launcher"
              echo -e "''${GREEN}Super + Q''${NC}        - Close window"
              echo -e "''${GREEN}Super + F''${NC}        - Fullscreen"
              echo -e "''${GREEN}Super + 1-0''${NC}      - Switch workspaces"
              ;;
            3) ''${BROWSER:-firefox} https://github.com/TheArctesian/omnixy ;;
            4) ''${BROWSER:-firefox} https://github.com/TheArctesian/omnixy/issues ;;
            5) omnixy-about ;;
            0) return 0 ;;
            *) echo -e "''${RED}Invalid option!''${NC}" ;;
          esac
          echo
          echo -ne "''${YELLOW}Press Enter to continue...''${NC}"
          read -r
        }

        # Main menu loop
        while true; do
          show_main_menu
          read -r choice

          case "$choice" in
            1)
              while true; do
                show_system_menu
                read -r sub_choice
                handle_system_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            2)
              while true; do
                show_theme_menu
                read -r sub_choice
                handle_theme_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            3)
              while true; do
                show_config_menu
                read -r sub_choice
                handle_config_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            4)
              while true; do
                show_dev_menu
                read -r sub_choice
                handle_dev_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            5)
              while true; do
                show_info_menu
                read -r sub_choice
                handle_info_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            6)
              while true; do
                show_maintenance_menu
                read -r sub_choice
                handle_maintenance_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            7)
              while true; do
                show_help_menu
                read -r sub_choice
                handle_help_menu "$sub_choice"
                [ "$?" -eq 0 ] && break
              done
              ;;
            0|q|Q)
              echo -e "''${GREEN}Goodbye! 👋''${NC}"
              exit 0
              ;;
            *)
              echo -e "''${RED}Invalid option! Press Enter to continue...''${NC}"
              read -r
              ;;
          esac
        done
      '')

      # Quick theme selector
      (omnixy.makeScript "omnixy-theme-picker" "Quick theme picker with preview" ''
        #!/bin/bash

        # Colors
        CYAN='\033[0;36m'
        WHITE='\033[1;37m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        RED='\033[0;31m'
        NC='\033[0m'

        themes=(
          "tokyo-night:🌃:Dark theme with vibrant colors"
          "catppuccin:🎀:Pastel theme with modern aesthetics"
          "gruvbox:🟤:Retro theme with warm colors"
          "nord:❄️ :Arctic theme with cool colors"
          "everforest:🌲:Green forest theme"
          "rose-pine:🌹:Cozy theme with muted colors"
          "kanagawa:🌊:Japanese-inspired theme"
          "catppuccin-latte:☀️ :Light catppuccin variant"
          "matte-black:⚫:Minimalist dark theme"
          "osaka-jade:💎:Jade green accent theme"
          "ristretto:☕:Coffee-inspired warm theme"
        )

        clear
        echo -e "''${CYAN}🎨 OmniXY Theme Picker''${NC}"
        echo -e "''${WHITE}Current Theme: ''${YELLOW}${cfg.theme}''${NC}"
        echo
        echo -e "''${WHITE}Available Themes:''${NC}"
        echo

        for i in "''${!themes[@]}"; do
          IFS=':' read -ra theme_info <<< "''${themes[$i]}"
          theme_name="''${theme_info[0]}"
          theme_icon="''${theme_info[1]}"
          theme_desc="''${theme_info[2]}"

          printf "''${GREEN}%2d.''${NC} %s %-15s - %s\n" "$((i+1))" "$theme_icon" "$theme_name" "$theme_desc"
        done

        echo
        echo -e "''${RED} 0.''${NC} Cancel"
        echo
        echo -ne "''${CYAN}Select theme (1-''${#themes[@]}): ''${NC}"
        read -r choice

        if [[ "$choice" -ge 1 && "$choice" -le "''${#themes[@]}" ]]; then
          IFS=':' read -ra theme_info <<< "''${themes[$((choice-1))]}"
          selected_theme="''${theme_info[0]}"

          echo -e "''${GREEN}Switching to ''${selected_theme}...''${NC}"
          omnixy-theme "$selected_theme"
        elif [[ "$choice" == "0" ]]; then
          echo -e "''${YELLOW}Cancelled.''${NC}"
        else
          echo -e "''${RED}Invalid selection!''${NC}"
          exit 1
        fi
      '')
    ];

    # Shell aliases for easy access
    omnixy.forUser {
      programs.bash.shellAliases = {
        menu = "omnixy-menu";
        themes = "omnixy-theme-picker";
        rebuild = "omnixy-rebuild";
        update = "omnixy-update";
        info = "omnixy-info";
        clean = "omnixy-clean";
      };

      programs.zsh.shellAliases = {
        menu = "omnixy-menu";
        themes = "omnixy-theme-picker";
        rebuild = "omnixy-rebuild";
        update = "omnixy-update";
        info = "omnixy-info";
        clean = "omnixy-clean";
      };

      programs.fish.shellAliases = {
        menu = "omnixy-menu";
        themes = "omnixy-theme-picker";
        rebuild = "omnixy-rebuild";
        update = "omnixy-update";
        info = "omnixy-info";
        clean = "omnixy-clean";
      };
    };
  };
}