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
    AVAILABLE_THEMES="tokyo-night catppuccin gruvbox nord everforest rose-pine kanagawa catppuccin-latte matte-black osaka-jade ristretto"

    if [ -z "$THEME" ]; then
      if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
        exit 1
      fi
      echo "Usage: omnixy theme set <theme>" >&2
      echo "Available themes: $AVAILABLE_THEMES" >&2
      exit 1
    fi

    if ! echo "$AVAILABLE_THEMES" | grep -qw "$THEME"; then
      if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
        exit 1
      fi
      echo "Error: Unknown theme '$THEME'" >&2
      echo "Available themes: $AVAILABLE_THEMES" >&2
      exit 1
    fi

    # Update configuration
    sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$THEME\"/" /etc/nixos/configuration.nix

    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "Switching to theme: $THEME"
    fi

    # Rebuild system
    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      sudo nixos-rebuild switch --flake /etc/nixos#omnixy >/dev/null 2>&1
    else
      sudo nixos-rebuild switch --flake /etc/nixos#omnixy
      echo "Theme switched to $THEME successfully!"
    fi
    EOF
    chmod +x $out/bin/omnixy-theme-set

    cat > $out/bin/omnixy-theme-list << 'EOF'
    #!/usr/bin/env bash

    THEMES="tokyo-night catppuccin gruvbox nord everforest rose-pine kanagawa catppuccin-latte matte-black osaka-jade ristretto"

    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      echo "$THEMES" | tr ' ' '\n'
      exit 0
    fi

    if [[ "''${OMNIXY_JSON:-}" == "1" ]]; then
      current=$(grep currentTheme /etc/nixos/configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "tokyo-night")
      echo '{'
      echo '  "available": ["'$(echo "$THEMES" | sed 's/ /", "/g')'"],'
      echo '  "current": "'$current'"'
      echo '}'
      exit 0
    fi

    echo "Available OmniXY themes:"
    echo "========================"
    echo "  • tokyo-night (default)"
    echo "  • catppuccin"
    echo "  • gruvbox"
    echo "  • nord"
    echo "  • everforest"
    echo "  • rose-pine"
    echo "  • kanagawa"
    echo "  • catppuccin-latte"
    echo "  • matte-black"
    echo "  • osaka-jade"
    echo "  • ristretto"
    echo ""
    echo "Current theme: $(grep currentTheme /etc/nixos/configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "tokyo-night")"
    echo ""
    echo "To change theme, run: omnixy theme set <theme-name>"
    EOF
    chmod +x $out/bin/omnixy-theme-list

    # Get current theme command
    cat > $out/bin/omnixy-theme-get << 'EOF'
    #!/usr/bin/env bash
    current=$(grep currentTheme /etc/nixos/configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "tokyo-night")

    if [[ "''${OMNIXY_JSON:-}" == "1" ]]; then
      echo '{"current": "'$current'"}'
    else
      echo "$current"
    fi
    EOF
    chmod +x $out/bin/omnixy-theme-get

    # System management
    cat > $out/bin/omnixy-update << 'EOF'
    #!/usr/bin/env bash
    set -e

    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "🔄 Updating OmniXY system..."
      echo ""
    fi

    # Update flake inputs
    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "📦 Updating flake inputs..."
    fi
    cd /etc/nixos
    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      sudo nix flake update >/dev/null 2>&1
    else
      sudo nix flake update
    fi

    # Show what changed
    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo ""
      echo "📊 Changes:"
      git diff flake.lock | grep -E "^\+" | head -20
    fi

    # Rebuild system
    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo ""
      echo "🏗️  Rebuilding system..."
    fi
    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      sudo nixos-rebuild switch --flake .#omnixy >/dev/null 2>&1
    else
      sudo nixos-rebuild switch --flake .#omnixy
      echo ""
      echo "✅ System updated successfully!"
    fi
    EOF
    chmod +x $out/bin/omnixy-update

    cat > $out/bin/omnixy-clean << 'EOF'
    #!/usr/bin/env bash
    set -e

    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "🧹 Cleaning OmniXY system..."
      echo ""

      # Show current store size
      echo "Current store size:"
      du -sh /nix/store 2>/dev/null || echo "Unable to calculate"
      echo ""
    fi

    # Run garbage collection
    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "Running garbage collection..."
    fi
    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      sudo nix-collect-garbage -d >/dev/null 2>&1
    else
      sudo nix-collect-garbage -d
    fi

    # Optimize store
    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      echo "Optimizing Nix store..."
    fi
    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      sudo nix-store --optimise >/dev/null 2>&1
    else
      sudo nix-store --optimise
    fi

    if [[ "''${OMNIXY_QUIET:-}" != "1" ]]; then
      # Show new size
      echo ""
      echo "New store size:"
      du -sh /nix/store 2>/dev/null || echo "Unable to calculate"
      echo ""
      echo "✅ Cleanup complete!"
    fi
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

    # Gather data once
    VERSION=$(nixos-version)
    KERNEL=$(uname -r)
    THEME=$(grep currentTheme /etc/nixos/configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "tokyo-night")
    CPU=$(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)
    MEMORY=$(free -h | awk '/^Mem:/ {print $2}')
    DISK=$(df -h / | awk 'NR==2 {print $2}')

    if [[ "''${OMNIXY_JSON:-}" == "1" ]]; then
      echo "{"
      echo "  \"system\": {"
      echo "    \"version\": \"$VERSION\","
      echo "    \"kernel\": \"$KERNEL\","
      echo "    \"theme\": \"$THEME\","
      echo "    \"user\": \"$USER\","
      echo "    \"shell\": \"$SHELL\","
      echo "    \"terminal\": \"$TERM\""
      echo "  },"
      echo "  \"hardware\": {"
      echo "    \"cpu\": \"$CPU\","
      echo "    \"memory\": \"$MEMORY\","
      echo "    \"disk\": \"$DISK\""
      echo "  }"
      echo "}"
      exit 0
    fi

    if [[ "''${OMNIXY_QUIET:-}" == "1" ]]; then
      echo "version=$VERSION"
      echo "kernel=$KERNEL"
      echo "theme=$THEME"
      echo "user=$USER"
      echo "shell=$SHELL"
      echo "terminal=$TERM"
      echo "cpu=$CPU"
      echo "memory=$MEMORY"
      echo "disk=$DISK"
      exit 0
    fi

    echo "╭──────────────────────────────╮"
    echo "│       OMNIXY NIXOS           │"
    echo "╰──────────────────────────────╯"
    echo ""
    echo "System Information:"
    echo "==================="
    echo "Version:     $VERSION"
    echo "Kernel:      $KERNEL"
    echo "Theme:       $THEME"
    echo "User:        $USER"
    echo "Shell:       $SHELL"
    echo "Terminal:    $TERM"
    echo ""
    echo "Hardware:"
    echo "========="
    echo "CPU:         $CPU"
    echo "Memory:      $MEMORY"
    echo "Disk:        $DISK"
    echo ""
    echo "Quick Commands:"
    echo "=============="
    echo "  omnixy help     - Show help"
    echo "  omnixy update   - Update system"
    echo "  omnixy clean    - Clean system"
    echo "  omnixy theme    - List themes"
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

    # Parse global flags
    QUIET=false
    JSON=false
    while [[ $# -gt 0 ]]; do
      case $1 in
        --quiet|-q)
          QUIET=true
          export OMNIXY_QUIET=1
          shift
          ;;
        --json)
          JSON=true
          export OMNIXY_JSON=1
          shift
          ;;
        *)
          break
          ;;
      esac
    done

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
        case "''${1:-}" in
          set)
            shift
            omnixy-theme-set "$@"
            ;;
          list|ls)
            omnixy-theme-list "$@"
            ;;
          get|current)
            omnixy-theme-get "$@"
            ;;
          "")
            omnixy-theme-list "$@"
            ;;
          *)
            # Legacy: assume it's a theme name
            omnixy-theme-set "$@"
            ;;
        esac
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
        if [[ "$QUIET" == "false" ]]; then
          echo "Unknown command: $CMD" >&2
          echo "Run 'omnixy help' for available commands" >&2
        fi
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