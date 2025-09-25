# Themes Directory - OmniXY Theme System

The `modules/themes/` directory contains complete theme definitions that provide unified styling across all applications and desktop components in OmniXY. Each theme is a self-contained Nix module that configures colors, fonts, and appearance settings system-wide.

## Theme Architecture

Each theme module follows this structure:
```nix
{ config, lib, pkgs, ... }:
let
  # Color palette definitions
  colors = {
    primary = "#7aa2f7";
    background = "#1a1b26";
    # ... more colors
  };
in {
  # Theme configuration for all applications
  config = lib.mkIf (config.omnixy.theme == "theme-name") {
    # Application configurations
  };
}
```

## Available Themes

OmniXY includes 11 carefully crafted themes:

### Dark Themes

#### `tokyo-night.nix` (Default)
**Inspiration**: Tokyo's neon-lit nights
**Palette**: Deep blues and vibrant accents
**Character**: Modern, clean, high contrast
**Best for**: Programming, late-night work

**Key Colors**:
- Background: `#1a1b26` (Dark navy)
- Primary: `#7aa2f7` (Bright blue)
- Accent: `#bb9af7` (Purple)
- Success: `#9ece6a` (Green)
- Warning: `#e0af68` (Orange)

#### `catppuccin.nix`
**Inspiration**: Warm, cozy coffee shop
**Palette**: Soft pastels with warm undertones
**Character**: Soothing, gentle on eyes
**Best for**: Long coding sessions, reading

**Key Colors**:
- Background: `#1e1e2e` (Warm dark)
- Primary: `#cba6f7` (Soft purple)
- Accent: `#f38ba8` (Rose)
- Success: `#a6e3a1` (Mint green)

#### `gruvbox.nix`
**Inspiration**: Retro terminal aesthetics
**Palette**: Warm earth tones
**Character**: Vintage, comfortable, nostalgic
**Best for**: Terminal work, distraction-free coding

#### `nord.nix`
**Inspiration**: Arctic, Scandinavian minimalism
**Palette**: Cool blues and grays
**Character**: Clean, minimal, professional
**Best for**: Focus work, professional environments

#### `everforest.nix`
**Inspiration**: Deep forest, natural greens
**Palette**: Forest greens with earth accents
**Character**: Calm, natural, easy on eyes
**Best for**: Long work sessions, nature lovers

#### `rose-pine.nix`
**Inspiration**: English countryside
**Palette**: Muted roses and soft pinks
**Character**: Elegant, sophisticated, gentle
**Best for**: Creative work, design

#### `kanagawa.nix`
**Inspiration**: Japanese woodblock prints
**Palette**: Traditional Japanese colors
**Character**: Artistic, cultural, balanced
**Best for**: Creative coding, artistic work

#### `matte-black.nix`
**Inspiration**: Minimalist design
**Palette**: True blacks and whites
**Character**: Stark, minimal, high contrast
**Best for**: Focus, minimal distractions

#### `osaka-jade.nix`
**Inspiration**: Japanese jade and bamboo
**Palette**: Jade greens with natural accents
**Character**: Serene, balanced, harmonious
**Best for**: Meditation coding, calm work

#### `ristretto.nix`
**Inspiration**: Dark roasted coffee
**Palette**: Rich browns and warm tones
**Character**: Warm, cozy, comfortable
**Best for**: Coffee shop coding, warm environments

### Light Theme

#### `catppuccin-latte.nix`
**Inspiration**: Light coffee, morning work
**Palette**: Soft pastels on light background
**Character**: Bright, energetic, clean
**Best for**: Daytime work, bright environments

## Theme Components

Each theme configures these application categories:

### Terminal Applications
- **Alacritty**: Terminal colors and transparency
- **Kitty**: Color scheme and font rendering
- **Shell**: Prompt colors and syntax highlighting

### Text Editors
- **Neovim**: Syntax highlighting and UI colors
- **VSCode**: Editor theme and syntax colors
- **Terminal editors**: Vim, nano color schemes

