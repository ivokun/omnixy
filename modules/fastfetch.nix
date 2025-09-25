{ config, pkgs, lib, ... }:

# Fastfetch system information display for OmniXY
# Beautiful system information with OmniXY branding

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Add fastfetch and convenience scripts to system packages
    environment.systemPackages = (with pkgs; [
      fastfetch
    ]) ++ [
      # Convenience scripts
      (omnixy.makeScript "omnixy-info" "Show OmniXY system information" ''
        fastfetch --config /etc/omnixy/fastfetch/config.jsonc
      '')

      (omnixy.makeScript "omnixy-about" "Show OmniXY about screen" ''
        clear
        cat /etc/omnixy/branding/about.txt
        echo
        echo "Theme: ${cfg.theme}"
        echo "Preset: ${cfg.preset or "custom"}"
        echo "User: ${cfg.user}"
        echo "NixOS Version: $(nixos-version)"
        echo
        echo "Visit: https://github.com/TheArctesian/omnixy"
      '')
    ];

    # Create OmniXY branding directory
    environment.etc."omnixy/branding/logo.txt".text = ''

      ███████╗███╗   ███╗███╗   ██╗██╗██╗  ██╗██╗   ██╗
      ██╔════╝████╗ ████║████╗  ██║██║╚██╗██╔╝╚██╗ ██╔╝
      ██║     ██╔████╔██║██╔██╗ ██║██║ ╚███╔╝  ╚████╔╝
      ██║     ██║╚██╔╝██║██║╚██╗██║██║ ██╔██╗   ╚██╔╝
      ███████╗██║ ╚═╝ ██║██║ ╚████║██║██╔╝ ██╗   ██║
      ╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝

                   Declarative NixOS Configuration
    '';

    environment.etc."omnixy/branding/about.txt".text = ''
      ╭─────────────────────────────────────────────────────╮
      │                                                     │
      │    ██████╗ ███╗   ███╗███╗   ██╗██╗██╗  ██╗██╗   ██╗│
      │   ██╔═══██╗████╗ ████║████╗  ██║██║╚██╗██╔╝╚██╗ ██╔╝│
      │   ██║   ██║██╔████╔██║██╔██╗ ██║██║ ╚███╔╝  ╚████╔╝ │
      │   ██║   ██║██║╚██╔╝██║██║╚██╗██║██║ ██╔██╗   ╚██╔╝  │
      │   ╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║██╔╝ ██╗   ██║   │
      │    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝   │
      │                                                     │
      │         🚀 Declarative • 🎨 Beautiful • ⚡ Fast      │
      │                                                     │
      ╰─────────────────────────────────────────────────────╯
    '';

    # Create fastfetch configuration
    environment.etc."omnixy/fastfetch/config.jsonc".text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "type": "file",
          "source": "/etc/omnixy/branding/about.txt",
          "color": {
            "1": "cyan",
            "2": "blue"
          },
          "padding": {
            "top": 1,
            "right": 4,
            "left": 2
          }
        },
        "modules": [
          "break",
          {
            "type": "custom",
            "format": "\u001b[90m┌─────────────────── Hardware ───────────────────┐"
          },
          {
            "type": "host",
            "key": "  󰌢 Host",
            "keyColor": "cyan"
          },
          {
            "type": "cpu",
            "key": "  󰻠 CPU",
            "keyColor": "cyan"
          },
          {
            "type": "gpu",
            "key": "  󰍛 GPU",
            "keyColor": "cyan"
          },
          {
            "type": "memory",
            "key": "  󰍛 Memory",
            "keyColor": "cyan"
          },
          {
            "type": "disk",
            "key": "  󰋊 Disk (/)",
            "keyColor": "cyan"
          },
          {
            "type": "custom",
            "format": "\u001b[90m├─────────────────── Software ───────────────────┤"
          },
          {
            "type": "os",
            "key": "  󰣇 OS",
            "keyColor": "blue"
          },
          {
            "type": "kernel",
            "key": "  󰌽 Kernel",
            "keyColor": "blue"
          },
          {
            "type": "de",
            "key": "  󰧨 DE",
            "keyColor": "blue"
          },
          {
            "type": "wm",
            "key": "  󰖸 WM",
            "keyColor": "blue"
          },
          {
            "type": "wmtheme",
            "key": "  󰏘 Theme",
            "keyColor": "blue"
          },
          {
            "type": "shell",
            "key": "  󰆍 Shell",
            "keyColor": "blue"
          },
          {
            "type": "terminal",
            "key": "  󰆍 Terminal",
            "keyColor": "blue"
          },
          {
            "type": "custom",
            "format": "\u001b[90m├─────────────────── OmniXY ─────────────────────┤"
          },
          {
            "type": "custom",
            "format": "  󰣇 Theme: ${cfg.theme}",
            "keyColor": "magenta"
          },
          {
            "type": "custom",
            "format": "  󰣇 Preset: ${cfg.preset or "custom"}",
            "keyColor": "magenta"
          },
          {
            "type": "custom",
            "format": "  󰣇 User: ${cfg.user}",
            "keyColor": "magenta"
          },
          {
            "type": "packages",
            "key": "  󰏖 Packages",
            "keyColor": "magenta"
          },
          {
            "type": "custom",
            "format": "\u001b[90m└─────────────────────────────────────────────────┘"
          },
          "break"
        ]
      }
    '';

    # Convenience scripts are now consolidated above

    # Add to user environment
    home-manager.users.${config.omnixy.user} = {
      # Set XDG config dir for fastfetch
      xdg.configFile."fastfetch/config.jsonc".source =
        config.environment.etc."omnixy/fastfetch/config.jsonc".source;

      # Add shell aliases
      programs.bash.shellAliases = {
        neofetch = "omnixy-info";
        screenfetch = "omnixy-info";
        sysinfo = "omnixy-info";
        about = "omnixy-about";
      };

      programs.zsh.shellAliases = {
        neofetch = "omnixy-info";
        screenfetch = "omnixy-info";
        sysinfo = "omnixy-info";
        about = "omnixy-about";
      };

      programs.fish.shellAliases = {
        neofetch = "omnixy-info";
        screenfetch = "omnixy-info";
        sysinfo = "omnixy-info";
        about = "omnixy-about";
      };
    };
  };
}