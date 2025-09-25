# OmniXY Architecture

## Overview
OmniXY is built on a layered architecture that combines NixOS's declarative system configuration with modern desktop tools and development environments.

## System Layers

```
┌─────────────────────────────────────────┐
│             User Interface              │
│    Hyprland + Waybar + Applications     │
├─────────────────────────────────────────┤
│           Desktop Environment           │
│   Theme System + Window Management      │
├─────────────────────────────────────────┤
│          OmniXY Configuration           │
│     Modules + Scripts + Packages        │
├─────────────────────────────────────────┤
│          Home Manager Layer             │
│      User Environment & Dotfiles        │
├─────────────────────────────────────────┤
│             NixOS System                │
│    Package Management + Services        │
├─────────────────────────────────────────┤
│             Linux Kernel                │
│        Hardware Abstraction             │
└─────────────────────────────────────────┘
```

## Core Components

### 1. Nix Flake System (`flake.nix`)
The foundation that defines all system inputs and outputs:
- **Inputs**: External dependencies (nixpkgs, home-manager, hyprland)
- **Outputs**: System configurations, packages, development shells, apps
- **Lock File**: Ensures reproducible builds across machines

### 2. System Configuration (`configuration.nix`)
Main NixOS system configuration that:
- Imports all modules
- Defines system-wide settings
- Sets the current theme
- Configures hardware and services

### 3. Module System (`modules/`)
Modular architecture with focused components:
- **Core**: Base system settings and OmniXY options
- **Themes**: Complete color schemes and application theming
- **Hardware**: Device-specific configurations
- **Desktop**: Window manager and GUI settings
- **Development**: Programming tools and environments

### 4. Home Manager (`home.nix`)
User environment management:
- User-specific packages
- Dotfile configuration
- Application settings
- Theme integration

### 5. Package System (`packages/`)
Custom Nix packages:
- OmniXY utility scripts
- Specialized tools
- Theme packages

### 6. Unix Tools (`scripts/`)
Focused utilities following Unix philosophy:
- System management
- Configuration backup
- User setup
- Build automation

## Data Flow

### System Build Process
```
flake.nix → configuration.nix → modules/*.nix → system build
    ↓              ↓                 ↓
 inputs        system opts      module config
    ↓              ↓                 ↓
nixpkgs       theme selection   packages/services
```

### Theme Application Flow
```
Theme Selection → Module Configuration → Application Settings
      ↓                    ↓                      ↓
  omnixy theme      modules/themes/        GTK/Qt/Terminal
   set <name>         <name>.nix              theming
```

### User Environment Flow
```
home.nix → Home Manager → User Packages & Dotfiles
    ↓           ↓                 ↓
user config  evaluation     ~/.config/* files
```

## Configuration Management

### Declarative Configuration
- All system state defined in Nix expressions
- No imperative commands modify system configuration
- Changes require rebuild to take effect

### Immutable System
- Built configurations are immutable
- Previous generations available for rollback
- Atomic upgrades prevent partial failures

### Module Composition
- Features implemented as independent modules
- Modules can depend on other modules
- Options system provides configuration interface

### Reproducible Builds
- Flake inputs pinned with lock file
- Same inputs produce identical outputs
- Cross-machine consistency guaranteed

## Development Architecture

### Language Support
Each language environment includes:
- Runtime and tools
- Language server protocols (LSPs)
- Package managers
- Development utilities

### Shell Environments
```
Development Shell:
  nix develop .#<language>
       ↓
  Language-specific packages
       ↓
  Configured environment
```

### Tool Integration
- Git with lazygit TUI
- Terminal with shell integration
- Editor with language support
- Build systems and debuggers

## Theme Architecture

### Unified Theming
All applications themed consistently:
- Terminal emulators (Alacritty, Kitty)
- Text editors (Neovim, VSCode)
- Desktop components (Waybar, Hyprland)
- GUI applications (GTK, Qt)

### Color Management
```
Theme Module → Color Variables → Application Configs
     ↓               ↓                    ↓
tokyo-night.nix → #7aa2f7 (blue) → terminal.colors.blue
```

### Theme Switching
1. Update configuration.nix with new theme
2. Rebuild system to apply changes
3. All applications automatically use new theme

## Hardware Support

### Adaptive Configuration
- Automatic hardware detection
- GPU-specific optimizations (Intel, AMD, NVIDIA)
- Audio system configuration
- Network and Bluetooth setup

### Conditional Modules
```nix
config = lib.mkIf cfg.hardware.nvidia.enable {
  # NVIDIA-specific configuration
};
```

## Security Architecture

### System Security
- Secure boot support
- Firewall configuration
- AppArmor profiles
- User isolation

### Authentication
- Multi-factor authentication support
- Fingerprint integration
- FIDO2 security keys
- Password management

## Extensibility

### Custom Modules
- Follow NixOS module structure
- Use options for configuration
- Implement proper dependencies
- Document all options

### Package Development
- Custom packages in `packages/`
- Integration with flake outputs
- Proper meta information
- Cross-platform support

### Theme Development
- Color palette definition
- Application configuration
- Testing across components
- Documentation and examples

This architecture provides a solid foundation for a reproducible, customizable, and maintainable desktop Linux system.