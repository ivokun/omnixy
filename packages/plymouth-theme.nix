{ lib, pkgs, stdenv, writeTextFile, ... }:

# OmniXY Plymouth Theme Package
# Creates theme-aware Plymouth boot screens

let
  # Theme color definitions
  themeColors = {
    tokyo-night = {
      bg = "#1a1b26";
      fg = "#c0caf5";
      accent = "#7aa2f7";
      secondary = "#bb9af7";
    };
    catppuccin = {
      bg = "#1e1e2e";
      fg = "#cdd6f4";
      accent = "#89b4fa";
      secondary = "#cba6f7";
    };
    gruvbox = {
      bg = "#282828";
      fg = "#ebdbb2";
      accent = "#d79921";
      secondary = "#b16286";
    };
    nord = {
      bg = "#2e3440";
      fg = "#eceff4";
      accent = "#5e81ac";
      secondary = "#b48ead";
    };
    everforest = {
      bg = "#2d353b";
      fg = "#d3c6aa";
      accent = "#a7c080";
      secondary = "#e67e80";
    };
    rose-pine = {
      bg = "#191724";
      fg = "#e0def4";
      accent = "#31748f";
      secondary = "#c4a7e7";
    };
    kanagawa = {
      bg = "#1f1f28";
      fg = "#dcd7ba";
      accent = "#7e9cd8";
      secondary = "#957fb8";
    };
    catppuccin-latte = {
      bg = "#eff1f5";
      fg = "#4c4f69";
      accent = "#1e66f5";
      secondary = "#8839ef";
    };
    matte-black = {
      bg = "#000000";
      fg = "#ffffff";
      accent = "#666666";
      secondary = "#999999";
    };
    osaka-jade = {
      bg = "#0d1b1e";
      fg = "#c5d4d7";
      accent = "#5fb3a1";
      secondary = "#7ba05b";
    };
    ristretto = {
      bg = "#2c1810";
      fg = "#d4c5a7";
      accent = "#d08b5b";
      secondary = "#a67458";
    };
  };

  # Base assets (copied from omarchy)
  assets = pkgs.runCommand "omnixy-plymouth-assets" {} ''
    mkdir -p $out

    # Create base logo (OmniXY branding)
    cat > $out/logo.svg <<'EOF'
<svg width="120" height="120" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#7aa2f7;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#bb9af7;stop-opacity:1" />
    </linearGradient>
  </defs>
  <circle cx="60" cy="60" r="50" fill="url(#grad1)" opacity="0.8"/>
  <text x="60" y="70" font-family="JetBrains Mono" font-size="24" font-weight="bold"
        text-anchor="middle" fill="white">XY</text>
