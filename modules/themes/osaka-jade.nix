{ config, pkgs, lib, ... }:

# Osaka Jade theme for OmniXY
# A sophisticated green-tinted dark theme with jade accents

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Osaka Jade color palette
  colors = {
    # Base colors - dark with jade undertones
    bg = "#0f1419";          # Very dark background with slight jade tint
    bg_light = "#1a2026";    # Lighter background
    bg_lighter = "#252d33";  # Even lighter background
    bg_accent = "#2d3640";   # Accent background

    # Foreground colors
    fg = "#c9c7cd";          # Light foreground
    fg_dim = "#828691";      # Dimmed foreground
    fg_muted = "#5c6166";    # Muted foreground

    # Jade accent colors
    jade = "#71CEAD";        # Main jade accent (from omarchy)
    jade_light = "#8dd4b8";  # Light jade
    jade_dark = "#5ba896";   # Dark jade
    jade_muted = "#4a8f7d";  # Muted jade

    # Supporting colors
    teal = "#4fd6be";        # Teal
    mint = "#88e5d3";        # Mint green
    seafoam = "#a0f0e0";     # Seafoam

    # Status colors - jade-tinted
    red = "#f07178";         # Error red
    orange = "#ffb454";      # Warning orange
    yellow = "#e6c384";      # Attention yellow
    green = "#71CEAD";       # Success (using jade)
    blue = "#6bb6ff";        # Info blue
    purple = "#c991e1";      # Purple
    cyan = "#71CEAD";        # Cyan (using jade)

    # Special UI colors
    border = "#2d3640";      # Border color
    shadow = "#0a0d11";      # Shadow color
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/osaka-jade/1-osaka-jade-bg.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(71CEAD)
            col.inactive_border = rgba(2d3640aa)
        }
        decoration {
            col.shadow = rgba(0a0d11ee)
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
        OMNIXY_THEME_COLORS_ACCENT = colors.jade;
      };

      # Console colors
      console = {
        colors = [
          colors.bg_light    # black
          colors.red         # red
          colors.green       # green
          colors.yellow      # yellow
          colors.blue        # blue
          colors.purple      # magenta
          colors.jade        # cyan (using jade)
          colors.fg_dim      # white
          colors.bg_lighter  # bright black
          colors.red         # bright red
          colors.jade_light  # bright green (jade)
          colors.yellow      # bright yellow
          colors.blue        # bright blue
          colors.purple      # bright magenta
          colors.seafoam     # bright cyan
          colors.fg          # bright white
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
        settings = {
          background = colors.bg;
          foreground = colors.fg;
          selection_background = colors.bg_lighter;
          selection_foreground = colors.fg;

          # Cursor colors
          cursor = colors.jade;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.jade_light;

          # Tab colors
          active_tab_background = colors.jade;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_light;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.jade;
          inactive_border_color = colors.jade_muted;
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
              cursor = colors.jade;
            };
            normal = {
              black = colors.bg_light;
              red = colors.red;
              green = colors.jade;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.teal;
              white = colors.fg_dim;
            };
            bright = {
              black = colors.bg_lighter;
              red = colors.red;
              green = colors.jade_light;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.seafoam;
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
            border-bottom: 2px solid ${colors.jade};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.jade};
            border-bottom-color: ${colors.jade};
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
            color: ${colors.red};
          }

          #battery.warning {
            color: ${colors.yellow};
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
            border-color = mkLiteral colors.jade;
            separatorcolor = mkLiteral colors.bg_light;
            scrollbar-handle = mkLiteral colors.jade;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.jade;
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
          border-color = colors.jade;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.jade;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Ayu Dark";
          "workbench.preferredDarkColorTheme" = "Ayu Dark";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=dark
          colorscheme ayu
        '';
      };

      # Git diff and bat theme
      programs.bat.config.theme = "ansi";

      # btop theme
      programs.btop.settings.color_theme = "ayu-dark";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.bg_lighter ];
          selectedRangeBgColor = [ colors.bg_lighter ];
        };
      };

      # Zsh/shell prompt colors
      programs.starship = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          character = {
            success_symbol = "[➜](bold ${colors.jade})";
            error_symbol = "[➜](bold ${colors.red})";
          };
          directory = {
            style = "bold ${colors.jade_light}";
          };
          git_branch = {
            style = "bold ${colors.purple}";
          };
          git_status = {
            style = "bold ${colors.yellow}";
          };
        };
      };
    })
  ]);
}