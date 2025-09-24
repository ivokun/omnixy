{ pkgs, lib, ... }:

# Omarchy utility scripts as a Nix package
pkgs.stdenv.mkDerivation rec {
  pname = "omarchy-scripts";
  version = "1.0.0";

  # No source needed for script-only package
  dontUnpack = true;

  buildInputs = with pkgs; [
    bash
    coreutils
    gnugrep
    gnused
    gawk
    jq
    curl
    wget
    git
    fzf
    ripgrep
  ];

  installPhase = ''
    mkdir -p $out/bin

    # Theme management
    cat > $out/bin/omarchy-theme-set << 'EOF'
    #!/usr/bin/env bash
    set -e

    THEME="$1"
    AVAILABLE_THEMES="tokyo-night catppuccin gruvbox nord everforest rose-pine kanagawa"

    if [ -z "$THEME" ]; then
      echo "Usage: omarchy-theme-set <theme>"
      echo "Available themes: $AVAILABLE_THEMES"
      exit 1
    fi

    if ! echo "$AVAILABLE_THEMES" | grep -qw "$THEME"; then
      echo "Error: Unknown theme '$THEME'"
      echo "Available themes: $AVAILABLE_THEMES"
      exit 1
    fi

    echo "Switching to theme: $THEME"

    # Update configuration
    sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$THEME\"/" /etc/nixos/configuration.nix

    # Rebuild system
    sudo nixos-rebuild switch --flake /etc/nixos#omarchy

    echo "Theme switched to $THEME successfully!"
    EOF
    chmod +x $out/bin/omarchy-theme-set

    cat > $out/bin/omarchy-theme-list << 'EOF'
    #!/usr/bin/env bash
    echo "Available Omarchy themes:"
    echo "========================"
    echo "  • tokyo-night (default)"
    echo "  • catppuccin"
    echo "  • gruvbox"
    echo "  • nord"
    echo "  • everforest"
    echo "  • rose-pine"
    echo "  • kanagawa"
    echo ""
    echo "Current theme: $(grep currentTheme /etc/nixos/configuration.nix | cut -d'"' -f2)"
    echo ""
    echo "To change theme, run: omarchy-theme-set <theme-name>"
    EOF
    chmod +x $out/bin/omarchy-theme-list

    # System management
    cat > $out/bin/omarchy-update << 'EOF'
    #!/usr/bin/env bash
    set -e

    echo "🔄 Updating Omarchy system..."
    echo ""

    # Update flake inputs
    echo "📦 Updating flake inputs..."
    cd /etc/nixos
    sudo nix flake update

    # Show what changed
    echo ""
    echo "📊 Changes:"
    git diff flake.lock | grep -E "^\+" | head -20

    # Rebuild system
    echo ""
    echo "🏗️  Rebuilding system..."
    sudo nixos-rebuild switch --flake .#omarchy

    echo ""
    echo "✅ System updated successfully!"
    EOF
    chmod +x $out/bin/omarchy-update

    cat > $out/bin/omarchy-clean << 'EOF'
    #!/usr/bin/env bash
    set -e

    echo "🧹 Cleaning Omarchy system..."
    echo ""

    # Show current store size
    echo "Current store size:"
    du -sh /nix/store 2>/dev/null || echo "Unable to calculate"
    echo ""

    # Run garbage collection
    echo "Running garbage collection..."
    sudo nix-collect-garbage -d

    # Optimize store
    echo "Optimizing Nix store..."
    sudo nix-store --optimise

    # Show new size
    echo ""
    echo "New store size:"
    du -sh /nix/store 2>/dev/null || echo "Unable to calculate"

    echo ""
    echo "✅ Cleanup complete!"
    EOF
    chmod +x $out/bin/omarchy-clean

    # Package management
    cat > $out/bin/omarchy-search << 'EOF'
    #!/usr/bin/env bash

    QUERY="$1"

    if [ -z "$QUERY" ]; then
      echo "Usage: omarchy-search <package-name>"
      exit 1
    fi

    echo "Searching for '$QUERY'..."
    nix search nixpkgs "$QUERY" 2>/dev/null | head -50
    EOF
    chmod +x $out/bin/omarchy-search

    cat > $out/bin/omarchy-install << 'EOF'
    #!/usr/bin/env bash
    set -e

    PACKAGES="$*"

    if [ -z "$PACKAGES" ]; then
      echo "Usage: omarchy-install <package-name> [package-name...]"
      exit 1
    fi

    echo "📦 Installing packages: $PACKAGES"
    echo ""

    # Add packages to configuration
    CONFIG="/etc/nixos/configuration.nix"

    for PKG in $PACKAGES; do
      echo "Adding $PKG to configuration..."
      # This would need more sophisticated editing
      echo "Package $PKG needs to be manually added to $CONFIG"
    done

    echo ""
    echo "Please edit $CONFIG and add the packages to environment.systemPackages"
    echo "Then run: omarchy-rebuild"
    EOF
    chmod +x $out/bin/omarchy-install

    # Development helpers
    cat > $out/bin/omarchy-dev-shell << 'EOF'
    #!/usr/bin/env bash

    LANG="$1"

    case "$LANG" in
      rust)
        echo "Starting Rust development shell..."
        nix-shell -p rustc cargo rust-analyzer rustfmt clippy
        ;;
      go)
        echo "Starting Go development shell..."
        nix-shell -p go gopls gotools golangci-lint
        ;;
      python)
        echo "Starting Python development shell..."
        nix-shell -p python3 python3Packages.pip python3Packages.virtualenv python3Packages.ipython
        ;;
      node|js)
        echo "Starting Node.js development shell..."
        nix-shell -p nodejs_20 nodePackages.pnpm nodePackages.typescript
        ;;
      c|cpp)
        echo "Starting C/C++ development shell..."
        nix-shell -p gcc cmake gnumake gdb clang-tools
        ;;
      *)
        echo "Usage: omarchy-dev-shell <language>"
        echo "Supported languages: rust, go, python, node/js, c/cpp"
        exit 1
        ;;
    esac
    EOF
    chmod +x $out/bin/omarchy-dev-shell

    # Screenshot utility
    cat > $out/bin/omarchy-screenshot << 'EOF'
    #!/usr/bin/env bash

    MODE="''${1:-region}"
    OUTPUT_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$OUTPUT_DIR"
    FILENAME="$OUTPUT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

    case "$MODE" in
      region|area)
        grim -g "$(slurp)" "$FILENAME"
        ;;
      full|screen)
        grim "$FILENAME"
        ;;
      window)
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$FILENAME"
        ;;
      *)
        echo "Usage: omarchy-screenshot [region|full|window]"
        exit 1
        ;;
    esac

    if [ -f "$FILENAME" ]; then
      wl-copy < "$FILENAME"
      notify-send "Screenshot saved" "$FILENAME" -i "$FILENAME"
      echo "$FILENAME"
    fi
    EOF
    chmod +x $out/bin/omarchy-screenshot

    # System info
    cat > $out/bin/omarchy-info << 'EOF'
    #!/usr/bin/env bash

    echo "╭──────────────────────────────╮"
    echo "│       OMARCHY NIXOS          │"
    echo "╰──────────────────────────────╯"
    echo ""
    echo "System Information:"
    echo "==================="
    echo "Version:     $(nixos-version)"
    echo "Kernel:      $(uname -r)"
    echo "Theme:       $(grep currentTheme /etc/nixos/configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "default")"
    echo "User:        $USER"
    echo "Shell:       $SHELL"
    echo "Terminal:    $TERM"
    echo ""
    echo "Hardware:"
    echo "========="
    echo "CPU:         $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "Memory:      $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk:        $(df -h / | awk 'NR==2 {print $2}')"
    echo ""
    echo "Quick Commands:"
    echo "=============="
    echo "  omarchy-help     - Show help"
    echo "  omarchy-update   - Update system"
    echo "  omarchy-clean    - Clean system"
    echo "  omarchy-theme    - Change theme"
    EOF
    chmod +x $out/bin/omarchy-info

    # Help command
    cat > $out/bin/omarchy-help << 'EOF'
    #!/usr/bin/env bash

    cat << HELP
    Omarchy NixOS - Command Reference
    ==================================

    System Management:
    ------------------
    omarchy-update        Update system and flake inputs
    omarchy-clean         Clean and optimize Nix store
    omarchy-rebuild       Rebuild system configuration
    omarchy-info          Show system information

    Package Management:
    -------------------
    omarchy-search        Search for packages
    omarchy-install       Install packages (guide)

    Theme Management:
    -----------------
    omarchy-theme-list    List available themes
    omarchy-theme-set     Set system theme

    Development:
    ------------
    omarchy-dev-shell     Start language-specific shell
    dev-postgres          Start PostgreSQL container
    dev-redis             Start Redis container
    dev-mysql             Start MySQL container
    dev-mongodb           Start MongoDB container

    Utilities:
    ----------
    omarchy-screenshot    Take screenshots

    Hyprland Keybindings:
    ---------------------
    Super + Return        Open terminal
    Super + B             Open browser
    Super + E             Open file manager
    Super + D             Application launcher
    Super + Q             Close window
    Super + F             Fullscreen
    Super + Space         Toggle floating
    Super + 1-9           Switch workspace
    Super + Shift + 1-9   Move to workspace
    Print                 Screenshot region
    Shift + Print         Screenshot full

    For more information: https://omarchy.org
    HELP
    EOF
    chmod +x $out/bin/omarchy-help

    # Main omarchy command
    cat > $out/bin/omarchy << 'EOF'
    #!/usr/bin/env bash

    CMD="''${1:-help}"
    shift || true

    case "$CMD" in
      update|upgrade)
        omarchy-update "$@"
        ;;
      clean|gc)
        omarchy-clean "$@"
        ;;
      theme)
        if [ -n "$1" ]; then
          omarchy-theme-set "$@"
        else
          omarchy-theme-list
        fi
        ;;
      search)
        omarchy-search "$@"
        ;;
      install)
        omarchy-install "$@"
        ;;
      info|status)
        omarchy-info "$@"
        ;;
      help|--help|-h)
        omarchy-help "$@"
        ;;
      *)
        echo "Unknown command: $CMD"
        echo "Run 'omarchy help' for available commands"
        exit 1
        ;;
    esac
    EOF
    chmod +x $out/bin/omarchy

    # Create rebuild alias
    cat > $out/bin/omarchy-rebuild << 'EOF'
    #!/usr/bin/env bash
    sudo nixos-rebuild switch --flake /etc/nixos#omarchy "$@"
    EOF
    chmod +x $out/bin/omarchy-rebuild
  '';

  meta = with lib; {
    description = "Omarchy utility scripts for NixOS";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}