### Desktop Environment
- **Hyprland**: Window borders, gaps, animations
- **Waybar**: Panel colors, module styling
- **Rofi/Launchers**: Menu and selection colors

### System UI
- **GTK**: System-wide GTK application theming
- **Qt**: Qt application color schemes
- **Icon themes**: Matching icon sets

### Notification System
- **Mako**: Notification colors and styling
- **System notifications**: Alert and info colors

### Development Tools
- **Git tools**: Diff colors, status indicators
- **Lazygit**: TUI color scheme
- **Development containers**: Terminal themes

## Theme Implementation

### Color Management
Each theme defines a comprehensive color palette:

```nix
colors = {
  # Base colors
  bg = "#1a1b26";           # Background
  fg = "#c0caf5";           # Foreground text

  # Accent colors
  blue = "#7aa2f7";         # Primary blue
  cyan = "#7dcfff";         # Cyan accents
  green = "#9ece6a";        # Success/positive
  yellow = "#e0af68";       # Warnings
  red = "#f7768e";          # Errors/critical
  purple = "#bb9af7";       # Special/accent

  # UI colors
  border = "#414868";       # Window borders
  selection = "#364a82";    # Text selection
  comment = "#565f89";      # Comments/inactive
};
```

### Application Configuration
Colors are applied consistently across applications:

```nix
# Alacritty terminal configuration
programs.alacritty.settings = {
  colors = {
    primary = {
      background = colors.bg;
      foreground = colors.fg;
    };
    normal = {
      black = colors.bg;
      blue = colors.blue;
      # ... more colors
    };
  };
};
```

### Dynamic Application
Themes are applied conditionally:

```nix
config = lib.mkIf (config.omnixy.theme == "tokyo-night") {
  # All theme configurations here
};
```

## Theme Switching

### Command Line
```bash
# List available themes
omnixy theme list

# Switch theme
omnixy theme set gruvbox

# Get current theme
omnixy theme get
```

### System Integration
Theme switching:
1. Updates `configuration.nix` with new theme
2. Rebuilds system configuration
3. All applications automatically use new colors
4. No manual restart required for most applications

### Scriptable Interface
```bash
# Automated theme switching
current=$(omnixy --quiet theme get)
omnixy theme list --quiet | grep -v "$current" | head -1 | xargs omnixy theme set

# JSON output for automation
omnixy --json theme list | jq -r '.available[]'
```

## Creating Custom Themes

### 1. Copy Existing Theme
```bash
cp modules/themes/tokyo-night.nix modules/themes/my-theme.nix
```

### 2. Define Color Palette
```nix
let
  colors = {
    bg = "#your-bg-color";
    fg = "#your-fg-color";
    # Define your complete palette
  };
```

### 3. Update Theme Condition
```nix
config = lib.mkIf (config.omnixy.theme == "my-theme") {
  # Theme configurations
};
```

### 4. Add to Available Themes
Update theme management scripts to include your new theme.

### 5. Test and Iterate
```bash
# Test your theme
omnixy theme set my-theme

# Make adjustments and rebuild
omnixy-rebuild
```

## Theme Guidelines

### Color Accessibility
- Ensure adequate contrast ratios (4.5:1 for normal text)
- Test with color blindness simulators
- Provide clear visual hierarchy

### Consistency
- Use semantic color naming (primary, secondary, accent)
- Maintain consistent color relationships
- Apply colors systematically across applications

### Performance
- Avoid complex color calculations
- Use static color definitions
- Test theme switching performance

### Documentation
- Document color meanings and usage
- Provide theme inspiration and character
- Include screenshots or examples

## Theme Validation

### Color Contrast Testing
```bash
# Test theme accessibility
omnixy theme set my-theme
# Use accessibility tools to check contrast ratios
```

### Visual Testing
- Test all major applications
- Verify readability in different lighting
- Check consistency across different screen types

### Integration Testing
- Ensure theme switching works properly
- Verify all applications receive theme updates
- Test with different desktop configurations

This comprehensive theme system ensures a cohesive, beautiful, and customizable visual experience across the entire OmniXY desktop environment.