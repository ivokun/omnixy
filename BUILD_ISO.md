# Building OmniXY ISO Image

This guide explains how to build a live ISO image of OmniXY NixOS that can be used for installation or testing.

## Prerequisites

1. **NixOS or Nix with Flakes**: You need a system with Nix installed and flakes enabled
2. **Sufficient disk space**: Building an ISO requires several GB of space
3. **Good internet connection**: Initial build will download many packages

## Quick Start

### Method 1: Using the Built-in App (Recommended)

```bash
# Clone the repository
git clone https://github.com/TheArctesian/omnixy.git
cd omnixy

# Build the ISO using the built-in app
nix run .#build-iso
```

The built app will:
- Build the ISO image
- Show progress and final location
- Provide instructions for using the ISO

### Method 2: Direct Nix Build

```bash
# Build the ISO directly
nix build .#iso

# The ISO will be available as a symlink
ls -la ./result/iso/
```

### Method 3: Build Specific Configuration

```bash
# Build the ISO configuration specifically
nix build .#nixosConfigurations.omnixy-iso.config.system.build.isoImage

# Find the ISO file
find ./result -name "*.iso"
```

## ISO Features

The OmniXY ISO includes:

### Pre-installed Software
- **Desktop Environment**: Hyprland with full OmniXY theming
- **Development Tools**: Complete development stack (editors, compilers, etc.)
- **Multimedia**: Video players, image viewers, audio tools
- **Productivity**: Browsers, office suite, communication tools
- **System Tools**: Disk utilities, system monitors, network tools

### Live Session Features
- **Auto-login**: Boots directly to the desktop as `nixos` user
- **No password required**: Passwordless sudo for system administration
- **Network ready**: NetworkManager enabled for easy connection
- **Installation tools**: Graphical installer (Calamares) included
- **Theme showcase**: All OmniXY themes available for testing

### Installation Capabilities
- **Guided installation**: Run `omnixy-installer` for graphical setup
- **Manual installation**: Full NixOS installation tools available
- **Hardware support**: Wide hardware compatibility with latest kernel

## ISO Configuration Details

### Size and Performance
- **Expected size**: 3-5 GB (depending on included packages)
- **RAM requirements**: Minimum 4GB RAM for live session
- **Boot methods**: UEFI and BIOS supported

### Included Themes
All OmniXY themes are included and can be tested:
- tokyo-night (default)
- catppuccin
- gruvbox
- nord
- everforest
- rose-pine
- kanagawa
- catppuccin-latte
- matte-black
- osaka-jade
- ristretto

### Customization Options

#### Building with Different Default Theme

Edit `iso.nix` and change the theme import:

```nix
# Change this line:
./modules/themes/tokyo-night.nix

# To your preferred theme:
./modules/themes/gruvbox.nix
```

#### Excluding Packages

Modify the `omnixy.packages.exclude` section in `iso.nix`:

```nix
omnixy = {
  # ... other config
  packages = {
    exclude = [ "discord" "spotify" "steam" ]; # Add packages to exclude
  };
};
```

#### Adding Custom Packages

Add packages to the `environment.systemPackages` in `iso.nix`:

```nix
environment.systemPackages = with pkgs; [
  # ... existing packages
  your-custom-package
];
```

## Using the ISO

### Creating Bootable Media

#### USB Drive (Linux)
```bash
# Replace /dev/sdX with your USB device
sudo dd if=./result/iso/omnixy-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

#### USB Drive (Windows)
Use tools like:
- Rufus
- Balena Etcher
- Windows USB/DVD Download Tool

#### DVD
Use any DVD burning software with the ISO file.

### Testing in Virtual Machine

#### QEMU
```bash
# Basic VM test (4GB RAM)
qemu-system-x86_64 -cdrom ./result/iso/omnixy-*.iso -m 4G -enable-kvm

# VM with more features
qemu-system-x86_64 \
  -cdrom ./result/iso/omnixy-*.iso \
  -m 8G \
  -enable-kvm \
  -vga virtio \
  -display gtk,gl=on \
  -machine q35 \
  -cpu host
