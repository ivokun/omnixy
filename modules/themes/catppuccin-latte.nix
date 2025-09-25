{ config, pkgs, lib, ... }:

# Catppuccin Latte theme for OmniXY
# A soothing light theme with excellent contrast

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Catppuccin Latte color palette
  colors = {
    # Base colors (light theme)
    base = "#eff1f5";        # Light background
    mantle = "#e6e9ef";      # Slightly darker background
    crust = "#dce0e8";       # Crust background

    # Text colors
    text = "#4c4f69";        # Main text
    subtext1 = "#5c5f77";    # Subtext 1
    subtext0 = "#6c6f85";    # Subtext 0

    # Surface colors
    surface0 = "#ccd0da";    # Surface 0
    surface1 = "#bcc0cc";    # Surface 1
    surface2 = "#acb0be";    # Surface 2

    # Overlay colors
    overlay0 = "#9ca0b0";    # Overlay 0
    overlay1 = "#8c8fa1";    # Overlay 1
    overlay2 = "#7c7f93";    # Overlay 2

    # Accent colors
    rosewater = "#dc8a78";   # Rosewater
    flamingo = "#dd7878";    # Flamingo
    pink = "#ea76cb";        # Pink
    mauve = "#8839ef";       # Mauve
    red = "#d20f39";         # Red
    maroon = "#e64553";      # Maroon
    peach = "#fe640b";       # Peach
    yellow = "#df8e1d";      # Yellow
    green = "#40a02b";       # Green
    teal = "#179299";        # Teal
    sky = "#04a5e5";         # Sky
    sapphire = "#209fb5";    # Sapphire
    blue = "#1e66f5";        # Blue
    lavender = "#7287fd";    # Lavender
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/catppuccin-latte/1-catppuccin-latte.png;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(1e66f5)
            col.inactive_border = rgba(9ca0b0aa)
        }
        decoration {
            col.shadow = rgba(4c4f69ee)
        }
      '';

      # GTK theme (light theme)
      programs.dconf.enable = true;

      # Environment variables for consistent theming
      environment.variables = {
        GTK_THEME = "Adwaita";
        QT_STYLE_OVERRIDE = "adwaita";
        OMNIXY_THEME_COLORS_BG = colors.base;
        OMNIXY_THEME_COLORS_FG = colors.text;
        OMNIXY_THEME_COLORS_ACCENT = colors.blue;
      };

      # Console colors (adapted for light theme)
      console = {
        colors = [
          colors.surface2      # black
          colors.red          # red
          colors.green        # green
          colors.yellow       # yellow
          colors.blue         # blue
          colors.mauve        # magenta
          colors.teal         # cyan
          colors.text         # white
          colors.overlay1     # bright black
          colors.red          # bright red
          colors.green        # bright green
          colors.yellow       # bright yellow
          colors.blue         # bright blue
          colors.mauve        # bright magenta
          colors.teal         # bright cyan
          colors.text         # bright white
        ];
      };
    }

    # User-specific theme configuration
    (omnixy.forUser {
      # GTK configuration (light theme)
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 0;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 0;
        };
      };

      # Qt theming (light theme)
      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita";
      };

      # Kitty terminal theme
      programs.kitty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        themeFile = "Catppuccin-Latte";
        settings = {
          background = colors.base;
          foreground = colors.text;
          selection_background = colors.surface1;
          selection_foreground = colors.text;

          # Cursor colors
          cursor = colors.text;
          cursor_text_color = colors.base;

          # URL underline color when hovering
          url_color = colors.blue;

          # Tab colors
          active_tab_background = colors.blue;
          active_tab_foreground = colors.base;
          inactive_tab_background = colors.surface0;
          inactive_tab_foreground = colors.subtext1;

          # Window border colors
          active_border_color = colors.blue;
          inactive_border_color = colors.overlay0;
        };
      };

      # Alacritty terminal theme
      programs.alacritty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        settings = {
          colors = {
            primary = {
              background = colors.base;
              foreground = colors.text;
            };
            cursor = {
              text = colors.base;
              cursor = colors.text;
            };
            normal = {
              black = colors.surface1;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.mauve;
              cyan = colors.teal;
              white = colors.text;
            };
            bright = {
              black = colors.overlay1;
              red = colors.red;
              green = colors.green;
              yellow = colors.yellow;
              blue = colors.blue;
              magenta = colors.mauve;
              cyan = colors.teal;
              white = colors.text;
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
            background: ${colors.base};
            color: ${colors.text};
            border-bottom: 2px solid ${colors.blue};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.subtext1};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.blue};
            border-bottom-color: ${colors.blue};
          }

          #workspaces button:hover {
            color: ${colors.text};
            background: ${colors.surface0};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.surface0};
            color: ${colors.text};
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
            background-color = mkLiteral colors.base;
            foreground-color = mkLiteral colors.text;
            border-color = mkLiteral colors.blue;
            separatorcolor = mkLiteral colors.surface0;
            scrollbar-handle = mkLiteral colors.blue;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.blue;
            text-color = mkLiteral colors.base;
          };
        };
      };

      # Mako notification theme
      services.mako = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        settings = {
          font = "JetBrainsMono Nerd Font 10";
          background-color = colors.base;
          text-color = colors.text;
          border-color = colors.blue;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.blue;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Catppuccin Latte";
          "workbench.preferredLightColorTheme" = "Catppuccin Latte";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=light
          colorscheme catppuccin-latte
        '';
        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Catppuccin-latte";

      # btop theme - using latte theme
      programs.btop.settings.color_theme = "catppuccin-latte";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = true;
          selectedLineBgColor = [ colors.surface0 ];
          selectedRangeBgColor = [ colors.surface0 ];
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
            style = "bold ${colors.mauve}";
          };
          git_status = {
            style = "bold ${colors.yellow}";
          };
        };
      };
    })
  ]);
}