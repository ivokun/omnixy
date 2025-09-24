{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omarchy;
in
{
  options.omarchy = {
    enable = mkEnableOption "Omarchy system configuration";

    user = mkOption {
      type = types.str;
      default = "user";
      description = "Primary user for the system";
    };

    theme = mkOption {
      type = types.enum [ "tokyo-night" "catppuccin" "gruvbox" "nord" "everforest" "rose-pine" "kanagawa" ];
      default = "tokyo-night";
      description = "System theme";
    };

    features = {
      docker = mkEnableOption "Docker container support";
      development = mkEnableOption "Development tools and environments";
      gaming = mkEnableOption "Gaming support (Steam, Wine, etc.)";
      multimedia = mkEnableOption "Multimedia applications";
    };
  };

  config = mkIf cfg.enable {
    # Basic system configuration
    system.autoUpgrade = {
      enable = true;
      flake = "/etc/nixos#omarchy";
      flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
      dates = "weekly";
    };

    # Enable documentation
    documentation = {
      enable = true;
      man.enable = true;
      dev.enable = cfg.features.development;
    };

    # Security settings
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        extraRules = [
          {
            groups = [ "wheel" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/nixos-rebuild";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };

      polkit.enable = true;
    };

    # System services
    services = {
      # Enable SSH daemon
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # Enable fstrim for SSD
      fstrim.enable = true;

      # Enable thermald for thermal management
      thermald.enable = true;

      # Enable power management
      power-profiles-daemon.enable = true;
      upower.enable = true;

      # Enable bluetooth
      blueman.enable = true;

      # Enable GVFS for mounting
      gvfs.enable = true;

      # Enable Avahi for network discovery
      avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          userServices = true;
        };
      };

      # Enable flatpak support
      flatpak.enable = true;

      # System monitoring
      smartd = {
        enable = true;
        autodetect = true;
      };
    };

    # Hardware support
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # OpenGL support
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };

    # Docker configuration
    virtualisation = mkIf cfg.features.docker {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };

    # Development configuration
    programs = mkIf cfg.features.development {
      git = {
        enable = true;
        lfs.enable = true;
      };

      npm.enable = true;
    };

    # Gaming configuration
    programs.steam = mkIf cfg.features.gaming {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Environment variables
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
      TERM = "xterm-256color";

      # Development
      CARGO_HOME = "$HOME/.cargo";
      GOPATH = "$HOME/go";
      NPM_CONFIG_PREFIX = "$HOME/.npm";

      # Omarchy specific
      OMARCHY_ROOT = "/etc/nixos";
      OMARCHY_VERSION = "1.0.0";
    };

    # Shell configuration
    programs.bash = {
      interactiveShellInit = ''
        # Omarchy bash initialization
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.npm/bin:$PATH"

        # Aliases
        alias ll='eza -la'
        alias ls='eza'
        alias cat='bat'
        alias grep='rg'
        alias find='fd'
        alias vim='nvim'
        alias vi='nvim'

        # Omarchy specific aliases
        alias omarchy-rebuild='sudo nixos-rebuild switch --flake /etc/nixos#omarchy'
        alias omarchy-update='nix flake update --flake /etc/nixos'
        alias omarchy-clean='sudo nix-collect-garbage -d'
        alias omarchy-search='nix search nixpkgs'

        # Functions
        omarchy-theme() {
          local theme=$1
          if [ -z "$theme" ]; then
            echo "Available themes: tokyo-night, catppuccin, gruvbox, nord, everforest, rose-pine, kanagawa"
            return 1
          fi

          echo "Switching to theme: $theme"
          # This would need to update the configuration and rebuild
          sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$theme\"/" /etc/nixos/configuration.nix
          omarchy-rebuild
        }

        omarchy-help() {
          cat << EOF
        Omarchy Commands:
        ================
        omarchy-rebuild  - Rebuild system configuration
        omarchy-update   - Update flake inputs
        omarchy-clean    - Garbage collect nix store
        omarchy-search   - Search for packages
        omarchy-theme    - Change system theme
        omarchy-help     - Show this help message

        Key Bindings (Hyprland):
        =======================
        Super + Return   - Open terminal
        Super + B        - Open browser
        Super + E        - Open file manager
        Super + D        - Application launcher
        Super + Q        - Close window
        Super + F        - Fullscreen
        Super + Space    - Toggle floating

        For more information, visit: https://omarchy.org
        EOF
        }

        # Welcome message
        if [ -z "$IN_NIX_SHELL" ]; then
          echo "Welcome to Omarchy! Type 'omarchy-help' for available commands."
        fi
      '';

      promptInit = ''
        # Starship prompt
        if command -v starship &> /dev/null; then
          eval "$(starship init bash)"
        fi
      '';
    };

    # System-wide packages
    environment.systemPackages = with pkgs; [
      # Core utilities
      coreutils
      findutils
      gnugrep
      gnused
      gawk

      # System tools
      htop
      neofetch
      tree
      wget
      curl

      # Text editors
      vim
      nano

      # Development basics
      git
      make
      gcc

      # Nix tools
      nix-prefetch-git
      nixpkgs-fmt
      nil

      # Custom Omarchy scripts
      (writeShellScriptBin "omarchy-info" ''
        #!/usr/bin/env bash
        echo "Omarchy NixOS"
        echo "============="
        echo "Version: ${config.omarchy.version or "1.0.0"}"
        echo "Theme: ${cfg.theme}"
        echo "User: ${cfg.user}"
        echo ""
        echo "Features:"
        echo "  Docker: ${if cfg.features.docker then "✓" else "✗"}"
        echo "  Development: ${if cfg.features.development then "✓" else "✗"}"
        echo "  Gaming: ${if cfg.features.gaming then "✓" else "✗"}"
        echo "  Multimedia: ${if cfg.features.multimedia then "✓" else "✗"}"
        echo ""
        echo "System Info:"
        nixos-version
      '')
    ];
  };
}