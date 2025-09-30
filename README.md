# OmniXY NixOS

Transform your NixOS installation into a fully-configured, beautiful, and modern development system based on Hyprland. OmniXY brings the elegance of declarative configuration to desktop Linux, creating a reproducible and version-controlled development environment.

## ✨ Features

- **🎨 Beautiful Themes**: Ships with 11 carefully crafted themes (Tokyo Night, Catppuccin, Gruvbox, Nord, and more) - all declaratively configured
- **🚀 Modern Stack**: Pure Wayland with Hyprland compositor, Waybar, Alacritty, Ghostty, Neovim with LazyVim
- **📦 Declarative Everything**: Entire system configuration as code - reproducible across machines
- **🛠️ Development Ready**: Pre-configured environments for Rust, Go, Python, Node.js, C/C++, and more via Nix shells
- **🔄 Atomic Updates**: Rollback capability, no broken states, system-wide updates with one command
- **🎯 Modular Design**: Feature flags for Docker, gaming, multimedia - enable only what you need
- **⚡ Flake-based**: Modern Nix flakes for dependency management and reproducible builds
- **🏠 Home Manager**: User environment managed declaratively alongside system configuration
- **💿 ISO Builder**: Build custom live ISOs with your configuration

## 📋 Requirements

- NixOS 24.05 or newer (fresh installation recommended)
- 8GB RAM minimum (16GB+ recommended for development)
- 40GB disk space (for Nix store and development tools)
- UEFI system (for systemd-boot configuration)

## 🚀 Installation

### Direct Flake Installation (Recommended)

On an existing NixOS system:

```bash
# Install directly from GitHub
sudo nixos-rebuild switch --flake github:thearctesian/omnixy#omnixy

# Or clone and install locally
git clone https://github.com/thearctesian/omnixy
cd omnixy
sudo nixos-rebuild switch --flake .#omnixy
```

### Building a Custom ISO

Build a live ISO with the OmniXY configuration:

```bash
# Clone the repository
git clone https://github.com/thearctesian/omnixy
cd omnixy

# Build the ISO (this will take time on first build)
nix build .#iso

# The ISO will be available at:
ls -la result/iso/
```

Write the ISO to a USB drive:
```bash
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress
```

## 🎮 Usage

### System Management

```bash
omnixy help              # Show all available commands
omnixy update            # Update system and flake inputs
omnixy clean             # Clean and optimize Nix store
omnixy info              # Show system information
omnixy-rebuild           # Rebuild system configuration
omnixy search <package>  # Search for packages
```

### Theme Management

```bash
omnixy theme             # List available themes
omnixy theme tokyo-night # Switch to Tokyo Night theme

# Available themes:
# - tokyo-night (default)
# - catppuccin
# - catppuccin-latte
# - gruvbox
# - nord
# - everforest
# - rose-pine
# - kanagawa
# - matte-black
# - osaka-jade
# - ristretto
```

### Development Environments

```bash
# Enter development shells
nix develop               # Default development shell
nix develop .#rust        # Rust development environment
nix develop .#python      # Python development environment
nix develop .#node        # Node.js development environment
nix develop .#go          # Go development environment
nix develop .#c           # C/C++ development environment

# Alternative: Use omnixy development shells
omnixy-dev-shell rust    # Rust development shell
omnixy-dev-shell python  # Python development shell
omnixy-dev-shell go      # Go development shell
omnixy-dev-shell js      # JavaScript/Node.js shell
omnixy-dev-shell c       # C/C++ development shell
```

### Package Management

```bash
omnixy search firefox    # Search for packages
nix search nixpkgs python # Alternative package search

# Install packages by editing configuration
# Add to modules/packages.nix, then:
omnixy-rebuild           # Apply changes
```

## ⌨️ Key Bindings

| Key Combination | Action |
|-----------------|--------|
| `Super + Return` | Open terminal (Ghostty) |
| `Super + B` | Open browser (Firefox) |
| `Super + E` | Open file manager |
| `Super + D` | Application launcher (Walker) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Space` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Print` | Screenshot region |
| `Shift + Print` | Screenshot full screen |
| `Super + L` | Lock screen |

## 📁 Project Structure

