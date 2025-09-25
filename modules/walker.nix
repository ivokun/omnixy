{ config, pkgs, lib, ... }:

# Walker app launcher configuration for OmniXY
# Modern replacement for Rofi with better Wayland integration

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Add walker to system packages
    environment.systemPackages = with pkgs; [
      walker
    ];

    # Create Walker configuration
    environment.etc."omnixy/walker/config.json".text = builtins.toJSON {
      # General configuration
      placeholder = "Search applications, files, and more...";
      fullscreen = false;
      layer = "overlay";
      modules = [
        {
          name = "applications";
          src = "applications";
          transform = "uppercase";
        }
        {
          name = "runner";
          src = "runner";
        }
        {
          name = "websearch";
          src = "websearch";
          engines = [
            {
              name = "Google";
              url = "https://www.google.com/search?q=%s";
              icon = "web-browser";
            }
            {
              name = "GitHub";
              url = "https://github.com/search?q=%s";
              icon = "github";
            }
            {
              name = "NixOS Packages";
              url = "https://search.nixos.org/packages?query=%s";
              icon = "nix-snowflake";
            }
          ];
        }
        {
          name = "finder";
          src = "finder";
          dirs = [
            "/home/${cfg.user}"
            "/home/${cfg.user}/Documents"
            "/home/${cfg.user}/Downloads"
            "/home/${cfg.user}/Desktop"
          ];
        }
        {
          name = "calc";
          src = "calc";
        }
      ];

      # UI Configuration
      ui = {
        anchors = {
          top = false;
          left = true;
          right = false;
          bottom = false;
        };
        margin = {
          top = 100;
          bottom = 0;
          left = 100;
          right = 0;
        };
        width = 600;
        height = 500;
        show_initial_entries = true;
        show_search_text = true;
        scroll_height = 300;
      };

      # Search configuration
      search = {
        delay = 100;
        placeholder = "Type to search...";
        force_keyboard_focus = true;
      };

      # List configuration
      list = {
        height = 200;
        always_show = true;
        max_entries = 50;
      };

      # Icons
      icons = {
        theme = "Papirus";
        size = 32;
      };

      # Theming based on current theme
      theme = if cfg.theme == "gruvbox" then "gruvbox"
        else if cfg.theme == "nord" then "nord"
        else if cfg.theme == "catppuccin" then "catppuccin"
        else if cfg.theme == "tokyo-night" then "tokyo-night"
        else "default";
    };

    # Create Walker CSS theme files
    environment.etc."omnixy/walker/themes/gruvbox.css".text = ''
      * {
        color: #ebdbb2;
        background-color: #282828;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      window {
        background-color: rgba(40, 40, 40, 0.95);
        border: 2px solid #a89984;
        border-radius: 12px;
      }

      #search {
        background-color: #3c3836;
        border: 1px solid #665c54;
        border-radius: 8px;
        padding: 8px 12px;
        margin: 12px;
        color: #ebdbb2;
      }

      #search:focus {
        border-color: #d79921;
      }

      #list {
        background-color: transparent;
        padding: 0 12px 12px 12px;
      }

      .item {
        padding: 8px 12px;
        border-radius: 6px;
        margin-bottom: 2px;
      }

      .item:selected {
        background-color: #504945;
        color: #fbf1c7;
      }

      .item:hover {
        background-color: #3c3836;
      }

      .item .icon {
        margin-right: 12px;
        min-width: 32px;
      }

      .item .text {
        font-weight: normal;
      }

      .item .sub {
        font-size: 12px;
        color: #a89984;
      }
    '';

    environment.etc."omnixy/walker/themes/nord.css".text = ''
      * {
        color: #eceff4;
        background-color: #2e3440;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      window {
        background-color: rgba(46, 52, 64, 0.95);
        border: 2px solid #4c566a;
        border-radius: 12px;
      }

      #search {
        background-color: #3b4252;
        border: 1px solid #4c566a;
        border-radius: 8px;
        padding: 8px 12px;
        margin: 12px;
        color: #eceff4;
      }

      #search:focus {
        border-color: #5e81ac;
      }

      #list {
        background-color: transparent;
        padding: 0 12px 12px 12px;
      }

      .item {
        padding: 8px 12px;
        border-radius: 6px;
        margin-bottom: 2px;
      }

      .item:selected {
        background-color: #434c5e;
        color: #eceff4;
      }

      .item:hover {
        background-color: #3b4252;
      }

      .item .icon {
        margin-right: 12px;
        min-width: 32px;
      }

      .item .text {
        font-weight: normal;
      }

      .item .sub {
        font-size: 12px;
        color: #81a1c1;
      }
    '';

    environment.etc."omnixy/walker/themes/catppuccin.css".text = ''
      * {
        color: #cdd6f4;
        background-color: #1e1e2e;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      window {
        background-color: rgba(30, 30, 46, 0.95);
        border: 2px solid #6c7086;
        border-radius: 12px;
      }

      #search {
        background-color: #313244;
        border: 1px solid #45475a;
        border-radius: 8px;
        padding: 8px 12px;
        margin: 12px;
        color: #cdd6f4;
      }

      #search:focus {
        border-color: #89b4fa;
      }

      #list {
        background-color: transparent;
        padding: 0 12px 12px 12px;
      }

      .item {
        padding: 8px 12px;
        border-radius: 6px;
        margin-bottom: 2px;
      }

      .item:selected {
        background-color: #45475a;
        color: #cdd6f4;
      }

      .item:hover {
        background-color: #313244;
      }

      .item .icon {
        margin-right: 12px;
        min-width: 32px;
      }

      .item .text {
        font-weight: normal;
      }

      .item .sub {
        font-size: 12px;
        color: #89dceb;
      }
    '';

    environment.etc."omnixy/walker/themes/tokyo-night.css".text = ''
      * {
        color: #c0caf5;
        background-color: #1a1b26;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      window {
        background-color: rgba(26, 27, 38, 0.95);
        border: 2px solid #414868;
        border-radius: 12px;
      }

      #search {
        background-color: #24283b;
        border: 1px solid #414868;
        border-radius: 8px;
        padding: 8px 12px;
        margin: 12px;
        color: #c0caf5;
      }

      #search:focus {
        border-color: #7aa2f7;
      }

      #list {
        background-color: transparent;
        padding: 0 12px 12px 12px;
      }

      .item {
        padding: 8px 12px;
        border-radius: 6px;
        margin-bottom: 2px;
      }

      .item:selected {
        background-color: #414868;
        color: #c0caf5;
      }

      .item:hover {
        background-color: #24283b;
      }

      .item .icon {
        margin-right: 12px;
        min-width: 32px;
      }

      .item .text {
        font-weight: normal;
      }

      .item .sub {
        font-size: 12px;
        color: #7dcfff;
      }
    '';

    # Add to user environment
    omnixy.forUser {
      # Set XDG config dir for Walker
      xdg.configFile."walker/config.json".source =
        config.environment.etc."omnixy/walker/config.json".source;

      # Theme-specific CSS
      xdg.configFile."walker/themes/style.css".source =
        config.environment.etc."omnixy/walker/themes/${cfg.theme}.css".source;

      # Add shell aliases
      programs.bash.shellAliases = {
        launcher = "walker";
        run = "walker --modules runner";
        apps = "walker --modules applications";
        files = "walker --modules finder";
      };

      programs.zsh.shellAliases = {
        launcher = "walker";
        run = "walker --modules runner";
        apps = "walker --modules applications";
        files = "walker --modules finder";
      };

      programs.fish.shellAliases = {
        launcher = "walker";
        run = "walker --modules runner";
        apps = "walker --modules applications";
        files = "walker --modules finder";
      };
    };

    # Create convenience scripts
    environment.systemPackages = [
      (omnixy.makeScript "omnixy-launcher" "Launch OmniXY app launcher" ''
        walker --config ~/.config/walker/config.json --css ~/.config/walker/themes/style.css
      '')

      (omnixy.makeScript "omnixy-run" "Quick command runner" ''
        walker --modules runner --config ~/.config/walker/config.json --css ~/.config/walker/themes/style.css
      '')

      (omnixy.makeScript "omnixy-apps" "Application launcher" ''
        walker --modules applications --config ~/.config/walker/config.json --css ~/.config/walker/themes/style.css
      '')

      (omnixy.makeScript "omnixy-files" "File finder" ''
        walker --modules finder --config ~/.config/walker/config.json --css ~/.config/walker/themes/style.css
      '')
    ];
  };
}