{ config, pkgs, lib, ... }:

{
  # Tokyo Night theme configuration
  config = {
    # Color palette
    environment.variables = {
      OMARCHY_THEME = "tokyo-night";
      OMARCHY_THEME_BG = "#1a1b26";
      OMARCHY_THEME_FG = "#c0caf5";
      OMARCHY_THEME_ACCENT = "#7aa2f7";
    };

    # Home-manager theme configuration
    home-manager.users.${config.omarchy.user or "user"} = {
      # Alacritty theme
      programs.alacritty.settings.colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };

        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };

        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };

        indexed_colors = [
          { index = 16; color = "#ff9e64"; }
          { index = 17; color = "#db4b4b"; }
        ];
      };

      # Kitty theme
      programs.kitty = {
        theme = "Tokyo Night";
        settings = {
          background = "#1a1b26";
          foreground = "#c0caf5";

          selection_background = "#33467c";
          selection_foreground = "#c0caf5";

          cursor = "#c0caf5";
          cursor_text_color = "#1a1b26";

          # Black
          color0 = "#15161e";
          color8 = "#414868";

          # Red
          color1 = "#f7768e";
          color9 = "#f7768e";

          # Green
          color2 = "#9ece6a";
          color10 = "#9ece6a";

          # Yellow
          color3 = "#e0af68";
          color11 = "#e0af68";

          # Blue
          color4 = "#7aa2f7";
          color12 = "#7aa2f7";

          # Magenta
          color5 = "#bb9af7";
          color13 = "#bb9af7";

          # Cyan
          color6 = "#7dcfff";
          color14 = "#7dcfff";

          # White
          color7 = "#a9b1d6";
          color15 = "#c0caf5";
        };
      };

      # VS Code theme
      programs.vscode.userSettings = {
        "workbench.colorTheme" = "Tokyo Night";
        "editor.tokenColorCustomizations" = {
          "[Tokyo Night]" = {
            "textMateRules" = [];
          };
        };
        "workbench.colorCustomizations" = {
          "[Tokyo Night]" = {
            "editor.background" = "#1a1b26";
            "editor.foreground" = "#c0caf5";
            "sideBar.background" = "#16161e";
            "sideBar.foreground" = "#a9b1d6";
            "activityBar.background" = "#16161e";
            "activityBar.foreground" = "#c0caf5";
          };
        };
      };

      # GTK theme
      gtk = {
        theme = {
          name = "Tokyo-Night";
          package = pkgs.tokyo-night-gtk or (pkgs.adw-gtk3.overrideAttrs (oldAttrs: {
            pname = "tokyo-night-gtk";
            postInstall = (oldAttrs.postInstall or "") + ''
              # Customize colors for Tokyo Night
              sed -i 's/#1e1e2e/#1a1b26/g' $out/share/themes/*/gtk-3.0/gtk.css
              sed -i 's/#cdd6f4/#c0caf5/g' $out/share/themes/*/gtk-3.0/gtk.css
            '';
          }));
        };
      };

      # Rofi/Wofi theme
      programs.rofi = {
        theme = let
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            background = mkLiteral "#1a1b26";
            foreground = mkLiteral "#c0caf5";
            selected = mkLiteral "#33467c";
            active = mkLiteral "#7aa2f7";
            urgent = mkLiteral "#f7768e";
          };
        };
      };

      # Starship theme adjustments
      programs.starship.settings = {
        palette = "tokyo-night";

        palettes.tokyo-night = {
          bg = "#1a1b26";
          fg = "#c0caf5";
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };

        character = {
          success_symbol = "[➜](green)";
          error_symbol = "[➜](red)";
        };

        directory = {
          style = "blue";
          truncation_length = 3;
        };

        git_branch = {
          style = "magenta";
          symbol = " ";
        };

        git_status = {
          style = "red";
        };
      };

      # Neovim theme
      programs.neovim.plugins = with pkgs.vimPlugins; [
        {
          plugin = tokyonight-nvim;
          type = "lua";
          config = ''
            vim.cmd[[colorscheme tokyonight-night]]
          '';
        }
      ];

      # Bat theme
      programs.bat.config.theme = "TwoDark"; # Close to Tokyo Night

      # btop theme
      programs.btop.settings.color_theme = "tokyo-night";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          activeBorderColor = [ "#7aa2f7" "bold" ];
          inactiveBorderColor = [ "#414868" ];
          selectedLineBgColor = [ "#33467c" ];
          selectedRangeBgColor = [ "#33467c" ];
          cherryPickedCommitBgColor = [ "#33467c" ];
          cherryPickedCommitFgColor = [ "#7aa2f7" ];
          unstagedChangesColor = [ "#f7768e" ];
          defaultFgColor = [ "#c0caf5" ];
        };
      };

      # Firefox theme
      programs.firefox.profiles.default = {
        userChrome = ''
          /* Tokyo Night theme for Firefox */
          :root {
            --toolbar-bgcolor: #1a1b26 !important;
            --toolbar-color: #c0caf5 !important;
            --toolbarbutton-hover-background: #33467c !important;
            --toolbarbutton-active-background: #414868 !important;
            --urlbar-focused-bg-color: #1a1b26 !important;
            --urlbar-focused-color: #c0caf5 !important;
            --tab-selected-bgcolor: #33467c !important;
            --tab-selected-color: #c0caf5 !important;
          }
        '';
      };

      # Mako notification theme
      services.mako = {
        backgroundColor = "#1a1b26";
        textColor = "#c0caf5";
        borderColor = "#7aa2f7";
        progressColor = "#7aa2f7";
        defaultTimeout = 5000;
        borderRadius = 10;
        borderSize = 2;
        font = "JetBrainsMono Nerd Font 10";
        padding = "10";
        margin = "20";
      };
    };

    # Wallpaper
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "set-wallpaper" ''
        #!/usr/bin/env bash
        # Set Tokyo Night themed wallpaper
        swww img ${./wallpapers/tokyo-night.jpg} --transition-type wipe --transition-angle 30 --transition-step 90
      '')
    ];
  };
}