# OmniXY Command Reference

This document provides a comprehensive reference for all OmniXY commands and utilities.

## Main Command Interface

### `omnixy`
The primary command interface supporting global flags and subcommands.

**Global Flags**:
- `--quiet`, `-q`: Minimal output for scripting
- `--json`: Machine-readable JSON output where applicable

**Subcommands**:
- `help`: Show comprehensive help
- `info`, `status`: Display system information
- `update`, `upgrade`: Update system and flake inputs
- `clean`, `gc`: Garbage collection and optimization
- `theme`: Theme management
- `search`: Package search
- `install`: Package installation guide

## System Management Commands

### System Information
```bash
# System overview
omnixy info

# Quiet output (key=value pairs)
omnixy --quiet info

# JSON output for scripting
omnixy --json info | jq .system.version
```

### System Updates
```bash
# Update system with progress indication
omnixy update

# Quiet update for scripts
omnixy --quiet update

# Manual rebuild
omnixy-rebuild
```

### System Maintenance
```bash
# Clean and optimize
omnixy clean

# Show current/new store sizes
omnixy clean  # Shows before/after sizes

# Quiet cleanup
omnixy --quiet clean
```

## Theme Management Commands

### Theme Operations
```bash
# List all available themes
omnixy theme list
omnixy theme ls

# Get current theme
omnixy theme get
omnixy theme current

# Set new theme
omnixy theme set tokyo-night
omnixy theme kanagawa
```

### Scriptable Theme Management
```bash
# List themes (one per line)
omnixy --quiet theme list

# JSON theme information
omnixy --json theme list

# Current theme for scripting
current_theme=$(omnixy --quiet theme get)

# Automated theme cycling
themes=($(omnixy --quiet theme list))
next_theme=${themes[$(( ($(omnixy --quiet theme list | grep -n "$(omnixy --quiet theme get)" | cut -d: -f1) % ${#themes[@]}) ))]}
omnixy theme set "$next_theme"
```

## Package Management Commands

### Package Search
```bash
# Search for packages
omnixy search firefox
omnixy search development-tools

# Direct nix search
nix search nixpkgs firefox
```

### Package Installation
```bash
# Installation guide (interactive)
omnixy install firefox

# Note: Actual installation requires editing configuration files
# and rebuilding the system
```

## Development Commands

### Development Shells
```bash
# Language-specific development environments
omnixy-dev-shell rust    # Rust toolchain
omnixy-dev-shell python  # Python environment
omnixy-dev-shell go      # Go development
omnixy-dev-shell js      # Node.js/JavaScript
omnixy-dev-shell node    # Alternative for Node.js
omnixy-dev-shell c       # C/C++ development
omnixy-dev-shell cpp     # Alternative for C++

# Using flake development shells
nix develop          # Default development shell
nix develop .#rust   # Rust-specific shell
nix develop .#python # Python-specific shell
nix develop .#node   # Node.js-specific shell
```

## Utility Commands

### Screenshot Management
```bash
# Interactive region selection (default)
omnixy-screenshot
omnixy-screenshot region

# Full screen capture
omnixy-screenshot full
omnixy-screenshot screen

# Active window capture
omnixy-screenshot window
```

### System Help
```bash
# Comprehensive help system
omnixy help
omnixy-help

# Command-specific help
omnixy --help
omnixy theme --help
```

## Unix Philosophy Tools

Located in `scripts/` directory - focused utilities following Unix principles:

### System Validation
```bash
# Complete system check
./scripts/omnixy-check-system

# Check only NixOS
./scripts/omnixy-check-system --nixos-only

# Check permissions only
./scripts/omnixy-check-system --permissions-only

# Silent check (exit codes only)
./scripts/omnixy-check-system --quiet

# JSON output
OMNIXY_JSON=1 ./scripts/omnixy-check-system
```

