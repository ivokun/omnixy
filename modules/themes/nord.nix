{ config, pkgs, lib, ... }:

# Nord theme for OmniXY
# An arctic, north-bluish color palette

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Nord color palette
  colors = {
    # Polar Night
    bg = "#2e3440";        # Dark background
    bg_dark = "#242933";   # Darker background
    bg_light = "#3b4252";  # Light background
    bg_lighter = "#434c5e"; # Lighter background

    # Snow Storm
    fg = "#eceff4";        # Light foreground
    fg_dim = "#d8dee9";    # Dimmed foreground
    fg_dark = "#e5e9f0";   # Dark foreground

    # Frost
    blue = "#5e81ac";      # Primary blue
    blue_light = "#88c0d0"; # Light blue
    blue_bright = "#81a1c1"; # Bright blue
    teal = "#8fbcbb";      # Teal

    # Aurora
    red = "#bf616a";       # Red
    orange = "#d08770";    # Orange
    yellow = "#ebcb8b";    # Yellow
    green = "#a3be8c";     # Green
    purple = "#b48ead";    # Purple

    # UI colors
    accent = "#88c0d0";    # Primary accent (light blue)
    warning = "#ebcb8b";   # Warning (yellow)
    error = "#bf616a";     # Error (red)
    success = "#a3be8c";   # Success (green)
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/nord/1-nord.png;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(D8DEE9)
            col.inactive_border = rgba(4c566aaa)
        }
        decoration {
            col.shadow = rgba(2e3440ee)
        }
      '';

      # GTK theme
      programs.dconf.enable = true;

      # Environment variables for consistent theming
      environment.variables = {
        GTK_THEME = "Adwaita-dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";
        OMNIXY_THEME_COLORS_BG = colors.bg;
        OMNIXY_THEME_COLORS_FG = colors.fg;
        OMNIXY_THEME_COLORS_ACCENT = colors.accent;
      };

      # Console colors
      console = {
        colors = [
          colors.bg_dark    # black
          colors.red        # red
          colors.green      # green
          colors.yellow     # yellow
          colors.blue       # blue
          colors.purple     # magenta
          colors.teal       # cyan
          colors.fg_dim     # white
          colors.bg_lighter # bright black
          colors.red        # bright red
          colors.green      # bright green
          colors.yellow     # bright yellow
          colors.blue_light # bright blue
          colors.purple     # bright magenta
          colors.blue_bright # bright cyan
          colors.fg         # bright white
        ];
      };
    }

    # User-specific theme configuration
    (omnixy.forUser {
      # GTK configuration
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      # Qt theming
      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };

      # Kitty terminal theme
      programs.kitty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        themeFile = "Nord";
        settings = {
          background = colors.bg;
          foreground = colors.fg;
          selection_background = colors.bg_light;
          selection_foreground = colors.fg;

          # Cursor colors
          cursor = colors.fg;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.accent;

          # Tab colors
          active_tab_background = colors.accent;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_light;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.accent;
          inactive_border_color = colors.bg_lighter;
        };
      };

      # Alacritty terminal theme
      programs.alacritty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        settings = {
          colors = {
            primary = {
              background = colors.bg;
              foreground = colors.fg;
            };
            cursor = {
              text = colors.bg;
              cursor = colors.fg;
            };
            normal = {
              black = colors.bg_dark;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.teal;
              white = colors.fg_dim;
            };
            bright = {
              black = colors.bg_lighter;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue_light;
              magenta = colors.purple;
              cyan = colors.blue_bright;
              white = colors.fg;
            };
          };
        };
      };

      # Waybar theme
      programs.waybar = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
            border: none;
            border-radius: 0;
            min-height: 0;
          }

          window#waybar {
            background: ${colors.bg};
            color: ${colors.fg};
            border-bottom: 2px solid ${colors.accent};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.accent};
            border-bottom-color: ${colors.accent};
          }

          #workspaces button:hover {
            color: ${colors.fg};
            background: ${colors.bg_light};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.bg_light};
            color: ${colors.fg};
          }

          #battery.critical {
            color: ${colors.error};
          }

          #battery.warning {
            color: ${colors.warning};
          }
        '';
      };

      # Rofi theme
      programs.rofi = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        theme = {
          "*" = {
            background-color = mkLiteral colors.bg;
            foreground-color = mkLiteral colors.fg;
            border-color = mkLiteral colors.accent;
            separatorcolor = mkLiteral colors.bg_light;
            scrollbar-handle = mkLiteral colors.accent;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.accent;
            text-color = mkLiteral colors.bg;
          };
        };
      };

      # Mako notification theme
      services.mako = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        settings = {
          font = "JetBrainsMono Nerd Font 10";
          background-color = colors.bg;
          text-color = colors.fg;
          border-color = colors.accent;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.accent;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          arcticicestudio.nord-visual-studio-code
        ];
        userSettings = {
          "workbench.colorTheme" = "Nord";
          "workbench.preferredDarkColorTheme" = "Nord";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          colorscheme nord
          set background=dark
        '';
        plugins = with pkgs.vimPlugins; [
          nord-nvim
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Nord";

      # btop theme - using a Nord-inspired theme
      programs.btop.settings.color_theme = "nord";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.bg_light ];
          selectedRangeBgColor = [ colors.bg_light ];
        };
      };

      # Zsh/shell prompt colors
      programs.starship = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          character = {
            success_symbol = "[➜](bold ${colors.success})";
            error_symbol = "[➜](bold ${colors.error})";
          };
          directory = {
            style = "bold ${colors.blue_light}";
          };
          git_branch = {
            style = "bold ${colors.purple}";
          };
          git_status = {
            style = "bold ${colors.warning}";
          };
        };
      };
    })
  ]);
}