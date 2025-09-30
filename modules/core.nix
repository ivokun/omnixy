{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omnixy;
in
{
  options.omnixy = {
    enable = mkEnableOption "OmniXY system configuration";

    # User Configuration
    user = mkOption {
      type = types.str;
      default = "user";
      description = "Primary user for the system";
      example = "john";
    };

    # Theme Configuration
    theme = mkOption {
      type = types.enum [ "tokyo-night" "catppuccin" "gruvbox" "nord" "everforest" "rose-pine" "kanagawa" ];
      default = "tokyo-night";
      description = "System theme - changes colors, wallpaper, and overall look";
      example = "catppuccin";
    };

    # User-friendly theme aliases
    darkMode = mkOption {
      type = types.bool;
      default = true;
      description = "Use dark theme variant when available";
    };

    displayManager = mkOption {
      type = types.enum [ "gdm" "tuigreet" ];
      default = "tuigreet";
      description = "Display manager to use for login";
    };

    colorScheme = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "Color scheme from nix-colors. If null, uses theme-specific colors.";
      example = "inputs.nix-colors.colorSchemes.tokyo-night-dark";
    };

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to wallpaper for automatic color generation";
    };

    # Feature Categories - Simple on/off switches for major functionality
    features = {
      # Development
      coding = mkEnableOption "Development tools, editors, and programming languages";
      containers = mkEnableOption "Docker and container support";

      # Entertainment
      gaming = mkEnableOption "Gaming support with Steam, Wine, and performance tools";
      media = mkEnableOption "Video players, image viewers, and media editing tools";

      # Productivity
      office = mkEnableOption "Office suite, PDF viewers, and productivity apps";
      communication = mkEnableOption "Chat apps, email clients, and video conferencing";

      # System
      virtualization = mkEnableOption "VM support (VirtualBox, QEMU, etc.)";
      backup = mkEnableOption "Backup tools and cloud sync applications";

      # Appearance
      customThemes = mkEnableOption "Advanced theming with nix-colors integration";
      wallpaperEffects = mkEnableOption "Dynamic wallpapers and color generation";
    };

    # Simple Presets - Predefined feature combinations
    preset = mkOption {
      type = types.nullOr (types.enum [ "minimal" "developer" "creator" "gamer" "office" "everything" ]);
      default = null;
      description = ''
        Quick setup preset that automatically enables related features:
        - minimal: Just the basics (browser, terminal, file manager)
        - developer: Coding tools, containers, git, IDEs
        - creator: Media editing, design tools, content creation
        - gamer: Gaming support, performance tools, Discord
        - office: Productivity apps, office suite, communication
        - everything: All features enabled
      '';
      example = "developer";
    };
  };

  config = mkIf cfg.enable {
    # Apply preset configurations automatically
    omnixy.features = mkMerge [
      # Default features based on preset
      (mkIf (cfg.preset == "minimal") {
        # Only basic features
      })
      (mkIf (cfg.preset == "developer") {
        coding = mkDefault true;
        containers = mkDefault true;
        customThemes = mkDefault true;
      })
      (mkIf (cfg.preset == "creator") {
        media = mkDefault true;
        office = mkDefault true;
        customThemes = mkDefault true;
        wallpaperEffects = mkDefault true;
      })
      (mkIf (cfg.preset == "gamer") {
        gaming = mkDefault true;
        media = mkDefault true;
        communication = mkDefault true;
      })
      (mkIf (cfg.preset == "office") {
        office = mkDefault true;
        communication = mkDefault true;
        backup = mkDefault true;
      })
      (mkIf (cfg.preset == "everything") {
        coding = mkDefault true;
        containers = mkDefault true;
        gaming = mkDefault true;
        media = mkDefault true;
        office = mkDefault true;
        communication = mkDefault true;
        virtualization = mkDefault true;
        backup = mkDefault true;
        customThemes = mkDefault true;
        wallpaperEffects = mkDefault true;
      })
    ];

    # Basic system configuration
    system.autoUpgrade = {
      enable = true;
      flake = "/etc/nixos#omnixy";
      flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
      dates = "weekly";
    };

    # Enable documentation
    documentation = {
      enable = true;
      man.enable = true;
      dev.enable = cfg.features.coding or false;
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

      # Graphics support
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };

    # Docker configuration
    virtualisation = mkIf (cfg.features.containers or false) {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };

    # Programs configuration
    programs = {
      # Development programs
      git = mkIf (cfg.features.coding or false) {
        enable = true;
        lfs.enable = true;
      };

      npm = mkIf (cfg.features.coding or false) {
        enable = true;
      };

      # Gaming configuration
      steam = mkIf (cfg.features.gaming or false) {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
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

      # OmniXY specific
      OMNIXY_ROOT = "/etc/nixos";
      OMNIXY_VERSION = "1.0.0";
    };

    # Shell configuration
    programs.bash = {
      interactiveShellInit = ''
        # OmniXY bash initialization
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.npm/bin:$PATH"

        # Aliases
        alias ll='eza -la'
        alias ls='eza'
        alias cat='bat'
        alias grep='rg'
        alias find='fd'
        alias vim='nvim'
        alias vi='nvim'

        # OmniXY specific aliases
        alias omnixy-rebuild='sudo nixos-rebuild switch --flake /etc/nixos#omnixy'
        alias omnixy-update='nix flake update --flake /etc/nixos'
        alias omnixy-clean='sudo nix-collect-garbage -d'
        alias omnixy-search='nix search nixpkgs'

        # Functions
        omnixy-theme() {
          local theme=$1
          if [ -z "$theme" ]; then
            echo "Available themes: tokyo-night, catppuccin, catppuccin-latte, gruvbox, nord, everforest, rose-pine, kanagawa, matte-black, osaka-jade, ristretto"
            return 1
          fi

          echo "Switching to theme: $theme"
          # This would need to update the configuration and rebuild
          sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$theme\"/" /etc/nixos/configuration.nix
          omnixy-rebuild
        }

        omnixy-help() {
          cat << EOF
        OmniXY Commands:
        ===============
        omnixy-rebuild  - Rebuild system configuration
        omnixy-update   - Update flake inputs
        omnixy-clean    - Garbage collect nix store
        omnixy-search   - Search for packages
        omnixy-theme    - Change system theme
        omnixy-help     - Show this help message

        Key Bindings (Hyprland):
        =======================
        Super + Return   - Open terminal
        Super + B        - Open browser
        Super + E        - Open file manager
        Super + D        - Application launcher
        Super + Q        - Close window
        Super + F        - Fullscreen
        Super + Space    - Toggle floating

        For more information, visit: https://github.com/TheArctesian/omnixy
        EOF
        }

        # Welcome message
        if [ -z "$IN_NIX_SHELL" ]; then
          echo "Welcome to OmniXY! Type 'omnixy-help' for available commands."
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
      gnumake
      gcc

      # Nix tools
      nix-prefetch-git
      nixpkgs-fmt
      nil

      # Custom OmniXY scripts
      (writeShellScriptBin "omnixy-info" ''
        #!/usr/bin/env bash
        echo "🌟 OmniXY NixOS Configuration"
        echo "============================="
        echo ""
        echo "📋 Basic Settings:"
        echo "   User: ${cfg.user}"
        echo "   Theme: ${cfg.theme}"
        echo "   Preset: ${if cfg.preset != null then cfg.preset else "custom"}"
        echo "   Display Manager: ${cfg.displayManager}"
        echo ""
        echo "🎯 Active Features:"
        echo "   Development: ${if cfg.features.coding or false then "✅" else "❌"}"
        echo "   Containers: ${if cfg.features.containers or false then "✅" else "❌"}"
        echo "   Gaming: ${if cfg.features.gaming or false then "✅" else "❌"}"
        echo "   Media: ${if cfg.features.media or false then "✅" else "❌"}"
        echo "   Office: ${if cfg.features.office or false then "✅" else "❌"}"
        echo "   Communication: ${if cfg.features.communication or false then "✅" else "❌"}"
        echo "   Virtualization: ${if cfg.features.virtualization or false then "✅" else "❌"}"
        echo "   Backup: ${if cfg.features.backup or false then "✅" else "❌"}"
        echo ""
        echo "🎨 Theming:"
        echo "   Custom Themes: ${if cfg.features.customThemes or false then "✅" else "❌"}"
        echo "   Wallpaper Effects: ${if cfg.features.wallpaperEffects or false then "✅" else "❌"}"
        echo "   Color Scheme: ${if cfg.colorScheme != null then "Custom" else "Theme-based"}"
        echo "   Wallpaper: ${if cfg.wallpaper != null then toString cfg.wallpaper else "Not set"}"
        echo ""
        echo "💡 Quick Commands:"
        echo "   omnixy-setup-colors  - Configure colors and themes"
        echo "   omnixy-rebuild       - Rebuild system configuration"
        echo "   omnixy-help          - Show keyboard shortcuts and help"
        echo ""
        echo "📊 System Information:"
        nixos-version --json | ${pkgs.jq}/bin/jq -r '"   NixOS: " + .nixosVersion'
        echo "   Kernel: $(uname -r)"
        echo "   Uptime: $(uptime -p)"
      '')
    ];
  };
}