### Configuration Management
```bash
# Create configuration backup
backup_path=$(./scripts/omnixy-backup-config)
echo "Backup created at: $backup_path"

# Custom backup location
./scripts/omnixy-backup-config /custom/backup/path

# Install configuration files
./scripts/omnixy-install-files

# Custom source/destination
./scripts/omnixy-install-files /source/path /dest/path
```

### User Configuration
```bash
# Interactive user setup
username=$(./scripts/omnixy-configure-user)

# Non-interactive mode
./scripts/omnixy-configure-user alice

# Custom config files
./scripts/omnixy-configure-user alice /etc/nixos/configuration.nix /etc/nixos/home.nix
```

### System Building
```bash
# Build and switch system
./scripts/omnixy-build-system

# Dry run (test only)
./scripts/omnixy-build-system --dry-run

# Custom configuration
./scripts/omnixy-build-system /path/to/config custom-name
```

## Installation Commands

### Simple Installer
```bash
# Basic installation
./install-simple.sh

# With options
./install-simple.sh --user alice --theme gruvbox --quiet

# Dry run
./install-simple.sh --dry-run

# Environment variables
OMNIXY_USER=bob OMNIXY_THEME=nord ./install-simple.sh --quiet
```

### Interactive Installer
```bash
# Full interactive experience
./install.sh

# Features styled terminal interface with:
# - System verification
# - User configuration
# - Theme selection
# - Feature toggles
# - Progress indication
```

### Bootstrap Installation
```bash
# Remote bootstrap (run on fresh NixOS)
curl -fsSL https://raw.githubusercontent.com/thearctesian/omnixy/main/boot.sh | bash

# Local bootstrap
./boot.sh
```

## Advanced Commands

### Build System Commands
```bash
# Build without switching
nixos-rebuild build --flake .#omnixy

# Build VM for testing
nixos-rebuild build-vm --flake .#omnixy

# Run VM
./result/bin/run-omnixy-vm

# Check flake evaluation
nix flake check

# Update flake inputs
nix flake update
```

### Package Building
```bash
# Build OmniXY scripts package
nix build .#omnixy-scripts

# Test built scripts
./result/bin/omnixy --help

# Build specific packages
nix build .#package-name
```

### Development Commands
```bash
# Format Nix code
nixpkgs-fmt *.nix **/*.nix
alejandra *.nix  # Alternative formatter

# Nix code analysis
statix check .   # Static analysis
deadnix .       # Dead code detection

# Show flake info
nix flake show
nix flake metadata
```

## Environment Variables

### Global Settings
- `OMNIXY_QUIET=1`: Enable quiet mode for all commands
- `OMNIXY_JSON=1`: Enable JSON output where supported
- `OMNIXY_USER`: Default username for installation
- `OMNIXY_THEME`: Default theme for installation

### Usage Examples
```bash
# Quiet automation
export OMNIXY_QUIET=1
omnixy update && omnixy clean && echo "Maintenance complete"

# JSON processing
omnixy --json info | jq -r '.system.version'

# Environment-based installation
export OMNIXY_USER=developer
export OMNIXY_THEME=tokyo-night
./install-simple.sh --quiet
```

## Command Composition Examples

### System Maintenance Script
```bash
#!/bin/bash
# Complete system maintenance

echo "Starting system maintenance..."

# Update system
omnixy --quiet update || { echo "Update failed"; exit 1; }

# Clean system
omnixy --quiet clean

# Verify system health
omnixy --quiet info | grep -q "NixOS" || { echo "System check failed"; exit 1; }

echo "Maintenance complete"
```

### Theme Rotation Script
```bash
#!/bin/bash
# Rotate through available themes

current=$(omnixy --quiet theme get)
themes=($(omnixy --quiet theme list))

for i in "${!themes[@]}"; do
    if [[ "${themes[$i]}" == "$current" ]]; then
        next_index=$(( (i + 1) % ${#themes[@]} ))
        next_theme="${themes[$next_index]}"
        omnixy theme set "$next_theme"
        echo "Switched from $current to $next_theme"
        break
    fi
done
```

This command reference provides comprehensive coverage of all OmniXY utilities, making it easy to find and use the right tool for any task.