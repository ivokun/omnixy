{ config, pkgs, lib, ... }:

# Gruvbox theme for OmniXY
# A retro groove color scheme with warm, earthy tones

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Gruvbox color palette
  colors = {
    bg = "#282828";        # Dark background
    bg_hard = "#1d2021";   # Harder background
    bg_soft = "#32302f";   # Soft background
    fg = "#ebdbb2";        # Light foreground
    fg_dim = "#a89984";    # Dimmed foreground

    red = "#cc241d";       # Dark red
    green = "#98971a";     # Dark green
    yellow = "#d79921";    # Dark yellow
    blue = "#458588";      # Dark blue
    purple = "#b16286";    # Dark purple
    aqua = "#689d6a";      # Dark aqua
    orange = "#d65d0e";    # Dark orange
    gray = "#928374";      # Gray

    red_light = "#fb4934";    # Light red
    green_light = "#b8bb26";  # Light green
    yellow_light = "#fabd2f"; # Light yellow
    blue_light = "#83a598";   # Light blue
    purple_light = "#d3869b"; # Light purple
    aqua_light = "#8ec07c";   # Light aqua
    orange_light = "#fe8019"; # Light orange
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/gruvbox/1-grubox.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(a89984)
            col.inactive_border = rgba(665c54aa)
        }
        decoration {
            col.shadow = rgba(1d2021ee)
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
        OMNIXY_THEME_COLORS_ACCENT = colors.orange_light;
      };

      # Console colors
      console = {
        colors = [
          colors.bg       # black
          colors.red      # red
          colors.green    # green
          colors.yellow   # yellow
          colors.blue     # blue
          colors.purple   # magenta
          colors.aqua     # cyan
          colors.fg       # white
          colors.gray     # bright black
          colors.red_light    # bright red
          colors.green_light  # bright green
          colors.yellow_light # bright yellow
          colors.blue_light   # bright blue
          colors.purple_light # bright magenta
          colors.aqua_light   # bright cyan
          colors.fg       # bright white
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
        themeFile = "gruvbox-dark";
        settings = {
          background = colors.bg;
          foreground = colors.fg;
          selection_background = colors.bg_soft;
          selection_foreground = colors.fg;

          # Cursor colors
          cursor = colors.fg;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.blue_light;

          # Tab colors
          active_tab_background = colors.orange_light;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_soft;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.orange_light;
          inactive_border_color = colors.gray;
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
              black = colors.bg;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.purple;
              cyan = colors.aqua;
              white = colors.fg;
            };
            bright = {
              black = colors.gray;
              red = colors.red_light;
              green = colors.green_light;
              yellow = colors.yellow_light;
              blue = colors.blue_light;
              magenta = colors.purple_light;
              cyan = colors.aqua_light;
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
            border-bottom: 2px solid ${colors.orange_light};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.orange_light};
            border-bottom-color: ${colors.orange_light};
          }

          #workspaces button:hover {
            color: ${colors.fg};
            background: ${colors.bg_soft};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.bg_soft};
            color: ${colors.fg};
          }

          #battery.critical {
            color: ${colors.red_light};
          }

          #battery.warning {
            color: ${colors.yellow_light};
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
            border-color = mkLiteral colors.orange_light;
            separatorcolor = mkLiteral colors.bg_soft;
            scrollbar-handle = mkLiteral colors.orange_light;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.orange_light;
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
          border-color = colors.orange_light;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.orange_light;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          jdinhlife.gruvbox
        ];
        userSettings = {
          "workbench.colorTheme" = "Gruvbox Dark Medium";
          "workbench.preferredDarkColorTheme" = "Gruvbox Dark Medium";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          colorscheme gruvbox
          set background=dark
        '';
        plugins = with pkgs.vimPlugins; [
          gruvbox-nvim
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "gruvbox-dark";

      # btop theme
      programs.btop.settings.color_theme = "gruvbox_dark";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.bg_soft ];
          selectedRangeBgColor = [ colors.bg_soft ];
        };
      };

      # Zsh/shell prompt colors
      programs.starship = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          character = {
            success_symbol = "[➜](bold ${colors.green_light})";
            error_symbol = "[➜](bold ${colors.red_light})";
          };
          directory = {
            style = "bold ${colors.blue_light}";
          };
          git_branch = {
            style = "bold ${colors.purple_light}";
          };
          git_status = {
            style = "bold ${colors.yellow_light}";
          };
        };
      };
    })
  ]);
}