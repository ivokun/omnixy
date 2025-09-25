# Modules Directory

The `modules/` directory contains the modular NixOS configuration system that makes up OmniXY. Each module is responsible for a specific aspect of the system and can be enabled, disabled, or configured independently.

## Module Architecture

Each module follows the standard NixOS module structure:
```nix
{ config, lib, pkgs, ... }:
with lib;
{
  options = {
    # Configuration options for this module
  };

  config = mkIf cfg.enable {
    # Module implementation
  };
}
```

## Core System Modules

### `core.nix`
**Purpose**: Base system settings and OmniXY-specific options
**What it configures**:
- Essential system services (NetworkManager, Bluetooth, Audio)
- Graphics support (OpenGL/Vulkan)
- Font management
- Basic security settings
- OmniXY module system foundations

**Key Features**:
- Automatic hardware graphics detection
- Unified font configuration across the system
- Essential service enablement
- Module option definitions

### `packages.nix`
**Purpose**: System-wide package management with feature categories
**What it manages**:
- Base system packages (editors, terminals, file managers)
- Development tools and languages
- Media and graphics applications
- Gaming packages (optional)
- Productivity software

**Categories**:
- `base`: Essential system utilities
- `development`: Programming tools and IDEs
- `media`: Audio/video applications
- `graphics`: Image editing and design tools
- `gaming`: Games and gaming platforms
- `productivity`: Office and productivity suites

### `services.nix`
**Purpose**: System service configuration and management
**What it configures**:
- Display manager (GDM)
- Audio system (PipeWire)
- Network services
- Container services (Docker, Podman)
- Development services (databases, etc.)

**Service Categories**:
- Desktop services (compositor, display manager)
- Audio/media services
- Network and connectivity
- Development and container services

### `users.nix`
**Purpose**: User account management and configuration
**What it manages**:
- User account creation and settings
- Shell configuration defaults
- User group memberships
- Home directory setup

**Features**:
- Automatic user creation based on configuration
- Shell preferences (zsh as default)
- Group membership for hardware access
- Integration with home-manager

## Security and System

### `security.nix`
**Purpose**: Security settings and authentication methods
**What it configures**:
- Multi-factor authentication
- Fingerprint support (fprintd)
- FIDO2 security keys
- System hardening options
- Firewall configuration

**Authentication Methods**:
- Password authentication
- Fingerprint recognition
- FIDO2/WebAuthn security keys
- Two-factor authentication

### `boot.nix`
**Purpose**: Boot system and kernel configuration
**What it manages**:
- Boot loader configuration (systemd-boot)
- Kernel parameters and modules
- Plymouth boot theme
- Early boot optimizations

**Boot Features**:
- Fast boot configuration
- Kernel optimization
- Boot splash screen
- Hardware initialization

## User Interface

### `menus.nix`
**Purpose**: Application menus and launchers
**What it configures**:
- Application launchers (rofi alternatives)
- Desktop menu systems
- Quick access interfaces
- Search functionality

### `walker.nix`
**Purpose**: Walker application launcher configuration
**What it manages**:
- Walker launcher settings
- Search backends and plugins
- Keybindings and interface
- Theme integration

### `fastfetch.nix`
**Purpose**: System information display tool
**What it configures**:
- System info formatting
- Logo and branding display
- Performance metrics
- Terminal integration

## Development Environment

### `development.nix`
**Purpose**: Development tools and programming environments
**What it provides**:
- Multiple language support (Rust, Go, Python, Node.js, C/C++)
- Language servers and tools
- Git configuration and tools
- Development containers and databases

**Language Support**:
- Runtime environments
- Package managers
- Language-specific tools
- IDE and editor integration

### `scripts.nix`
**Purpose**: OmniXY utility script management
**What it manages**:
- System management scripts
- Theme switching utilities
- Development helper scripts
- Unix philosophy tools

## Hardware Support

The `hardware/` subdirectory contains hardware-specific modules:

### `default.nix`
**Purpose**: Hardware detection and automatic configuration
**What it does**:
- Detects available hardware
- Enables appropriate drivers
- Configures hardware-specific settings
- Imports relevant hardware modules

### GPU Support
- `amd.nix`: AMD GPU drivers and configuration
- `intel.nix`: Intel integrated graphics
- `nvidia.nix`: NVIDIA proprietary drivers

### Audio and Input
- `audio.nix`: Audio system configuration
- `touchpad.nix`: Laptop touchpad settings
- `bluetooth.nix`: Bluetooth device support

## Theme System

The `themes/` subdirectory contains complete theme definitions:

Each theme module (e.g., `tokyo-night.nix`) configures:
- Color palette definitions
- Terminal color schemes
- Editor themes (Neovim, VSCode)
- Desktop component theming (Waybar, Hyprland)
- GTK/Qt application themes

## Desktop Environment

The `desktop/` subdirectory contains desktop-specific configurations:

### `hyprland.nix`
**Purpose**: Hyprland compositor configuration
**Sub-modules**:
- `bindings.nix`: Keyboard shortcuts and bindings
- `autostart.nix`: Applications started with the desktop
- `idle.nix`: Idle management and screen locking

## Utility Modules

### `lib.nix`
**Purpose**: Shared library functions and utilities
**What it provides**:
- Helper functions used across modules
- Common configuration patterns
- Utility functions for theme and configuration management

### `colors.nix`
**Purpose**: Color management and palette definitions
**What it manages**:
- Color space conversions
- Palette generation utilities
- Theme color validation

### `helpers.nix`
**Purpose**: Additional helper functions
**What it provides**:
- File and directory utilities
- Configuration templating functions
- System integration helpers

## Module Dependencies

```
core.nix (foundation)
    ↓
packages.nix + services.nix (system layer)
    ↓
security.nix + boot.nix (system hardening)
    ↓
themes/*.nix (visual layer)
    ↓
desktop/*.nix (user interface)
    ↓
development.nix (developer tools)
```

## Adding New Modules

To add a new module:

1. Create the module file in the appropriate subdirectory
2. Follow the standard NixOS module structure
3. Define clear options with types and descriptions
4. Import the module in `configuration.nix`
5. Document the module's purpose and options
6. Test the module in isolation and with others

## Module Best Practices

1. **Single Responsibility**: Each module handles one aspect
2. **Clear Options**: Well-defined configuration interface
3. **Documentation**: Comments and option descriptions
4. **Dependencies**: Explicit module dependencies
5. **Testing**: Verify module works in isolation
6. **Performance**: Efficient evaluation and build times

This modular architecture makes OmniXY highly customizable while maintaining clean separation of concerns.