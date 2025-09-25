{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };

  # Function to generate colors from wallpaper using imagemagick
  generateColorsFromWallpaper = wallpaperPath: pkgs.writeShellScriptBin "generate-colors" ''
    #!/usr/bin/env bash

    # Extract dominant colors from wallpaper using imagemagick
    colors=$(${pkgs.imagemagick}/bin/convert "${wallpaperPath}" -resize 1x1 -format "%[pixel:u]" info:)

    # Generate a simple color scheme based on the dominant color
    # This is a simplified approach - ideally would use a more sophisticated algorithm
    echo "# Generated color scheme from wallpaper: ${wallpaperPath}"
    echo "# Dominant color: $colors"

    # For now, we'll use predefined schemes that match common wallpaper types
    # In a real implementation, this would analyze the image and generate appropriate colors
  '';

  # Default color schemes for common wallpaper types
  fallbackColorSchemes = {
    dark = inputs.nix-colors.colorSchemes.tokyo-night-dark or null;
    light = inputs.nix-colors.colorSchemes.tokyo-night-light or null;
    blue = inputs.nix-colors.colorSchemes.nord or null;
    purple = inputs.nix-colors.colorSchemes.catppuccin-mocha or null;
    green = inputs.nix-colors.colorSchemes.gruvbox-dark-medium or null;
  };

  # Select color scheme based on wallpaper or user preference
  selectedColorScheme =
    if cfg.colorScheme != null then
      cfg.colorScheme
    else if cfg.wallpaper != null && cfg.features.autoColors then
      # TODO: Implement actual color analysis
      # For now, use a sensible default based on theme
      fallbackColorSchemes.${cfg.theme} or fallbackColorSchemes.dark
    else
      # Use theme-based color scheme
      fallbackColorSchemes.${cfg.theme} or fallbackColorSchemes.dark;

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # User-specific configuration using shared helpers
    (omnixy.forUser (mkIf (selectedColorScheme != null) {
      colorScheme = selectedColorScheme;

      # Add packages for color management
      home.packages = omnixy.filterPackages (with pkgs; [
        imagemagick  # For color extraction from images
      ] ++ optionals (omnixy.isEnabled "customThemes" || omnixy.isEnabled "wallpaperEffects") [
        # Additional packages for advanced color analysis
        python3Packages.pillow  # For more sophisticated image analysis
        python3Packages.colorthief  # For extracting color palettes
      ] ++ optionals (cfg.wallpaper != null) [
        # Generate wallpaper setter script that respects colors
        (omnixy.makeScript "set-omnixy-wallpaper" "Set wallpaper with automatic color generation" ''
          WALLPAPER_PATH="${cfg.wallpaper}"

          echo "Setting wallpaper: $WALLPAPER_PATH"

          # Set wallpaper with swww
          if command -v swww &> /dev/null; then
            swww img "$WALLPAPER_PATH" --transition-type wipe --transition-angle 30 --transition-step 90
          else
            echo "swww not found, please install swww for wallpaper support"
          fi

          # Optionally generate new colors from wallpaper
          ${optionalString (omnixy.isEnabled "wallpaperEffects") ''
            echo "Generating colors from wallpaper..."
            # This would trigger a system rebuild with new colors
            # For now, just notify the user
            echo "Note: Automatic color generation requires system rebuild"
            echo "Consider adding this wallpaper to your configuration and rebuilding"
          ''}
        '')
      ]);
    }))

    # System-level configuration
    {

    # System-level packages for color management
    environment.systemPackages = with pkgs; [
      # Color utilities
      imagemagick

      # Wallpaper utilities
      swww  # Wayland wallpaper daemon

      # Script to help users set up automatic colors
      (writeShellScriptBin "omnixy-setup-colors" ''
        #!/usr/bin/env bash

        echo "OmniXY Color Setup"
        echo "=================="
        echo ""
        echo "Current configuration:"
        echo "  Theme: ${cfg.theme}"
        echo "  Preset: ${if cfg.preset != null then cfg.preset else "none"}"
        echo "  Custom Themes: ${if cfg.features.customThemes or false then "enabled" else "disabled"}"
        echo "  Wallpaper Effects: ${if cfg.features.wallpaperEffects or false then "enabled" else "disabled"}"
        echo "  Wallpaper: ${if cfg.wallpaper != null then toString cfg.wallpaper else "not set"}"
        echo "  Color Scheme: ${if cfg.colorScheme != null then "custom" else "theme-based"}"
        echo ""

        ${optionalString (!(cfg.features.wallpaperEffects or false)) ''
          echo "To enable automatic color generation:"
          echo "  1. Set omnixy.features.wallpaperEffects = true; in your configuration"
          echo "  2. Set omnixy.wallpaper = /path/to/your/wallpaper.jpg;"
          echo "  3. Rebuild your system with: omnixy-rebuild"
          echo ""
        ''}

        ${optionalString ((cfg.features.wallpaperEffects or false) && cfg.wallpaper == null) ''
          echo "Wallpaper effects are enabled but no wallpaper is set."
          echo "Set omnixy.wallpaper = /path/to/your/wallpaper.jpg; in your configuration."
          echo ""
        ''}

        echo "Available nix-colors schemes:"
        echo "  - tokyo-night-dark, tokyo-night-light"
        echo "  - catppuccin-mocha, catppuccin-latte"
        echo "  - gruvbox-dark-medium, gruvbox-light-medium"
        echo "  - nord"
        echo "  - everforest-dark-medium"
        echo "  - rose-pine, rose-pine-dawn"
        echo ""
        echo "To use a specific scheme:"
        echo '  omnixy.colorScheme = inputs.nix-colors.colorSchemes.SCHEME_NAME;'
      '')
    ];

      # Export color information for other modules to use
      environment.variables = mkIf (selectedColorScheme != null) {
        OMNIXY_COLOR_SCHEME = selectedColorScheme.slug or "unknown";
      };
    }
  ]);
}