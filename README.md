# OmniXY NixOS

Transform your NixOS installation into a fully-configured, beautiful, and modern development system based on Hyprland by running a single command. OmniXY brings the elegance of declarative configuration to desktop Linux, creating a reproducible and version-controlled development environment.

## ✨ Features

- **🎨 Beautiful Themes**: Ships with carefully crafted themes (Tokyo Night, Catppuccin, and more) - all declaratively configured
- **🚀 Modern Stack**: Hyprland compositor, Waybar, Alacritty, Neovim with LazyVim, all configured through Nix
- **📦 Declarative Everything**: Entire system configuration as code - reproducible across machines
- **🛠️ Development Ready**: Pre-configured environments for Rust, Go, Python, Node.js, C/C++, and more via Nix shells
- **🔄 Atomic Updates**: Rollback capability, no broken states, system-wide updates with one command
- **🎯 Modular Design**: Feature flags for Docker, gaming, multimedia - enable only what you need
- **⚡ Flake-based**: Modern Nix flakes for dependency management and reproducible builds
- **🏠 Home Manager**: User environment managed declaratively alongside system configuration

## 📋 Requirements

- NixOS 24.05 or newer (fresh installation recommended)
- 8GB RAM minimum (16GB+ recommended for development)
- 40GB disk space (for Nix store and development tools)
- UEFI system (for systemd-boot configuration)

## 🚀 Installation

### Quick Install (Bootstrap on fresh NixOS)

```bash
curl -fsSL https://raw.githubusercontent.com/thearctesian/omnixy/main/boot.sh | bash
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/thearctesian/omnixy
cd omnixy
```

2. Run the interactive installer:
```bash
./install.sh
```

3. The installer will:
   - Backup your existing NixOS configuration
   - Set up your username and home directory
   - Let you choose a theme (Tokyo Night, Catppuccin, etc.)
   - Configure optional features (Docker, gaming, multimedia)
   - Build and switch to the new configuration

### Advanced: Direct Flake Installation

```bash
# On existing NixOS system
sudo nixos-rebuild switch --flake github:thearctesian/omnixy#omnixy

# Or locally after cloning
sudo nixos-rebuild switch --flake .#omnixy
```

## 🎮 Usage

### System Management

```bash
omnixy help              # Show all available commands
omnixy update            # Update system and flake inputs
omnixy clean             # Clean and optimize Nix store
omnixy info              # Show system information
omnixy-rebuild           # Rebuild system configuration
```

### Theme Management

```bash
omnixy theme             # List available themes
omnixy theme tokyo-night # Switch to Tokyo Night theme
omnixy-theme-list        # List all available themes
omnixy-theme-set catppuccin  # Set Catppuccin theme
```

### Development Environments

```bash
# Enter development shells
nix develop               # Default development shell
nix develop .#rust        # Rust development environment
nix develop .#python      # Python development environment
nix develop .#node        # Node.js development environment

# Create new projects with dev environments
dev-project myapp rust    # Create Rust project with flake
dev-project webapp node   # Create Node.js project with flake

# Start development databases (Docker containers)
dev-postgres              # PostgreSQL container
dev-redis                 # Redis container
dev-mysql                 # MySQL container
dev-mongodb               # MongoDB container
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
| `Super + Return` | Open terminal |
| `Super + B` | Open browser |
| `Super + E` | Open file manager |
| `Super + D` | Application launcher |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Space` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Print` | Screenshot region |
| `Shift + Print` | Screenshot full screen |

## 📁 Project Structure

```
omnixy/
├── configuration.nix          # Main NixOS configuration entry point
├── flake.nix                  # Flake definition with inputs/outputs
├── home.nix                   # Home-manager user configuration
├── hardware-configuration.nix # Hardware-specific configuration (generated)
├── install.sh                 # Interactive installer script
├── boot.sh                    # Bootstrap script for fresh systems
├── modules/                   # Modular NixOS configuration
│   ├── core.nix              # Core Omarchy options and settings
│   ├── packages.nix          # Categorized package collections
│   ├── development.nix       # Development tools and environments
│   ├── services.nix          # System services and daemons
│   ├── users.nix             # User account management
│   ├── desktop/
│   │   └── hyprland.nix      # Hyprland compositor configuration
│   ├── themes/               # Declarative theme system
│   │   ├── tokyo-night.nix   # Tokyo Night theme
│   │   ├── catppuccin.nix    # Catppuccin theme
│   │   └── ...               # Additional themes
│   └── hardware/
│       └── default.nix       # Hardware support and drivers
└── packages/
    └── scripts.nix           # Omarchy utility scripts as Nix packages
```

## 🏗️ Architecture

### Flake-based Configuration
- **Pinned Dependencies**: All inputs locked for reproducibility
- **Multiple Outputs**: NixOS config, development shells, packages, and apps
- **Home Manager Integration**: User environment managed alongside system

### Modular Design
- **Feature Flags**: Enable/disable Docker, gaming, development tools, etc.
- **Theme System**: Complete application theming through Nix modules
- **Hardware Support**: Automatic detection and configuration
- **Development Environments**: Language-specific shells with all dependencies

### Declarative Everything
- **No Imperative Commands**: Everything defined in configuration files
- **Version Controlled**: All changes tracked in git
- **Rollback Support**: Previous generations available for recovery
- **Atomic Updates**: System changes applied atomically

## 🎨 Themes

Omarchy includes beautiful themes that configure your entire desktop environment:

- **Tokyo Night** (default) - A clean, dark theme inspired by Tokyo's night lights
- **Catppuccin** - Soothing pastel theme with excellent contrast
- More themes coming soon: **Gruvbox**, **Nord**, **Everforest**, **Rose Pine**, **Kanagawa**

Each theme declaratively configures:
- Terminal colors (Alacritty, Kitty)
- Editor themes (Neovim, VS Code)
- Desktop environment (Hyprland, Waybar, Mako)
- Applications (Firefox, BTtop, Lazygit)
- GTK/Qt theming

## 🔧 Customization

### Adding System Packages

Edit `modules/packages.nix` and add packages to the appropriate category:

```nix
# In modules/packages.nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  firefox
  vscode
  discord
] ++ optionals cfg.packages.categories.development [
  # Development-specific packages
  rustc
  go
  python3
];
```

Then rebuild:
```bash
omnixy-rebuild
```

### Adding User Packages

Edit `home.nix` for user-specific packages:

```nix
# In home.nix
home.packages = with pkgs; [
  # User-specific packages
  spotify
  obs-studio
  gimp
];
```

### Creating Custom Themes

1. Copy an existing theme as a template:
```bash
cp modules/themes/tokyo-night.nix modules/themes/my-theme.nix
```

2. Edit the color palette and application configurations
3. Update `configuration.nix` to use your theme:
```nix
currentTheme = "my-theme";
```

4. Rebuild to apply:
```bash
omnixy-rebuild
```

### Creating Development Environments

Add custom development shells to `flake.nix`:

```nix
devShells.${system}.myproject = pkgs.mkShell {
  packages = with pkgs; [
    nodejs_20
    typescript
    postgresql
  ];

  shellHook = ''
    echo "Welcome to My Project development environment!"
  '';
};
```

Use with: `nix develop .#myproject`

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
nixpkgs-fmt *.nix **/*.nix
```

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
