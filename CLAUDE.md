# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Notes
- **Repository**: https://github.com/TheArctesian/omnixy
- **System Name**: The system uses "omnixy" for flake names and commands
- **Git Setup**: The installation process requires users to set up their GitHub account manually before initializing the git repository

## Overview
This repository contains OmniXY NixOS (https://github.com/TheArctesian/omnixy), a declarative system configuration that transforms NixOS into a beautiful, modern development environment based on Hyprland. This version uses Nix's declarative configuration management for reproducible systems.

## Key Commands

### System Management
```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake /etc/nixos#omnixy
omnixy-rebuild  # Convenience wrapper

# Update system and flake inputs
omnixy update

# Clean and optimize Nix store
omnixy clean

# Search for packages
omnixy search <package-name>
```

### Development Workflows
```bash
# Test configuration changes
nixos-rebuild build --flake .#omnixy  # Build without switching

# Enter development shell
nix develop  # Uses flake.nix devShell
nix develop .#python  # Language-specific shell
nix develop .#node    # Node.js development
nix develop .#rust    # Rust development

# Format Nix code
nixpkgs-fmt *.nix
alejandra *.nix  # Alternative formatter

# Check Nix code
statix check .  # Static analysis
deadnix .       # Dead code elimination
```

### Theme Development
```bash
# Available themes in modules/themes/
ls modules/themes/

# Test theme switch
omnixy theme tokyo-night

# Create new theme
cp modules/themes/tokyo-night.nix modules/themes/my-theme.nix
# Edit color values and application configs
```

## Architecture

### Flake Structure
- **flake.nix** - Main flake definition with inputs and outputs
- **configuration.nix** - Main NixOS configuration entry point
- **home.nix** - Home-manager configuration for user environment

### Module System
The configuration is split into focused modules:
- **modules/core.nix** - Base system settings and Omarchy options
- **modules/packages.nix** - Package collections with feature flags
- **modules/development.nix** - Development tools and environments
- **modules/desktop/hyprland.nix** - Hyprland compositor configuration
- **modules/services.nix** - System services and daemons
- **modules/users.nix** - User account management
- **modules/themes/** - Theme-specific configurations

### Configuration Management
1. **Declarative** - Everything defined in Nix expressions
2. **Modular** - Features can be enabled/disabled via options
3. **Reproducible** - Same configuration produces identical systems
4. **Version Controlled** - All changes tracked in git

### Theme System
- Each theme is a complete Nix module in `modules/themes/`
- Themes configure: terminals, editors, GTK, Qt, desktop components
- Theme switching updates configuration.nix and rebuilds system
- Colors defined as variables for consistency

### Package Management
- **System packages** in `modules/packages.nix` with feature categories
- **User packages** in home.nix via home-manager
- **Development environments** via flake devShells
- **Custom packages** in packages/ directory

## Development Guidelines

### Adding Packages
1. **System packages**: Add to `modules/packages.nix` in appropriate category
2. **User packages**: Add to `home.nix` home.packages
3. **Development only**: Add to devShell in flake.nix
4. Always rebuild/test: `nixos-rebuild build --flake .#omnixy`

### Creating Modules
1. Follow NixOS module structure with options and config sections
2. Use `lib.mkEnableOption` and `lib.mkOption` for configuration
3. Implement feature flags for optional functionality
4. Document options and provide sensible defaults

### Theme Development
1. Copy existing theme as template
2. Define color palette as environment variables
3. Configure all supported applications consistently
4. Test theme switching functionality

### Custom Packages
1. Create derivations in packages/ directory
2. Use `pkgs.writeShellScriptBin` for simple scripts
3. Add to flake outputs for external use
4. Follow Nix packaging guidelines

### Flake Management
- Pin inputs for stability: `nix flake update --commit-lock-file`
- Use follows for input deduplication
- Provide multiple devShells for different workflows
- Export packages and apps for external consumption

### Testing Changes
- Build configuration: `nixos-rebuild build --flake .#omnixy`
- Test in VM: `nixos-rebuild build-vm --flake .#omnixy`
- Check evaluation: `nix flake check`
- Format code: `nixpkgs-fmt .`

### Home Manager Integration
- User-specific configuration in home.nix
- Theme integration via home-manager modules
- Dotfile management through Nix expressions
- Service management via systemd user units

## Common Tasks

### Adding New Service
1. Define in `modules/services.nix`
2. Use systemd service configuration
3. Add necessary packages
4. Configure firewalls/permissions as needed

### Hardware Support
1. Add hardware-specific modules in `modules/hardware/`
2. Use conditional configuration based on hardware detection
3. Include necessary firmware and drivers
4. Test on target hardware

### Debugging Issues
- Check system logs: `journalctl -xe`
- Nix build logs: `nix log /nix/store/...`
- Configuration evaluation: `nix show-config`
- Module option documentation: `man configuration.nix`