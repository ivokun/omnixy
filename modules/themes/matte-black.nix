{ config, pkgs, lib, ... }:

# Matte Black theme for OmniXY
# A sleek, professional dark theme with matte black aesthetics

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Matte Black color palette
  colors = {
    # Base colors - various shades of black and gray
    bg = "#0d1117";          # Very dark background
    bg_light = "#161b22";    # Slightly lighter background
    bg_lighter = "#21262d";  # Even lighter background
    bg_accent = "#30363d";   # Accent background

    # Foreground colors
    fg = "#f0f6fc";          # Light foreground
    fg_dim = "#8b949e";      # Dimmed foreground
    fg_muted = "#6e7681";    # Muted foreground

    # Accent colors - muted and professional
    white = "#ffffff";       # Pure white
    gray = "#8A8A8D";        # Main accent gray (from omarchy)
    gray_light = "#aeb7c2";  # Light gray
    gray_dark = "#484f58";   # Dark gray

    # Status colors - muted tones
    red = "#f85149";         # Error red
    orange = "#fd7e14";      # Warning orange
    yellow = "#d29922";      # Attention yellow
    green = "#238636";       # Success green
    blue = "#58a6ff";        # Info blue
    purple = "#a5a2ff";      # Purple accent
    cyan = "#76e3ea";        # Cyan accent

    # Special UI colors
    border = "#30363d";      # Border color
    shadow = "#010409";      # Shadow color
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/matte-black/1-matte-black.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(8A8A8D)
            col.inactive_border = rgba(30363daa)
        }
        decoration {
            col.shadow = rgba(010409ee)
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
        OMNIXY_THEME_COLORS_ACCENT = colors.gray;
      };

      # Console colors
      console = {
        colors = [
          colors.bg          # black
          colors.red         # red
          colors.green       # green
          colors.yellow      # yellow
          colors.blue        # blue
          colors.purple      # magenta
          colors.cyan        # cyan
          colors.fg_dim      # white
          colors.gray_dark   # bright black
          colors.red         # bright red
          colors.green       # bright green
          colors.yellow      # bright yellow
          colors.blue        # bright blue
          colors.purple      # bright magenta
          colors.cyan        # bright cyan
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
          cursor = colors.fg;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.blue;

          # Tab colors
          active_tab_background = colors.gray;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_light;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.gray;
          inactive_border_color = colors.gray_dark;
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
              black = colors.bg_light;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.cyan;
              white = colors.fg_dim;
            };
            bright = {
              black = colors.gray_dark;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.cyan;
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
            border-bottom: 2px solid ${colors.gray};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.gray};
            border-bottom-color: ${colors.gray};
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
            border-color = mkLiteral colors.gray;
            separatorcolor = mkLiteral colors.bg_light;
            scrollbar-handle = mkLiteral colors.gray;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.gray;
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
          border-color = colors.gray;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.gray;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "GitHub Dark Default";
          "workbench.preferredDarkColorTheme" = "GitHub Dark Default";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=dark
          colorscheme github_dark_default
        '';
      };

      # Git diff and bat theme
      programs.bat.config.theme = "GitHub";

      # btop theme
      programs.btop.settings.color_theme = "adapta";

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
            success_symbol = "[➜](bold ${colors.green})";
            error_symbol = "[➜](bold ${colors.red})";
          };
          directory = {
            style = "bold ${colors.blue}";
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