# OmniXY Documentation

## Overview
OmniXY is a declarative, reproducible NixOS-based operating system focused on developer productivity and aesthetic customization. Built on top of NixOS, it provides a complete development environment with beautiful themes, modern tools, and a tiling window manager (Hyprland).

## Table of Contents
- [Architecture Overview](./ARCHITECTURE.md)
- [Installation Guide](./INSTALLATION.md)
- [Configuration System](./CONFIGURATION.md)
- [Theme System](./THEMES.md)
- [Development Environment](./DEVELOPMENT.md)
- [Command Reference](./COMMANDS.md)
- [Troubleshooting](./TROUBLESHOOTING.md)

## Quick Start

1. **Install NixOS** - OmniXY requires a base NixOS installation
2. **Run Bootstrap** - `curl -fsSL https://raw.githubusercontent.com/thearctesian/omnixy/main/boot.sh | bash`
3. **Configure User** - Set your username and select a theme
4. **Reboot** - Apply the new configuration

## Core Concepts

### Declarative Configuration
Everything in OmniXY is defined through Nix expressions. Your entire system configuration—packages, services, themes, and settings—is declared in code and version controlled.

### Reproducibility
The same configuration will produce identical systems across different machines. This is achieved through Nix's functional package management and flake lock files.

### Modularity
The system is built from composable modules that can be enabled, disabled, or customized independently. Each module handles a specific aspect of the system.

### Immutability
System packages and configurations are immutable once built. Changes require rebuilding the system, preventing configuration drift and ensuring consistency.

## System Components

### Base System (NixOS)
- Functional package management
- Atomic upgrades and rollbacks
- Declarative system configuration
- Reproducible builds

### Window Manager (Hyprland)
- Dynamic tiling compositor for Wayland
- Smooth animations and effects
- Extensive customization options
- Modern GPU-accelerated rendering

### Development Tools
- Multiple language environments (Rust, Go, Python, Node.js, etc.)
- Git integration with lazygit
- Modern terminal emulators (Alacritty, Kitty)
- Neovim with LazyVim configuration

### Theme System
- 11 pre-configured color schemes
- Unified theming across all applications
- Easy theme switching with `omnixy theme set <name>`
- Custom theme support

## Directory Structure

```
omnixy/
├── docs/               # This documentation
├── configuration.nix   # Main system configuration
├── flake.nix          # Flake definition with inputs/outputs
├── home.nix           # User environment configuration
├── modules/           # System modules
│   ├── themes/        # Theme definitions
│   ├── hardware/      # Hardware configurations
│   └── desktop/       # Desktop environment configs
├── packages/          # Custom Nix packages
└── scripts/           # Unix philosophy utilities
```

## Philosophy

OmniXY follows these principles:

1. **Declarative Over Imperative** - Define what you want, not how to get it
2. **Reproducible Builds** - Same input always produces same output
3. **Unix Philosophy** - Tools that do one thing well
4. **Developer First** - Optimized for programming workflows
5. **Beautiful Defaults** - Aesthetic out of the box
6. **Extensible** - Easy to customize and extend

## Getting Help

- **Command Help**: `omnixy help`
- **System Info**: `omnixy info`
- **GitHub Issues**: https://github.com/TheArctesian/omnixy/issues
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/

## Contributing

OmniXY is open source and welcomes contributions. See the main README for contribution guidelines.