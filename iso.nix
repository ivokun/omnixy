# OmniXY NixOS Live ISO Configuration
# This creates a bootable ISO image with OmniXY pre-installed

{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    # Include the basic ISO image module (without Calamares to avoid conflicts)
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    
    # OmniXY modules (lib must be first to provide helpers)
    ./modules/lib.nix
    ./modules/core.nix
    ./modules/colors.nix
    ./modules/security.nix
    ./modules/fastfetch.nix
    ./modules/walker.nix
    ./modules/scripts.nix
    ./modules/menus.nix
    ./modules/desktop/hyprland.nix
    ./modules/packages.nix
    ./modules/development.nix
    ./modules/themes/tokyo-night.nix  # Default theme for ISO
    ./modules/users.nix
    ./modules/services.nix
    ./modules/hardware
  ];

  # ISO-specific configuration
  isoImage = {
    # ISO image settings
    image.fileName = "omnixy-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    volumeID = "OMNIXY_${lib.toUpper config.system.nixos.label}";
    
    # Boot configuration
    makeEfiBootable = true;
    makeUsbBootable = true;
    
    # Include additional files
    includeSystemBuildDependencies = false;
    
    # Boot splash (optional)
    splashImage = if builtins.pathExists ./assets/logo.png 
                  then ./assets/logo.png 
                  else null;

    # Desktop entry for installer
    contents = [
      {
        source = pkgs.writeText "omnixy-install.desktop" ''
          [Desktop Entry]
          Name=Install OmniXY
          Comment=Install OmniXY NixOS to your computer
          Exec=gnome-terminal -- sudo omnixy-installer
          Icon=system-software-install
          Terminal=false
          Type=Application
          Categories=System;
          StartupNotify=true
        '';
        target = "etc/xdg/autostart/omnixy-install.desktop";
      }
    ];
  };

  # System configuration for live ISO
  system.stateVersion = "24.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  # Networking
  networking = {
    hostName = "omnixy-live";
    networkmanager.enable = true;
    wireless.enable = false; # Disable wpa_supplicant, use NetworkManager
    
    # Enable firewall but allow common services for live session
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 3000 8080 ];
    };
  };

  # Timezone and locale
  time.timeZone = "UTC"; # Will be configured during installation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Sound configuration
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Override display manager configuration for ISO
  services = {
    # Disable greetd from main config
    greetd.enable = lib.mkForce false;
    
    # Enable auto-login for live session
    getty.autologinUser = "nixos";
    
    # Keep X11 disabled - pure Wayland
    xserver.enable = lib.mkForce false;
  };

  # Live user configuration is handled by modules/users.nix
  # The nixos user will be created automatically since omnixy.user = "nixos"
  # Remove any conflicting password settings
  users.users.nixos = {
    initialPassword = lib.mkForce ""; # Empty password for live session
    password = lib.mkForce null;
    hashedPassword = lib.mkForce null;
    hashedPasswordFile = lib.mkForce null;
    initialHashedPassword = lib.mkForce null;
  };

  # Configure the user's environment to auto-start Hyprland
  environment.etc."profile.d/auto-hyprland.sh".text = ''
    # Auto-start Hyprland for nixos user on tty1
    if [[ "$(tty)" == "/dev/tty1" && "$USER" == "nixos" ]]; then
      # Set up Wayland environment
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=Hyprland
      export XDG_CURRENT_DESKTOP=Hyprland
      
      # Start Hyprland
      exec ${pkgs.hyprland}/bin/Hyprland
    fi
  '';

  # Sudo configuration for live user
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false; # Allow passwordless sudo for live session
  };

  # Enable SSH for remote access (with empty password warning)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkForce true;  # Override core.nix setting for ISO
      PermitEmptyPasswords = lib.mkForce true;   # For live session only
    };
  };

  # OmniXY configuration for ISO
  omnixy = {
    enable = true;
    user = "nixos"; # Live session user
    theme = "tokyo-night";
    displayManager = "gdm"; # Override default for live session
    
    # Use developer preset for maximum features showcase
    preset = "everything";
    
    # Security configuration (relaxed for live session)
    security = {
      enable = true;
      fingerprint.enable = false;
      fido2.enable = false;
      systemHardening = {
        enable = false; # Disable hardening for live session compatibility
        faillock.enable = false;
      };
    };
    
    # Package configuration
    packages = {
      # Don't exclude anything for the live session showcase
      exclude = [];
    };
  };

  # Additional ISO packages
  environment.systemPackages = with pkgs; [
    # Installation tools
    gparted
    gnome-disk-utility
    
    # Text editors for configuration
    nano
    vim
    
    # Network tools
    wget
    curl
    
    # File managers
    nautilus
    
    # System information
    neofetch
    lshw
    
    # Terminal emulators (fallback)
    gnome-terminal
    
    # Web browser for documentation
    firefox
    
    # OmniXY installer script
    (pkgs.writeShellScriptBin "omnixy-installer" ''
      #!/usr/bin/env bash
      set -e
      
      echo "🚀 OmniXY NixOS Installer"
      echo "========================="
      echo ""
      echo "This will guide you through installing OmniXY NixOS to your computer."
      echo ""
      echo "⚠️  WARNING: This will modify your disk partitions!"
      echo ""
      
      read -p "Do you want to continue? (y/N): " -n 1 -r
      echo
      
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
      fi
      
      # Launch the graphical installer
      echo "🖥️  Launching graphical installer..."
      echo "   Follow the on-screen instructions to install OmniXY."
      echo ""
      
      # Use Calamares if available, otherwise provide manual instructions
      if command -v calamares &> /dev/null; then
        sudo calamares
      else
        echo "📝 Manual Installation Instructions:"
        echo ""
        echo "1. Partition your disk with gparted or fdisk"
        echo "2. Mount your root partition to /mnt"
        echo "3. Generate hardware configuration:"
        echo "   sudo nixos-generate-config --root /mnt"
        echo ""
        echo "4. Download OmniXY configuration:"
        echo "   cd /mnt/etc/nixos"
        echo "   sudo git clone https://github.com/TheArctesian/omnixy.git ."
        echo ""
        echo "5. Edit configuration.nix to set your username and theme"
        echo ""
        echo "6. Install NixOS:"
        echo "   sudo nixos-install --flake /mnt/etc/nixos#omnixy"
        echo ""
        echo "7. Reboot and enjoy OmniXY!"
        
        read -p "Press Enter to open gparted for disk partitioning..."
        sudo gparted
      fi
    '')
    
    # Demo scripts
    (pkgs.writeShellScriptBin "omnixy-demo" ''
      #!/usr/bin/env bash
      echo "🎨 OmniXY Live Demo"
      echo "=================="
      echo ""
      echo "Welcome to OmniXY NixOS Live Session!"
      echo ""
      echo "Available commands:"
      echo "  omnixy-installer  - Install OmniXY to your computer"
      echo "  omnixy-info       - Show system information"
      echo "  omnixy-theme      - Change theme (temporary for live session)"
      echo "  omnixy-demo       - Show this demo"
      echo ""
      echo "Key features to try:"
      echo "  • Hyprland window manager with modern animations"
      echo "  • Multiple themes (tokyo-night, catppuccin, gruvbox, etc.)"
      echo "  • Development tools and environments"
      echo "  • Multimedia and productivity applications"
      echo ""
      echo "To install OmniXY permanently, run: omnixy-installer"
      echo ""
    '')
  ];

  # Services for live session
  services = {
    # Enable printing support
    printing.enable = true;
    
    # Enable Bluetooth
    blueman.enable = true;
    
    # Enable location services
    geoclue2.enable = true;
    
    # Enable automatic time synchronization
    timesyncd.enable = true;
  };

  # Hardware support
  hardware = {
    # Enable all firmware
    enableAllFirmware = true;
    
    # Graphics drivers
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    
    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
  
  # Pulseaudio (disabled in favor of PipeWire)
  services.pulseaudio.enable = false;

  # Boot configuration for ISO
  boot = {
    # Support for various filesystems
    supportedFilesystems = [ "btrfs" "ext4" "xfs" "ntfs" "fat32" "exfat" ];
    
    # Include lots of modules for hardware compatibility
    initrd.availableKernelModules = [
      # Storage
      "ahci" "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
      # Graphics
      "amdgpu" "radeon" "nouveau" "i915"
      # Network
      "r8169" "e1000e" "iwlwifi" "ath9k" "ath10k_pci" "rtw88_8822ce"
    ];
    
    # Kernel parameters for better hardware compatibility
    kernelParams = [
      "boot.shell_on_fail"
      "i915.modeset=1"
      "nouveau.modeset=1"
      "radeon.modeset=1"
      "amdgpu.modeset=1"
    ];
    
    # Use latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Plymouth disabled for ISO to avoid potential issues
    plymouth.enable = false;
  };

  # Auto-login is configured above in services.displayManager

  # Automatically start OmniXY demo on login
  environment.loginShellInit = ''
    # Show demo information on first login
    if [ -f /home/nixos/.first-login ]; then
      omnixy-demo
      rm /home/nixos/.first-login
    fi
  '';

  # Create first-login marker
  system.activationScripts.createFirstLoginMarker = ''
    touch /home/nixos/.first-login
    chown nixos:users /home/nixos/.first-login
  '';

  # Disable some services that might cause issues in live session
  systemd.services = {
    # Disable networkd-wait-online to speed up boot
    systemd-networkd-wait-online.enable = false;
    
    # Disable some hardware services that might not be needed
    fwupd.enable = false;
  };

  # Memory and performance optimizations for live session
  boot.kernel.sysctl = {
    # Use more aggressive memory reclaim
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    
    # Network optimizations
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}