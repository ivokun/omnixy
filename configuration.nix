# OmniXY NixOS Configuration
# This is the main NixOS configuration file
# Edit this file to define what should be installed on your system

{ config, pkgs, lib, ... }:

let
  # Import custom modules
  omnixy = import ./modules { inherit config pkgs lib; };

  # Current theme - can be changed easily
  currentTheme = "tokyo-night";
in
{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # OmniXY modules (lib must be first to provide helpers)
    ./modules/lib.nix
    ./modules/core.nix
    ./modules/colors.nix
    ./modules/boot.nix
    ./modules/security.nix
    ./modules/fastfetch.nix
    ./modules/walker.nix
    ./modules/scripts.nix
    ./modules/menus.nix
    ./modules/desktop/hyprland.nix
    ./modules/packages.nix
    ./modules/development.nix
    ./modules/themes/${currentTheme}.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/hardware
  ];

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

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Bootloader (now configured in boot.nix module)
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Kernel
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Networking
  networking = {
    hostName = "omnixy";
    networkmanager.enable = true;

    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 3000 8080 ];
    };
  };

  # Timezone and locale
  time.timeZone = "America/New_York";
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

  # Sound (deprecated option removed)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];

    # Display manager disabled - using tuigreet in services.nix
    displayManager.gdm.enable = false;
  };

  # Console configuration
  console = {
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # System version
  system.stateVersion = "24.05";

  # Custom OmniXY settings
  omnixy = {
    enable = true;
    user = "user"; # Change this to your username
    theme = currentTheme;
    displayManager = "tuigreet";

    # Quick Setup - Choose a preset that matches your use case
    preset = "developer"; # Options: minimal, developer, creator, gamer, office, everything

    # Security configuration
    security = {
      enable = true;
      fingerprint = {
        enable = false;        # Set to true to enable fingerprint auth
        autoDetect = true;     # Auto-detect fingerprint hardware
      };
      fido2 = {
        enable = false;        # Set to true to enable FIDO2 auth
        autoDetect = true;     # Auto-detect FIDO2 devices
      };
      systemHardening = {
        enable = true;         # Enable security hardening
        faillock = {
          enable = true;       # Enable account lockout protection
          denyAttempts = 10;   # Lock after 10 failed attempts
          unlockTime = 120;    # Unlock after 2 minutes
        };
      };
    };

    # Color scheme configuration (optional)
    # Uncomment and customize these options for automatic color generation:
    # colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
    # wallpaper = /path/to/your/wallpaper.jpg;

    # Fine-grained feature control (overrides preset settings)
    # Uncomment and customize as needed:
    # features = {
    #   coding = true;           # Development tools, editors, programming languages
    #   containers = true;       # Docker and container support
    #   gaming = false;          # Steam, Wine, gaming performance tools
    #   media = true;            # Video players, image viewers, media editing
    #   office = false;          # Office suite, PDF viewers, productivity apps
    #   communication = false;   # Chat apps, email, video conferencing
    #   virtualization = false;  # VirtualBox, QEMU, VM tools
    #   backup = false;          # Backup tools, cloud sync
    #   customThemes = true;     # Advanced theming with nix-colors
    #   wallpaperEffects = true; # Dynamic wallpapers and color generation
    # };

    # Package management
    packages = {
      # Example: Exclude specific packages you don't want
      # exclude = [ "discord" "spotify" "steam" "teams" ];
    };
  };
}
