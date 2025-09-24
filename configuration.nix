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

    # Omarchy modules
    ./modules/core.nix
    ./modules/desktop/hyprland.nix
    ./modules/packages.nix
    ./modules/development.nix
    ./modules/themes/${currentTheme}.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/hardware
  ];

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

  # Bootloader
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Plymouth for boot splash
    plymouth = {
      enable = true;
      theme = "omnixy";
      themePackages = [ (pkgs.callPackage ./packages/plymouth-theme.nix {}) ];
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

  # Sound
  sound.enable = true;
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

    # Display manager
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
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
    theme = currentTheme;

    # Feature flags
    features = {
      docker = true;
      development = true;
      gaming = false;
      multimedia = true;
    };
  };
}