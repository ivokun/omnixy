{ config, pkgs, lib, ... }:

# Ristretto theme for OmniXY
# A warm, coffee-inspired theme with rich brown and cream tones

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Ristretto color palette - inspired by coffee and warm tones
  colors = {
    # Base colors - warm browns and creams
    bg = "#2b1f17";          # Dark coffee background
    bg_light = "#3d2a1f";    # Lighter coffee
    bg_lighter = "#4f3426";  # Even lighter coffee
    bg_accent = "#5d3e2e";   # Accent background

    # Foreground colors - cream and light browns
    fg = "#e6d9db";          # Main foreground (from omarchy)
    fg_dim = "#c4b5a0";      # Dimmed cream
    fg_muted = "#a08d7a";    # Muted cream

    # Coffee-inspired accent colors
    cream = "#e6d9db";       # Cream (main accent from omarchy)
    latte = "#d4c4b0";       # Latte
    mocha = "#b8997a";       # Mocha
    espresso = "#8b6f47";    # Espresso
    cappuccino = "#c9a96e";  # Cappuccino

    # Warm accent colors
    amber = "#d4a574";       # Amber
    caramel = "#c19a6b";     # Caramel
    cinnamon = "#a67c5a";    # Cinnamon
    vanilla = "#e8dcc6";     # Vanilla

    # Status colors - coffee-tinted
    red = "#d67c7c";         # Warm red
    orange = "#d4925a";      # Coffee orange
    yellow = "#d4c969";      # Warm yellow
    green = "#81a56a";       # Muted green
    blue = "#6b8bb3";        # Muted blue
    purple = "#a67cb8";      # Muted purple
    cyan = "#6ba3a3";        # Muted cyan

    # Special UI colors
    border = "#5d3e2e";      # Border color
    shadow = "#1a1008";      # Shadow color
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/ristretto/1-ristretto.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(e6d9db)
            col.inactive_border = rgba(5d3e2eaa)
        }
        decoration {
            col.shadow = rgba(1a1008ee)
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
        OMNIXY_THEME_COLORS_ACCENT = colors.cream;
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
          colors.cyan        # cyan
          colors.fg_dim      # white
          colors.espresso    # bright black
          colors.red         # bright red
          colors.green       # bright green
          colors.amber       # bright yellow
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
          cursor = colors.cream;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.amber;

          # Tab colors
          active_tab_background = colors.cream;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_light;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.cream;
          inactive_border_color = colors.mocha;
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
              cursor = colors.cream;
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
              black = colors.espresso;
              red = colors.red;
              green = colors.green;
              yellow = colors.amber;
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
            border-bottom: 2px solid ${colors.cream};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.cream};
            border-bottom-color: ${colors.cream};
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
            color: ${colors.amber};
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
            border-color = mkLiteral colors.cream;
            separatorcolor = mkLiteral colors.bg_light;
            scrollbar-handle = mkLiteral colors.cream;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.cream;
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
          border-color = colors.cream;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.cream;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Monokai";
          "workbench.preferredDarkColorTheme" = "Monokai";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=dark
          colorscheme monokai
        '';
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Monokai Extended";

      # btop theme
      programs.btop.settings.color_theme = "monokai";

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
            style = "bold ${colors.amber}";
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