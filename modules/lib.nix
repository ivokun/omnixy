{ config, pkgs, lib, ... }:

# Shared library module for OmniXY
# Provides common utilities, helpers, and patterns for other modules

with lib;

let
  cfg = config.omnixy;

  # Helper functions for common patterns
  helpers = {
    # Check if a feature is enabled, with fallback support
    isEnabled = feature: cfg.features.${feature} or false;

    # Get user-specific paths
    userPath = path: "/home/${cfg.user}/${path}";
    configPath = path: "/home/${cfg.user}/.config/${path}";
    cachePath = path: "/home/${cfg.user}/.cache/${path}";

    # Common color helper that works with both nix-colors and fallbacks
    getColor = colorName: fallback:
      if cfg.colorScheme != null && cfg.colorScheme ? colors && cfg.colorScheme.colors ? ${colorName}
      then "#${cfg.colorScheme.colors.${colorName}}"
      else fallback;

    # Feature-based conditional inclusion
    withFeature = feature: content: mkIf (helpers.isEnabled feature) content;
    withoutFeature = feature: content: mkIf (!helpers.isEnabled feature) content;

    # User-specific home-manager configuration
    forUser = userConfig: {
      home-manager.users.${cfg.user} = userConfig;
    };

    # Package filtering with exclusion support
    filterPackages = packages:
      builtins.filter (pkg:
        let name = pkg.name or pkg.pname or "unknown";
        in !(builtins.elem name (cfg.packages.exclude or []))
      ) packages;

    # Create a standardized script with OmniXY branding
    makeScript = name: description: script: pkgs.writeShellScriptBin name ''
      #!/usr/bin/env bash
      # ${description}
      # Part of OmniXY NixOS configuration

      set -euo pipefail

      ${script}
    '';

    # Standard paths for OmniXY
    paths = {
      config = "/etc/nixos";
      logs = "/var/log/omnixy";
      cache = "/var/cache/omnixy";
      runtime = "/run/omnixy";
    };

    # Color scheme mappings (base16 colors to semantic names)
    colors = {
      # Background colors
      bg = "#1a1b26";        # Primary background
      bgAlt = "#16161e";     # Alternative background
      bgAccent = "#2f3549";  # Accent background

      # Foreground colors
      fg = "#c0caf5";        # Primary foreground
      fgAlt = "#9aa5ce";     # Alternative foreground
      fgDim = "#545c7e";     # Dimmed foreground

      # Accent colors (Tokyo Night defaults, can be overridden by themes)
      red = "#f7768e";       # Error/danger
      orange = "#ff9e64";    # Warning
      yellow = "#e0af68";    # Attention
      green = "#9ece6a";     # Success
      cyan = "#7dcfff";      # Info
      blue = "#7aa2f7";      # Primary accent
      purple = "#bb9af7";    # Secondary accent
      brown = "#db4b4b";     # Tertiary accent
    };

    # Standard application categories for consistent organization
    categories = {
      system = [ "file managers" "terminals" "system monitors" ];
      development = [ "editors" "version control" "compilers" "debuggers" ];
      multimedia = [ "media players" "image viewers" "audio tools" "video editors" ];
      productivity = [ "office suites" "note taking" "calendars" "email" ];
      communication = [ "messaging" "video calls" "social media" ];
      gaming = [ "game launchers" "emulators" "performance tools" ];
      utilities = [ "calculators" "converters" "system tools" ];
    };

    # Standard service patterns
    service = {
      # Create a basic systemd service with OmniXY defaults
      make = name: serviceConfig: {
        description = serviceConfig.description or "OmniXY ${name} service";
        wantedBy = serviceConfig.wantedBy or [ "multi-user.target" ];
        after = serviceConfig.after or [ "network.target" ];
        serviceConfig = {
          Type = serviceConfig.type or "simple";
          User = serviceConfig.user or cfg.user;
          Group = serviceConfig.group or "users";
          Restart = serviceConfig.restart or "on-failure";
          RestartSec = serviceConfig.restartSec or "5";
        } // (serviceConfig.serviceConfig or {});
      };

      # Create a user service
      user = name: serviceConfig: {
        home-manager.users.${cfg.user}.systemd.user.services.${name} = (mkHelpers cfg).service.make name (serviceConfig // {
          wantedBy = [ "default.target" ];
          after = [ "graphical-session.target" ];
        });
      };
    };
  };

in
{
  # Export shared configuration for other modules
  config = {
    # Ensure required directories exist
    systemd.tmpfiles.rules = [
      "d ${helpers.paths.logs} 0755 root root -"
      "d ${helpers.paths.cache} 0755 root root -"
      "d ${helpers.paths.runtime} 0755 root root -"
      "d ${helpers.userPath ".local/bin"} 0755 ${cfg.user} users -"
      "d ${helpers.userPath ".local/share/omnixy"} 0755 ${cfg.user} users -"
    ];

    # Global environment variables that all modules can use
    environment.variables = {
      OMNIXY_USER = cfg.user;
      OMNIXY_THEME = cfg.theme;
      OMNIXY_PRESET = cfg.preset or "custom";
      OMNIXY_CONFIG_DIR = helpers.paths.config;
      OMNIXY_CACHE_DIR = helpers.paths.cache;
    };

    # Standard shell aliases that work consistently across modules
    programs.bash.shellAliases = {
      # OmniXY management
      omnixy-rebuild = "sudo nixos-rebuild switch --flake ${helpers.paths.config}#omnixy";
      omnixy-build = "sudo nixos-rebuild build --flake ${helpers.paths.config}#omnixy";
      omnixy-test = "sudo nixos-rebuild test --flake ${helpers.paths.config}#omnixy";
      omnixy-update = "cd ${helpers.paths.config} && sudo nix flake update";
      omnixy-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      omnixy-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

      # System information
      omnixy-status = "omnixy-info";
      omnixy-features = "echo 'Enabled features:' && omnixy-info | grep -A 10 'Active Features'";

      # Quick navigation
      omnixy-config = "cd ${helpers.paths.config}";
      omnixy-logs = "cd ${helpers.paths.logs}";
    };

    # Provide a global package for accessing OmniXY utilities
    environment.systemPackages = [
      (helpers.makeScript "omnixy-lib-test" "Test OmniXY library functions" ''
        echo "🧪 OmniXY Library Test"
        echo "===================="
        echo ""
        echo "Configuration:"
        echo "  User: ${cfg.user}"
        echo "  Theme: ${cfg.theme}"
        echo "  Preset: ${cfg.preset or "none"}"
        echo ""
        echo "Colors (base16 scheme):"
        echo "  Background: ${helpers.colors.bg}"
        echo "  Foreground: ${helpers.colors.fg}"
        echo "  Primary: ${helpers.colors.blue}"
        echo "  Success: ${helpers.colors.green}"
        echo "  Warning: ${helpers.colors.yellow}"
        echo "  Error: ${helpers.colors.red}"
        echo ""
        echo "Paths:"
        echo "  Config: ${helpers.paths.config}"
        echo "  Logs: ${helpers.paths.logs}"
        echo "  Cache: ${helpers.paths.cache}"
        echo "  User home: ${helpers.userPath ""}"
        echo ""
        echo "Features:"
        ${concatStringsSep "\n" (mapAttrsToList (name: enabled:
          ''echo "  ${name}: ${if enabled then "✅" else "❌"}"''
        ) cfg.features)}
      '')
    ];
  };
}