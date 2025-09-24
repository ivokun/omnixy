{ pkgs, lib, ... }:

# OmniXY utility scripts as a Nix package
pkgs.stdenv.mkDerivation rec {
  pname = "omnixy-scripts";
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
    cat > $out/bin/omnixy-theme-set << 'EOF'
    #!/usr/bin/env bash
    set -e

    THEME="$1"
    AVAILABLE_THEMES="tokyo-night catppuccin gruvbox nord everforest rose-pine kanagawa"

    if [ -z "$THEME" ]; then
      echo "Usage: omnixy-theme-set <theme>"
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
    sudo nixos-rebuild switch --flake /etc/nixos#omnixy

    echo "Theme switched to $THEME successfully!"
    EOF
    chmod +x $out/bin/omnixy-theme-set

    cat > $out/bin/omnixy-theme-list << 'EOF'
    #!/usr/bin/env bash
    echo "Available OmniXY themes:"
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
    echo "To change theme, run: omnixy-theme-set <theme-name>"
    EOF
    chmod +x $out/bin/omnixy-theme-list

    # System management
    cat > $out/bin/omnixy-update << 'EOF'
    #!/usr/bin/env bash
    set -e

    echo "🔄 Updating OmniXY system..."
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
    sudo nixos-rebuild switch --flake .#omnixy

    echo ""
    echo "✅ System updated successfully!"
    EOF
    chmod +x $out/bin/omnixy-update

    cat > $out/bin/omnixy-clean << 'EOF'
    #!/usr/bin/env bash
    set -e

    echo "🧹 Cleaning OmniXY system..."
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
    chmod +x $out/bin/omnixy-clean

    # Package management
    cat > $out/bin/omnixy-search << 'EOF'
    #!/usr/bin/env bash

    QUERY="$1"

    if [ -z "$QUERY" ]; then
      echo "Usage: omnixy-search <package-name>"
      exit 1
    fi

    echo "Searching for '$QUERY'..."
    nix search nixpkgs "$QUERY" 2>/dev/null | head -50
    EOF
    chmod +x $out/bin/omnixy-search

    cat > $out/bin/omnixy-install << 'EOF'
    #!/usr/bin/env bash
    set -e

    PACKAGES="$*"

    if [ -z "$PACKAGES" ]; then
      echo "Usage: omnixy-install <package-name> [package-name...]"
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
    echo "Then run: omnixy-rebuild"
    EOF
    chmod +x $out/bin/omnixy-install

    # Development helpers
    cat > $out/bin/omnixy-dev-shell << 'EOF'
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
        echo "Usage: omnixy-dev-shell <language>"
        echo "Supported languages: rust, go, python, node/js, c/cpp"
        exit 1
        ;;
    esac
    EOF
    chmod +x $out/bin/omnixy-dev-shell

    # Screenshot utility
    cat > $out/bin/omnixy-screenshot << 'EOF'
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
        echo "Usage: omnixy-screenshot [region|full|window]"
        exit 1
        ;;
    esac

    if [ -f "$FILENAME" ]; then
      wl-copy < "$FILENAME"
      notify-send "Screenshot saved" "$FILENAME" -i "$FILENAME"
      echo "$FILENAME"
    fi
    EOF
    chmod +x $out/bin/omnixy-screenshot

    # System info
    cat > $out/bin/omnixy-info << 'EOF'
    #!/usr/bin/env bash

    echo "╭──────────────────────────────╮"
    echo "│       OMNIXY NIXOS           │"
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
    echo "  omnixy-help     - Show help"
    echo "  omnixy-update   - Update system"
    echo "  omnixy-clean    - Clean system"
    echo "  omnixy-theme    - Change theme"
    EOF
    chmod +x $out/bin/omnixy-info

    # Help command
    cat > $out/bin/omnixy-help << 'EOF'
    #!/usr/bin/env bash

    cat << HELP
    OmniXY NixOS - Command Reference
    ================================

    System Management:
    ------------------
    omnixy-update        Update system and flake inputs
    omnixy-clean         Clean and optimize Nix store
    omnixy-rebuild       Rebuild system configuration
    omnixy-info          Show system information

    Package Management:
    -------------------
    omnixy-search        Search for packages
    omnixy-install       Install packages (guide)

    Theme Management:
    -----------------
    omnixy-theme-list    List available themes
    omnixy-theme-set     Set system theme

    Development:
    ------------
    omnixy-dev-shell     Start language-specific shell
    dev-postgres          Start PostgreSQL container
    dev-redis             Start Redis container
    dev-mysql             Start MySQL container
    dev-mongodb           Start MongoDB container

    Utilities:
    ----------
    omnixy-screenshot    Take screenshots

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

    For more information: https://github.com/TheArctesian/omnixy
    HELP
    EOF
    chmod +x $out/bin/omnixy-help

    # Main omnixy command
    cat > $out/bin/omnixy << 'EOF'
    #!/usr/bin/env bash

    CMD="''${1:-help}"
    shift || true

    case "$CMD" in
      update|upgrade)
        omnixy-update "$@"
        ;;
      clean|gc)
        omnixy-clean "$@"
        ;;
      theme)
        if [ -n "$1" ]; then
          omnixy-theme-set "$@"
        else
          omnixy-theme-list
        fi
        ;;
      search)
        omnixy-search "$@"
        ;;
      install)
        omnixy-install "$@"
        ;;
      info|status)
        omnixy-info "$@"
        ;;
      help|--help|-h)
        omnixy-help "$@"
        ;;
      *)
        echo "Unknown command: $CMD"
        echo "Run 'omnixy help' for available commands"
        exit 1
        ;;
    esac
    EOF
    chmod +x $out/bin/omnixy

    # Create rebuild alias
    cat > $out/bin/omnixy-rebuild << 'EOF'
    #!/usr/bin/env bash
    sudo nixos-rebuild switch --flake /etc/nixos#omnixy "$@"
    EOF
    chmod +x $out/bin/omnixy-rebuild
  '';

  meta = with lib; {
    description = "OmniXY utility scripts for NixOS";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}