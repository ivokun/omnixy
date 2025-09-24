{ config, pkgs, lib, ... }:

{
  # Catppuccin Mocha theme configuration
  config = {
    # Color palette
    environment.variables = {
      OMARCHY_THEME = "catppuccin";
      OMARCHY_THEME_BG = "#1e1e2e";
      OMARCHY_THEME_FG = "#cdd6f4";
      OMARCHY_THEME_ACCENT = "#cba6f7";
    };

    # Home-manager theme configuration
    home-manager.users.${config.omarchy.user or "user"} = {
      # Alacritty theme
      programs.alacritty.settings.colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          dim_foreground = "#a6adc8";
          bright_foreground = "#cdd6f4";
        };

        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };

        vi_mode_cursor = {
          text = "#1e1e2e";
          cursor = "#b4befe";
        };

        search = {
          matches = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
          focused_match = {
            foreground = "#1e1e2e";
            background = "#a6e3a1";
          };
        };

        hints = {
          start = {
            foreground = "#1e1e2e";
            background = "#f9e2af";
          };
          end = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
        };

        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };

        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };

        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };

        dim = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
      };

      # GTK theme
      gtk = {
        theme = {
          name = "Catppuccin-Mocha-Standard-Lavender-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["lavender"];
            size = "standard";
            variant = "mocha";
          };
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "lavender";
          };
        };
      };

      # Starship theme
      programs.starship.settings = {
        palette = "catppuccin_mocha";

        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };

        format = ''
          [╭─](surface2)$username[@](yellow)$hostname [in ](text)$directory$git_branch$git_status$cmd_duration
          [╰─](surface2)$character
        '';

        character = {
          success_symbol = "[➜](green)";
          error_symbol = "[➜](red)";
        };

        directory = {
          style = "blue";
        };

        git_branch = {
          style = "mauve";
          symbol = " ";
        };

        git_status = {
          style = "red";
        };
      };

      # Mako notification theme
      services.mako = {
        backgroundColor = "#1e1e2e";
        textColor = "#cdd6f4";
        borderColor = "#cba6f7";
        progressColor = "#cba6f7";
        defaultTimeout = 5000;
        borderRadius = 10;
        borderSize = 2;
        font = "JetBrainsMono Nerd Font 10";
        padding = "10";
        margin = "20";
      };
    };

    # Hyprland theme colors
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "set-catppuccin-colors" ''
        #!/usr/bin/env bash
        # Set Catppuccin Mocha colors in Hyprland
        hyprctl keyword general:col.active_border "rgba(cba6f7ee) rgba(89b4faee) 45deg"
        hyprctl keyword general:col.inactive_border "rgba(585b70aa)"
        hyprctl keyword decoration:col.shadow "rgba(1e1e2eee)"
      '')
    ];
  };
}