```

#### VirtualBox
1. Create new VM with Linux/Other Linux (64-bit)
2. Allocate at least 4GB RAM
3. Mount the ISO as CD/DVD
4. Enable hardware acceleration if available

#### VMware
1. Create new VM with Linux/Other Linux 5.x kernel 64-bit
2. Allocate at least 4GB RAM
3. Use ISO as CD/DVD source
4. Enable hardware acceleration

## Installation from ISO

### Using the Graphical Installer

1. Boot from the ISO
2. Wait for auto-login to complete
3. Run the installer:
   ```bash
   omnixy-installer
   ```
4. Follow the graphical installation wizard
5. Reboot when complete

### Manual Installation

1. Boot from the ISO
2. Partition your disk with `gparted` or command-line tools
3. Mount your root partition:
   ```bash
   sudo mount /dev/sdaX /mnt
   ```
4. Generate hardware configuration:
   ```bash
   sudo nixos-generate-config --root /mnt
   ```
5. Download OmniXY:
   ```bash
   cd /mnt/etc/nixos
   sudo git clone https://github.com/TheArctesian/omnixy.git .
   ```
6. Edit configuration:
   ```bash
   sudo nano configuration.nix
   # Set your username and preferred theme
   ```
7. Install:
   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#omnixy
   ```
8. Set root password when prompted
9. Reboot

## Troubleshooting

### Build Issues

#### "Path does not exist" errors
Ensure all files are present and paths in configuration are correct:
```bash
# Check if all required files exist
ls -la modules/ packages/ assets/
```

#### Out of disk space
Building requires significant space:
```bash
# Clean up nix store
nix-collect-garbage -d

# Check available space
df -h
```

#### Network issues during build
Ensure internet connection and try with cached builds:
```bash
# Use substituters
nix build .#iso --substituters https://cache.nixos.org
```

### Boot Issues

#### ISO doesn't boot
- Verify BIOS/UEFI settings
- Try different USB creation method
- Check USB drive integrity

#### Black screen on boot
- Try different graphics settings in GRUB
- Add `nomodeset` kernel parameter
- Use safe graphics mode

#### Out of memory during live session
- Use system with more RAM (minimum 4GB)
- Close unnecessary applications
- Consider lighter package selection

### Installation Issues

#### Hardware not detected
- Ensure latest kernel is being used
- Check for firmware packages
- Update hardware-configuration.nix manually

#### Network issues during installation
- Test network in live session first
- Configure NetworkManager connections
- Check firewall settings

## Advanced Usage

### Building for Different Architectures

Currently, OmniXY ISO supports x86_64-linux. For other architectures:

```bash
# Check available systems
nix flake show

# Build for specific system (if supported)
nix build .#packages.aarch64-linux.iso
```

### Customizing Boot Parameters

Edit the ISO configuration to add custom kernel parameters:

```nix
# In iso.nix
boot.kernelParams = [
  # Add your custom parameters
  "custom.parameter=value"
];
```

### Creating Minimal ISO

For a smaller ISO, disable features in `iso.nix`:

```nix
omnixy = {
  preset = "minimal"; # Instead of "everything"
  packages.exclude = [ /* large packages */ ];
};
```

## CI/CD Integration

### GitHub Actions

Add to `.github/workflows/build-iso.yml`:

```yaml
name: Build ISO
on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: cachix/install-nix-action@v20
      with:
        enable_flakes: true
    - name: Build ISO
      run: nix build .#iso
    - name: Upload ISO
      uses: actions/upload-artifact@v3
      with:
        name: omnixy-iso
        path: result/iso/*.iso
```

### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
build-iso:
  image: nixos/nix:latest
  script:
    - nix build .#iso
    - cp result/iso/*.iso ./
  artifacts:
    paths:
      - "*.iso"
    expire_in: 1 week
  only:
    - tags
```

## Contributing

When modifying the ISO configuration:

1. Test builds locally before committing
2. Verify ISO boots in at least one VM
3. Test both UEFI and BIOS boot modes
4. Check that installation process works
5. Update documentation if adding new features

## Support

- **Issues**: Report problems on GitHub Issues
- **Discussions**: Join GitHub Discussions for questions
- **Documentation**: Check the main README.md for general info
- **Matrix/Discord**: Community chat (links in main README)

---

For more information about OmniXY, see the main [README.md](README.md) file.