```
omnixy/
├── configuration.nix          # Main NixOS configuration entry point
├── flake.nix                  # Flake definition with inputs/outputs
├── home.nix                   # Home-manager user configuration
├── hardware-configuration.nix # Hardware-specific configuration (generated)
├── iso.nix                    # ISO image configuration
├── modules/                   # Modular NixOS configuration
│   ├── core.nix              # Core OmniXY options and settings
│   ├── packages.nix          # Categorized package collections
│   ├── development.nix       # Development tools and environments
│   ├── services.nix          # System services and daemons
│   ├── users.nix             # User account management
│   ├── boot.nix              # Boot configuration
│   ├── security.nix          # Security settings
│   ├── scripts.nix           # OmniXY utility scripts
│   ├── menus.nix             # Application launchers
│   ├── walker.nix            # Walker launcher configuration
│   ├── fastfetch.nix         # System info display
│   ├── desktop/
│   │   └── hyprland.nix      # Hyprland compositor configuration
│   ├── themes/               # Declarative theme system
│   │   ├── tokyo-night.nix   # Tokyo Night theme
│   │   ├── catppuccin.nix    # Catppuccin theme
│   │   ├── gruvbox.nix       # Gruvbox theme
│   │   └── ...               # Additional themes
│   └── hardware/
│       ├── default.nix       # Common hardware support
│       ├── nvidia.nix        # NVIDIA GPU support
│       ├── amd.nix           # AMD GPU/CPU support
│       ├── intel.nix         # Intel GPU/CPU support
│       ├── audio.nix         # Audio configuration
│       ├── bluetooth.nix     # Bluetooth support
│       └── touchpad.nix      # Touchpad configuration
└── packages/                  # Custom packages
    └── scripts.nix           # OmniXY utility scripts as Nix packages
```

## 🏗️ Architecture

### Flake-based Configuration
- **Pinned Dependencies**: All inputs locked for reproducibility
- **Multiple Outputs**: NixOS configs, development shells, packages, apps, and ISO
- **Home Manager Integration**: User environment managed alongside system

### Modular Design
- **Feature Flags**: Enable/disable Docker, gaming, development tools, etc.
- **Theme System**: Complete application theming through Nix modules
- **Hardware Support**: Automatic detection and configuration
- **Development Environments**: Language-specific shells with all dependencies

### Pure Wayland
- **No X11 Dependencies**: Full Wayland compositor stack
- **Hyprland**: Dynamic tiling compositor with animations
- **Native Wayland Apps**: Ghostty, Alacritty, Firefox with Wayland support

## 🎨 Themes

OmniXY includes beautiful themes that configure your entire desktop environment:

- **Tokyo Night** (default) - Clean, dark theme inspired by Tokyo's night lights
- **Catppuccin** - Soothing pastel theme (Mocha variant)
- **Catppuccin Latte** - Light variant of Catppuccin
- **Gruvbox** - Retro groove color scheme
- **Nord** - Arctic, north-bluish color palette
- **Everforest** - Comfortable green color scheme
- **Rose Pine** - Natural pine and rose colors
- **Kanagawa** - Inspired by Japanese paintings
- **Matte Black** - Pure black minimalist theme
- **Osaka Jade** - Jade green accents
- **Ristretto** - Coffee-inspired brown theme

Each theme declaratively configures:
- Terminal colors (Ghostty, Alacritty, Kitty)
- Editor themes (Neovim, VS Code)
- Desktop environment (Hyprland, Waybar, Mako)
- Applications (Firefox, BTtop, Lazygit)
- GTK/Qt theming

## 🔧 Customization

### Adding System Packages

Edit `modules/packages.nix` and add packages to the appropriate category, then rebuild:

```bash
omnixy-rebuild
```

### Adding User Packages

Edit `home.nix` for user-specific packages and rebuild.

### Creating Custom Themes

1. Copy an existing theme as a template:
```bash
cp modules/themes/tokyo-night.nix modules/themes/my-theme.nix
```

2. Edit the color palette and application configurations
3. Add to `flake.nix` theme list
4. Rebuild to apply

### Testing Changes

```bash
# Test configuration without switching
nixos-rebuild build --flake .#omnixy

# Test in virtual machine
nixos-rebuild build-vm --flake .#omnixy
./result/bin/run-omnixy-vm

# Check flake evaluation
nix flake check

# Format Nix code
nixpkgs-fmt *.nix modules/*.nix
```

## 🚀 Building ISOs

Build custom live ISOs with your configuration:

```bash
# Build ISO
nix build .#iso

# ISO location
ls result/iso/nixos-*.iso
```

The ISO includes:
- Full OmniXY desktop environment
- Auto-login live session
- Hyprland with selected theme
- Development tools
- Installation utilities

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Omakub](https://omakub.org/) by DHH - the original opinionated desktop setup
- Built on [NixOS](https://nixos.org/) - the declarative Linux distribution
- Using [Hyprland](https://hyprland.org/) compositor - dynamic tiling Wayland compositor
- [Home Manager](https://github.com/nix-community/home-manager) - declarative user environment
- Theme configurations adapted from community themes and color schemes
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - for reproducible and composable configurations

## 🔗 Links

- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official NixOS documentation
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - User environment management
- [Hyprland Wiki](https://wiki.hyprland.org/) - Hyprland configuration reference
- [Nix Package Search](https://search.nixos.org/) - Search available packages
- [GitHub Issues](https://github.com/TheArctesian/omnixy/issues) - Report bugs or request features

## 📚 Learning Resources

- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) - Modern NixOS guide
- [Zero to Nix](https://zero-to-nix.com/) - Gentle introduction to Nix

---

Built with ❤️ using the power of **NixOS** and **declarative configuration**