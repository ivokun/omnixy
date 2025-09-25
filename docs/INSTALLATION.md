# OmniXY Installation Guide

This guide covers all methods of installing OmniXY on your NixOS system, from automated installation to manual configuration.

## Prerequisites

### System Requirements
- **Operating System**: NixOS 24.05 or newer
- **RAM**: 8GB minimum (16GB+ recommended for development)
- **Storage**: 40GB free space (for Nix store and applications)
- **Boot**: UEFI system (for systemd-boot configuration)
- **Network**: Stable internet connection for package downloads

### Pre-Installation Checklist
```bash
# Verify NixOS installation
cat /etc/NIXOS

# Check available space
df -h /

# Verify internet connectivity
ping -c 3 github.com

# Check user permissions
groups $USER | grep -q wheel && echo "User has sudo access"
```

## Installation Methods

### Method 1: Bootstrap Installation (Recommended)

The fastest way to install OmniXY on a fresh NixOS system:

```bash
# Download and run bootstrap installer
curl -fsSL https://raw.githubusercontent.com/thearctesian/omnixy/main/boot.sh | bash
```

**What this does**:
1. Verifies NixOS installation
2. Downloads OmniXY repository
3. Runs the interactive installer
4. Guides you through configuration

**Advantages**:
- Single command installation
- Always uses latest version
- No local repository needed
- Automatic dependency handling

### Method 2: Interactive Installation

For users who want control over the installation process:

```bash
# Clone the repository
git clone https://github.com/thearctesian/omnixy
cd omnixy

# Run interactive installer
./install.sh
```

**Features**:
- Beautiful terminal interface with Tokyo Night colors
- Step-by-step guidance
- Theme selection with previews
- Optional features configuration
- Progress indication
- Automatic backup creation

**Installation Steps**:
1. **System Verification**: Checks NixOS and permissions
2. **Configuration Backup**: Saves existing `/etc/nixos`
3. **File Installation**: Copies OmniXY configuration
4. **User Setup**: Configure username and home directory
5. **Theme Selection**: Choose from 11 available themes
6. **Feature Configuration**: Enable optional features
7. **System Build**: Build and switch to new configuration

### Method 3: Simple Installation (Unix Philosophy)

For automation and scripting:

```bash
# Clone repository
git clone https://github.com/thearctesian/omnixy
cd omnixy

# Run simple installer with options
./install-simple.sh --user alice --theme gruvbox --quiet
```

**Command Options**:
- `--user USERNAME`: Set username (default: prompt)
- `--theme THEME`: Select theme (default: tokyo-night)
- `--quiet`, `-q`: Minimal output
- `--dry-run`, `-n`: Test without applying changes
- `--help`, `-h`: Show help

**Environment Variables**:
- `OMNIXY_USER`: Default username
- `OMNIXY_THEME`: Default theme
- `OMNIXY_QUIET=1`: Enable quiet mode

**Examples**:
```bash
# Fully automated installation
OMNIXY_USER=developer OMNIXY_THEME=tokyo-night ./install-simple.sh --quiet

# Test installation without applying
./install-simple.sh --user testuser --dry-run

# Interactive theme selection
./install-simple.sh --user alice
```

### Method 4: Manual Flake Installation

For advanced users who want direct control:

```bash
# Direct flake installation (replaces entire system)
sudo nixos-rebuild switch --flake github:thearctesian/omnixy#omnixy

# Or with local repository
git clone https://github.com/thearctesian/omnixy
cd omnixy
sudo nixos-rebuild switch --flake .#omnixy
```

**Important Notes**:
- Requires manual user configuration editing
- No automatic backup
- Assumes advanced Nix knowledge
- May overwrite existing configuration

## Step-by-Step Installation Process

### 1. Pre-Installation Setup

```bash
# Update NixOS channel (optional)
sudo nix-channel --update

# Ensure git is available
nix-shell -p git --run "git --version"

# Create backup directory (optional)
mkdir -p ~/nixos-backups
```

### 2. Repository Setup

```bash
# Clone to home directory
cd ~
git clone https://github.com/thearctesian/omnixy
cd omnixy

# Verify repository integrity
ls -la  # Should see flake.nix, configuration.nix, etc.
nix flake check  # Verify flake is valid
```

### 3. Configuration Customization (Optional)

Before installation, you can customize:

```bash
# Edit user configuration
vim home.nix  # Modify user packages and settings

# Modify system packages
vim modules/packages.nix  # Add/remove system packages

# Hardware-specific changes
vim hardware-configuration.nix  # Update for your hardware
```

### 4. Installation Execution

Choose your preferred installer and run it:

```bash
# Interactive (recommended for first-time users)
./install.sh

# Simple (for automation)
./install-simple.sh --user $USER --theme tokyo-night

# Manual (for experts)
sudo nixos-rebuild switch --flake .#omnixy
```

