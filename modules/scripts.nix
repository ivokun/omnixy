{ config, pkgs, lib, ... }:

# Essential system utility scripts for OmniXY
# Convenient scripts for system management and productivity

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # System utility scripts
    environment.systemPackages = [
      # System information and monitoring
      (omnixy.makeScript "omnixy-sysinfo" "Show comprehensive system information" ''
        echo "╭─────────────────── OmniXY System Info ───────────────────╮"
        echo "│"
        echo "│  💻 System: $(hostname) ($(uname -m))"
        echo "│  🐧 OS: NixOS $(nixos-version)"
        echo "│  🎨 Theme: ${cfg.theme}"
        echo "│  👤 User: ${cfg.user}"
        echo "│  🏠 Preset: ${cfg.preset or "custom"}"
        echo "│"
        echo "│  🔧 Uptime: $(uptime -p)"
        echo "│  💾 Memory: $(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')"
        echo "│  💽 Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')"
        echo "│  🌡️  Load: $(uptime | sed 's/.*load average: //')"
        echo "│"
        echo "│  📦 Packages: $(nix-env -qa --installed | wc -l) installed"
        echo "│  🗂️  Generations: $(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | wc -l) total"
        echo "│"
        echo "╰───────────────────────────────────────────────────────────╯"
      '')

      # Quick system maintenance
      (omnixy.makeScript "omnixy-clean" "Clean system (garbage collect, optimize)" ''
        echo "🧹 Cleaning OmniXY system..."

        echo "  ├─ Collecting garbage..."
        sudo nix-collect-garbage -d

        echo "  ├─ Optimizing store..."
        sudo nix-store --optimize

        echo "  ├─ Clearing user caches..."
        rm -rf ~/.cache/thumbnails/*
        rm -rf ~/.cache/mesa_shader_cache/*
        rm -rf ~/.cache/fontconfig/*

        echo "  ├─ Clearing logs..."
        sudo journalctl --vacuum-time=7d

        echo "  └─ Cleaning complete!"

        # Show space saved
        echo
        echo "💾 Disk usage:"
        df -h / | awk 'NR==2{printf "   Root: %s/%s (%s used)\n", $3, $2, $5}'
        du -sh /nix/store | awk '{printf "   Nix Store: %s\n", $1}'
      '')

      # Update system and flake
      (omnixy.makeScript "omnixy-update" "Update system and flake inputs" ''
        echo "📦 Updating OmniXY system..."

        cd /etc/nixos || { echo "❌ Not in /etc/nixos directory"; exit 1; }

        echo "  ├─ Updating flake inputs..."
        sudo nix flake update

        echo "  ├─ Rebuilding system..."
        sudo nixos-rebuild switch --flake .#omnixy

        echo "  └─ Update complete!"

        # Show new generation
        echo
        echo "🎯 Current generation:"
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1
      '')

      # Rebuild system configuration
      (omnixy.makeScript "omnixy-rebuild" "Rebuild NixOS configuration" ''
        echo "🔨 Rebuilding OmniXY configuration..."

        cd /etc/nixos || { echo "❌ Not in /etc/nixos directory"; exit 1; }

        # Check if there are any uncommitted changes
        if ! git diff --quiet; then
          echo "⚠️  Warning: There are uncommitted changes"
          echo "   Consider committing them first"
          echo
        fi

        # Build and switch
        sudo nixos-rebuild switch --flake .#omnixy

        if [ $? -eq 0 ]; then
          echo "✅ Rebuild successful!"
          echo "🎯 Active generation: $(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1)"
        else
          echo "❌ Rebuild failed!"
          exit 1
        fi
      '')

      # Test build without switching
      (omnixy.makeScript "omnixy-test" "Test build configuration without switching" ''
        echo "🧪 Testing OmniXY configuration..."

        cd /etc/nixos || { echo "❌ Not in /etc/nixos directory"; exit 1; }

        # Build without switching
        sudo nixos-rebuild build --flake .#omnixy

        if [ $? -eq 0 ]; then
          echo "✅ Build test successful!"
          echo "   Configuration is valid and ready for deployment"
        else
          echo "❌ Build test failed!"
          echo "   Fix configuration errors before rebuilding"
          exit 1
        fi
      '')

      # Search for packages
      (omnixy.makeScript "omnixy-search" "Search for NixOS packages" ''
        if [ -z "$1" ]; then
          echo "Usage: omnixy-search <package-name>"
          echo "Search for packages in nixpkgs"
          exit 1
        fi

        echo "🔍 Searching for packages matching '$1'..."
        echo

        # Search in nixpkgs
        nix search nixpkgs "$1" | head -20

        echo
        echo "💡 Install with: nix-env -iA nixpkgs.<package>"
        echo "   Or add to your configuration.nix"
      '')

      # Theme management
      (omnixy.makeScript "omnixy-theme" "Switch OmniXY theme" ''
        if [ -z "$1" ]; then
          echo "🎨 Available OmniXY themes:"
          echo "   tokyo-night    - Dark theme with vibrant colors"
          echo "   catppuccin     - Pastel theme with modern aesthetics"
          echo "   gruvbox        - Retro theme with warm colors"
          echo "   nord           - Arctic theme with cool colors"
          echo "   everforest     - Green forest theme"
          echo "   rose-pine      - Cozy theme with muted colors"
          echo "   kanagawa       - Japanese-inspired theme"
          echo "   catppuccin-latte - Light catppuccin variant"
          echo "   matte-black    - Minimalist dark theme"
          echo "   osaka-jade     - Jade green accent theme"
          echo "   ristretto      - Coffee-inspired warm theme"
          echo
          echo "Usage: omnixy-theme <theme-name>"
          echo "Current theme: ${cfg.theme}"
          exit 0
        fi

        THEME="$1"
        CONFIG_FILE="/etc/nixos/configuration.nix"

        echo "🎨 Switching to theme: $THEME"

        # Validate theme exists
        if [ ! -f "/etc/nixos/modules/themes/$THEME.nix" ]; then
          echo "❌ Theme '$THEME' not found!"
          echo "   Available themes listed above"
          exit 1
        fi

        # Update configuration.nix
        sudo sed -i "s/currentTheme = \".*\";/currentTheme = \"$THEME\";/" "$CONFIG_FILE"

        echo "  ├─ Updated configuration..."
        echo "  ├─ Rebuilding system..."

        # Rebuild with new theme
        cd /etc/nixos && sudo nixos-rebuild switch --flake .#omnixy

        if [ $? -eq 0 ]; then
          echo "  ├─ Theme switched successfully!"
          echo "  └─ Updating Plymouth boot theme..."

          # Update Plymouth theme to match
          sudo omnixy-plymouth-theme "$THEME" 2>/dev/null || echo "     (Plymouth theme update may require reboot)"

          echo "✅ Now using theme: $THEME"
          echo "💡 Reboot to see the new boot splash screen"
        else
          echo "❌ Failed to apply theme!"
          # Revert change
          sudo sed -i "s/currentTheme = \"$THEME\";/currentTheme = \"${cfg.theme}\";/" "$CONFIG_FILE"
          exit 1
        fi
      '')

      # Hardware information
      (omnixy.makeScript "omnixy-hardware" "Show detailed hardware information" ''
        echo "🖥️  OmniXY Hardware Information"
        echo "═══════════════════════════════════"
        echo

        echo "💻 System:"
        echo "  Model: $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'Unknown')"
        echo "  Manufacturer: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo 'Unknown')"
        echo "  BIOS: $(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo 'Unknown')"
        echo

        echo "🧠 CPU:"
        lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core|MHz"
        echo

        echo "💾 Memory:"
        free -h
        echo

        echo "💽 Storage:"
        lsblk -f
        echo

        echo "📺 Graphics:"
        lspci | grep -i vga
        lspci | grep -i 3d
        echo

        echo "🔊 Audio:"
        lspci | grep -i audio
        echo

        echo "🌐 Network:"
        ip addr show | grep -E "inet |link/"
      '')

      # Service management
      (omnixy.makeScript "omnixy-services" "Manage OmniXY services" ''
        case "$1" in
          "status")
            echo "📊 OmniXY Service Status"
            echo "═══════════════════════"

            services=(
              "display-manager"
              "networkmanager"
              "pipewire"
              "bluetooth"
              "hypridle"
            )

            for service in "''${services[@]}"; do
              status=$(systemctl is-active $service 2>/dev/null || echo "inactive")
              case $status in
                "active") icon="✅" ;;
                "inactive") icon="❌" ;;
                *) icon="⚠️ " ;;
              esac
              printf "  %s %s: %s\n" "$icon" "$service" "$status"
            done
            ;;
          "restart")
            if [ -z "$2" ]; then
              echo "Usage: omnixy-services restart <service-name>"
              exit 1
            fi
            echo "🔄 Restarting $2..."
            sudo systemctl restart "$2"
            ;;
          "logs")
            if [ -z "$2" ]; then
              echo "Usage: omnixy-services logs <service-name>"
              exit 1
            fi
            journalctl -u "$2" -f
            ;;
          *)
            echo "📋 OmniXY Service Management"
            echo
            echo "Usage: omnixy-services <command> [service]"
            echo
            echo "Commands:"
            echo "  status          - Show status of key services"
            echo "  restart <name>  - Restart a service"
            echo "  logs <name>     - View service logs"
            ;;
        esac
      '')

      # Quick configuration editing
      (omnixy.makeScript "omnixy-config" "Quick access to configuration files" ''
        case "$1" in
          "main"|"")
            echo "📝 Opening main configuration..."
            ''${EDITOR:-nano} /etc/nixos/configuration.nix
            ;;
          "hyprland")
            echo "📝 Opening Hyprland configuration..."
            ''${EDITOR:-nano} /etc/nixos/modules/desktop/hyprland.nix
            ;;
          "theme")
            echo "📝 Opening theme configuration..."
            ''${EDITOR:-nano} /etc/nixos/modules/themes/${cfg.theme}.nix
            ;;
          "packages")
            echo "📝 Opening package configuration..."
            ''${EDITOR:-nano} /etc/nixos/modules/packages.nix
            ;;
          *)
            echo "📝 OmniXY Configuration Files"
            echo
            echo "Usage: omnixy-config <target>"
            echo
            echo "Targets:"
            echo "  main       - Main configuration.nix file"
            echo "  hyprland   - Hyprland window manager config"
            echo "  theme      - Current theme configuration"
            echo "  packages   - Package configuration"
            echo
            echo "Files will open in: ''${EDITOR:-nano}"
            ;;
        esac
      '')

      # Backup and restore
      (omnixy.makeScript "omnixy-backup" "Backup OmniXY configuration" ''
        BACKUP_DIR="$HOME/omnixy-backups"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="$BACKUP_DIR/omnixy_$TIMESTAMP.tar.gz"

        echo "💾 Creating OmniXY configuration backup..."

        mkdir -p "$BACKUP_DIR"

        # Create backup archive
        sudo tar -czf "$BACKUP_FILE" \
          -C /etc \
          nixos/ \
          --exclude=nixos/hardware-configuration.nix

        # Also backup user configs that matter
        if [ -d "$HOME/.config" ]; then
          tar -czf "$BACKUP_DIR/userconfig_$TIMESTAMP.tar.gz" \
            -C "$HOME" \
            .config/hypr/ \
            .config/waybar/ \
            .config/mako/ \
            .config/walker/ 2>/dev/null || true
        fi

        echo "✅ Backup created:"
        echo "  System: $BACKUP_FILE"
        echo "  User:   $BACKUP_DIR/userconfig_$TIMESTAMP.tar.gz"
        echo
        echo "📊 Backup size:"
        du -sh "$BACKUP_DIR"/*"$TIMESTAMP"* | sed 's/^/  /'
      '')
    ];
  };
}