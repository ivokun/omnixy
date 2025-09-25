{ config, pkgs, lib, ... }:

# Everforest theme for OmniXY
# A green based color scheme with warm, comfortable tones

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Everforest Dark color palette
  colors = {
    # Background colors
    bg = "#2d353b";        # Dark background
    bg_dim = "#232a2e";    # Dimmer background
    bg_red = "#3c302a";    # Red background
    bg_visual = "#543a48"; # Visual selection background
    bg_yellow = "#45443c"; # Yellow background
    bg_green = "#3d4313";  # Green background
    bg_blue = "#384b55";   # Blue background

    # Foreground colors
    fg = "#d3c6aa";        # Light foreground
    red = "#e67e80";       # Red
    orange = "#e69875";    # Orange
    yellow = "#dbbc7f";    # Yellow
    green = "#a7c080";     # Green
    aqua = "#83c092";      # Aqua
    blue = "#7fbbb3";      # Blue
    purple = "#d699b6";    # Purple
    grey0 = "#7a8478";     # Grey 0
    grey1 = "#859289";     # Grey 1
    grey2 = "#9da9a0";     # Grey 2

    # Status line colors
    statusline1 = "#a7c080"; # Green for active
    statusline2 = "#d3c6aa"; # Foreground for inactive
    statusline3 = "#e67e80"; # Red for errors
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/everforest/1-everforest.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(d3c6aa)
            col.inactive_border = rgba(445349aa)
        }
        decoration {
            col.shadow = rgba(232a2eee)
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
        OMNIXY_THEME_COLORS_ACCENT = colors.green;
      };

      # Console colors
      console = {
        colors = [
          colors.bg_dim     # black
          colors.red        # red
          colors.green      # green
          colors.yellow     # yellow
          colors.blue       # blue
          colors.purple     # magenta
          colors.aqua       # cyan
          colors.grey1      # white
          colors.grey0      # bright black
          colors.red        # bright red
          colors.green      # bright green
          colors.yellow     # bright yellow
          colors.blue       # bright blue
          colors.purple     # bright magenta
          colors.aqua       # bright cyan
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
        themeFile = "Everforest Dark Medium";
        settings = {
          background = colors.bg;
          foreground = colors.fg;
          selection_background = colors.bg_visual;
          selection_foreground = colors.fg;

          # Cursor colors
          cursor = colors.fg;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.blue;

          # Tab colors
          active_tab_background = colors.green;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_dim;
          inactive_tab_foreground = colors.grey1;

          # Window border colors
          active_border_color = colors.green;
          inactive_border_color = colors.grey0;
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
              black = colors.bg_dim;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.aqua;
              white = colors.grey1;
            };
            bright = {
              black = colors.grey0;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.aqua;
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
            border-bottom: 2px solid ${colors.green};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.grey1};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.green};
            border-bottom-color: ${colors.green};
          }

          #workspaces button:hover {
            color: ${colors.fg};
            background: ${colors.bg_dim};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.bg_dim};
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
            border-color = mkLiteral colors.green;
            separatorcolor = mkLiteral colors.bg_dim;
            scrollbar-handle = mkLiteral colors.green;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.green;
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
          border-color = colors.green;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.green;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Everforest Dark";
          "workbench.preferredDarkColorTheme" = "Everforest Dark";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          let g:everforest_background = 'medium'
          let g:everforest_better_performance = 1
          colorscheme everforest
          set background=dark
        '';
        plugins = with pkgs.vimPlugins; [
          everforest
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Monokai Extended";

      # btop theme - using a forest-inspired theme
      programs.btop.settings.color_theme = "everforest-dark-medium";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.bg_visual ];
          selectedRangeBgColor = [ colors.bg_visual ];
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