</svg>
EOF

    # Convert SVG to PNG
    ${pkgs.librsvg}/bin/rsvg-convert -w 120 -h 120 $out/logo.svg -o $out/logo.png
    rm $out/logo.svg

    # Create other UI elements (simplified versions of omarchy assets)
    ${pkgs.imagemagick}/bin/convert -size 32x32 xc:none -fill '#ffffff' -draw 'circle 16,16 16,8' $out/lock.png
    ${pkgs.imagemagick}/bin/convert -size 200x32 xc:'rgba(255,255,255,0.1)' -stroke white -strokewidth 1 -fill none -draw 'roundrectangle 1,1 198,30 8,8' $out/entry.png
    ${pkgs.imagemagick}/bin/convert -size 8x8 xc:white $out/bullet.png
    ${pkgs.imagemagick}/bin/convert -size 300x8 xc:'rgba(255,255,255,0.2)' -stroke white -strokewidth 1 -fill none -draw 'roundrectangle 1,1 298,6 4,4' $out/progress_box.png
    ${pkgs.imagemagick}/bin/convert -size 296x4 xc:'rgba(255,255,255,0.8)' $out/progress_bar.png
  '';

  # Plymouth script template
  createPlymouthScript = themeName: colors: writeTextFile {
    name = "omnixy-${themeName}.script";
    text = ''
      # OmniXY Plymouth Theme Script
      # Theme: ${themeName}
      # Generated for NixOS/OmniXY

      // Theme color configuration
      bg_color = Colour("${colors.bg}");
      fg_color = Colour("${colors.fg}");
      accent_color = Colour("${colors.accent}");
      secondary_color = Colour("${colors.secondary}");

      // Screen setup
      screen_width = Window.GetWidth();
      screen_height = Window.GetHeight();
      Window.SetBackgroundTopColor(bg_color);
      Window.SetBackgroundBottomColor(bg_color);

      // Load assets
      logo_image = Image("logo.png");
      lock_image = Image("lock.png");
      entry_image = Image("entry.png");
      bullet_image = Image("bullet.png");
      progress_box_image = Image("progress_box.png");
      progress_bar_image = Image("progress_bar.png");

      // Logo setup
      logo_sprite = Sprite(logo_image);
      logo_sprite.SetX((screen_width - logo_image.GetWidth()) / 2);
      logo_sprite.SetY(screen_height / 2 - 100);
      logo_sprite.SetOpacity(0.9);

      // Progress bar setup
      progress_box_sprite = Sprite(progress_box_image);
      progress_box_sprite.SetX((screen_width - progress_box_image.GetWidth()) / 2);
      progress_box_sprite.SetY(screen_height / 2 + 50);

      progress_bar_sprite = Sprite(progress_bar_image);
      progress_bar_sprite.SetX((screen_width - progress_box_image.GetWidth()) / 2 + 2);
      progress_bar_sprite.SetY(screen_height / 2 + 52);

      // Animation variables
      fake_progress = 0;
      real_progress = 0;
      start_time = Plymouth.GetTime();
      fake_duration = 15; // 15 seconds fake progress

      // Easing function (ease-out quadratic)
      fun easeOutQuad(x) {
          return 1 - (1 - x) * (1 - x);
      }

      // Progress update function
      fun progress_callback() {
          current_time = Plymouth.GetTime();
          elapsed = current_time - start_time;

          // Calculate fake progress (0 to 0.7 over fake_duration)
          if (elapsed < fake_duration) {
              fake_progress = 0.7 * easeOutQuad(elapsed / fake_duration);
          } else {
              fake_progress = 0.7;
          }

          // Use the maximum of fake and real progress
          display_progress = fake_progress;
          if (real_progress > fake_progress) {
              display_progress = real_progress;
          }

          // Update progress bar
          bar_width = progress_bar_image.GetWidth() * display_progress;
          progress_bar_sprite.SetImage(progress_bar_image.Scale(bar_width, progress_bar_image.GetHeight()));

          // Add subtle pulsing to logo during boot
          pulse = Math.Sin(elapsed * 3) * 0.1 + 0.9;
          logo_sprite.SetOpacity(pulse);
      }

      Plymouth.SetUpdateFunction(progress_callback);

      // Boot progress callback
      Plymouth.SetBootProgressFunction(
          fun (duration, progress) {
              real_progress = progress;
          }
      );

      // Password dialog setup
      question_sprite = Sprite();
      answer_sprite = Sprite();

      fun DisplayQuestionCallback(prompt, entry) {
          question_sprite.SetImage(Image.Text(prompt, 1, 1, 1));
          question_sprite.SetX((screen_width - question_sprite.GetImage().GetWidth()) / 2);
          question_sprite.SetY(screen_height / 2 - 50);

          // Show lock icon
          lock_sprite = Sprite(lock_image);
          lock_sprite.SetX((screen_width - lock_image.GetWidth()) / 2);
          lock_sprite.SetY(screen_height / 2 - 20);

          // Show entry field
          entry_sprite = Sprite(entry_image);
          entry_sprite.SetX((screen_width - entry_image.GetWidth()) / 2);
          entry_sprite.SetY(screen_height / 2 + 20);

          // Show bullets for password
          bullet_sprites = [];
          for (i = 0; i < entry.GetLength(); i++) {
              bullet_sprites[i] = Sprite(bullet_image);
              bullet_sprites[i].SetX((screen_width / 2) - (entry.GetLength() * 10 / 2) + i * 10);
              bullet_sprites[i].SetY(screen_height / 2 + 28);
          }
      }

      Plymouth.SetDisplayQuestionFunction(DisplayQuestionCallback);

      // Hide question callback
      Plymouth.SetDisplayPasswordFunction(DisplayQuestionCallback);

      // Message display
      message_sprite = Sprite();

      Plymouth.SetMessageFunction(
          fun (text) {
              message_sprite.SetImage(Image.Text(text, 1, 1, 1));
              message_sprite.SetX((screen_width - message_sprite.GetImage().GetWidth()) / 2);
              message_sprite.SetY(screen_height - 50);
          }
      );

      // Quit callback
      Plymouth.SetQuitFunction(
          fun () {
              // Fade out animation
              for (i = 0; i < 30; i++) {
                  opacity = 1 - (i / 30);
                  logo_sprite.SetOpacity(opacity);
                  Plymouth.Sleep(16); // ~60fps
              }
          }
      );
    '';
  };

  # Create theme definition file
  createPlymouthTheme = themeName: colors: writeTextFile {
    name = "omnixy-${themeName}.plymouth";
    text = ''
      [Plymouth Theme]
      Name=OmniXY ${themeName}
      Description=OmniXY boot splash theme for ${themeName}
      ModuleName=script

      [script]
      ImageDir=/run/current-system/sw/share/plymouth/themes/omnixy-${themeName}
      ScriptFile=/run/current-system/sw/share/plymouth/themes/omnixy-${themeName}/omnixy-${themeName}.script
    '';
  };

in

# Create derivation for all Plymouth themes
stdenv.mkDerivation rec {
  pname = "omnixy-plymouth-themes";
  version = "1.0";

  src = assets;

  buildInputs = with pkgs; [ coreutils ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (themeName: colors: ''
      # Create theme directory
      theme_dir="$out/share/plymouth/themes/omnixy-${themeName}"
      mkdir -p "$theme_dir"

      # Copy assets
      cp ${src}/* "$theme_dir/"

      # Install theme files
      cp ${createPlymouthScript themeName colors} "$theme_dir/omnixy-${themeName}.script"
      cp ${createPlymouthTheme themeName colors} "$theme_dir/omnixy-${themeName}.plymouth"

      # Make script executable
      chmod +x "$theme_dir/omnixy-${themeName}.script"
    '') themeColors)}

    # Create a default symlink to tokyo-night
    ln -sf omnixy-tokyo-night $out/share/plymouth/themes/omnixy-default
  '';

  meta = with lib; {
    description = "OmniXY Plymouth boot splash themes";
    homepage = "https://github.com/TheArctesian/omnixy";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
  };
}