### 5. Post-Installation Configuration

After installation completes:

```bash
# Verify installation
omnixy info

# Check available commands
omnixy help

# Test theme switching
omnixy theme list
omnixy theme set nord

# Verify system health
systemctl status
journalctl -b | grep -i error
```

## Customization During Installation

### Theme Selection

Available themes during installation:
1. **tokyo-night** (default) - Dark with vibrant blues
2. **catppuccin** - Warm, soothing pastels
3. **gruvbox** - Retro earth tones
4. **nord** - Cool Arctic colors
5. **everforest** - Natural greens
6. **rose-pine** - Elegant pinks
7. **kanagawa** - Japanese-inspired
8. **catppuccin-latte** - Light variant
9. **matte-black** - Minimal black/white
10. **osaka-jade** - Jade greens
11. **ristretto** - Coffee browns

### Feature Configuration

Optional features you can enable:

**Security Features**:
- Fingerprint authentication
- FIDO2 security keys
- Two-factor authentication

**Development Features**:
- Docker/Podman support
- Development databases
- Additional programming languages

**Gaming Features**:
- Steam integration
- Wine compatibility
- Gaming optimizations

**Multimedia Features**:
- Video editing tools
- Audio production software
- Graphics applications

### Hardware Configuration

The installer automatically detects and configures:
- GPU drivers (Intel, AMD, NVIDIA)
- Audio hardware (PipeWire setup)
- Network interfaces
- Bluetooth devices
- Input devices (touchpad, etc.)

## Troubleshooting Installation

### Common Issues

**"Not running on NixOS" Error**:
```bash
# Verify NixOS installation
ls /etc/NIXOS
nixos-version
```

**Permission Denied Errors**:
```bash
# Ensure user is in wheel group
groups $USER | grep wheel

# Add user to wheel group if needed
sudo usermod -aG wheel $USER
```

**Network/Download Issues**:
```bash
# Test internet connectivity
curl -I https://github.com
ping -c 3 cache.nixos.org

# Check DNS resolution
nslookup github.com
```

**Insufficient Space**:
```bash
# Check available space
df -h /
du -sh /nix/store

# Clean up if needed
nix-collect-garbage -d
```

### Build Failures

**Flake Evaluation Errors**:
```bash
# Check flake syntax
nix flake check --show-trace

# Debug with verbose output
nixos-rebuild build --flake .#omnixy --show-trace
```

**Package Build Failures**:
```bash
# Check for specific package errors
journalctl -u nix-daemon | grep -i error

# Try building individual packages
nix build .#omnixy-scripts
```

**Out of Memory During Build**:
```bash
# Check memory usage
free -h
htop

# Enable swap if needed
sudo swapon -a

# Build with fewer jobs
nixos-rebuild build --flake .#omnixy --max-jobs 1
```

### Recovery Options

**Rollback to Previous Configuration**:
```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

**Restore from Backup**:
```bash
# If backup was created during installation
sudo cp -r /etc/nixos.backup.TIMESTAMP/* /etc/nixos/
sudo nixos-rebuild switch
```

**Boot from Rescue Environment**:
If the system fails to boot:
1. Boot from NixOS live USB
2. Mount the system
3. Restore backup or rollback
4. Rebuild system

## Verification and Testing

### Post-Installation Checks

```bash
# System information
omnixy info

# Theme verification
omnixy theme get

# Package verification
which alacritty hyprland waybar

# Service status
systemctl --user status hyprland
systemctl status NetworkManager
```

### Functional Testing

```bash
# Test theme switching
omnixy theme set gruvbox
omnixy theme set tokyo-night

# Test utilities
omnixy-screenshot --help
omnixy search firefox

# Test development environments
nix develop .#rust --command rustc --version
nix develop .#python --command python --version
```

### Performance Verification

```bash
# Check boot time
systemd-analyze

# Check memory usage
free -h
ps aux --sort=-%mem | head

# Check disk usage
df -h
du -sh /nix/store
```

## Next Steps After Installation

### Essential Configuration
1. **Set up Git**: Configure name and email
2. **Configure Shell**: Customize zsh/bash settings
3. **Install Additional Software**: Add personal packages
4. **Set up Development**: Configure programming environments

### System Maintenance
```bash
# Regular updates
omnixy update

# Regular cleanup
omnixy clean

# Monitor system health
omnixy info
```

### Customization
1. **Explore Themes**: Try different color schemes
2. **Customize Keybindings**: Modify Hyprland shortcuts
3. **Add Packages**: Edit configuration files
4. **Create Backups**: Regular system backups

This installation guide provides multiple paths to get OmniXY running on your system, accommodating different user preferences and technical backgrounds.