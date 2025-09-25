# Desktop Directory - Desktop Environment Configuration

The `modules/desktop/` directory contains the desktop environment configuration for OmniXY, centered around the Hyprland compositor. This directory manages the complete desktop experience including window management, user interface, and desktop interactions.

## Desktop Architecture

The desktop system is built in layers:
```
User Interaction Layer (keybindings, gestures)
         ↓
Application Layer (autostart, window rules)
         ↓
Compositor Layer (Hyprland core)
         ↓
System Integration Layer (services, hardware)
```

## Core Desktop Module

### `hyprland.nix`
**Purpose**: Main Hyprland compositor configuration and coordination
**What it provides**:
- Core Hyprland configuration
- Integration with other desktop components
- Theme-aware window management
- Performance optimizations

**Key Features**:
- Wayland-native compositor
- Dynamic tiling window management
- Smooth animations and effects
- GPU-accelerated rendering
- Extensive customization options

**Module Structure**:
```nix
imports = [
  ./hyprland/bindings.nix
  ./hyprland/autostart.nix
  ./hyprland/idle.nix
];
```

## Hyprland Sub-Modules

### `hyprland/bindings.nix`
**Purpose**: Keyboard shortcuts and input bindings
**What it configures**:
- Window management shortcuts
- Application launching bindings
- Workspace navigation
- System control shortcuts

**Key Binding Categories**:

#### Window Management
- `Super + Q`: Close window
- `Super + F`: Toggle fullscreen
- `Super + Space`: Toggle floating
- `Super + V`: Toggle split direction
- `Super + Arrow Keys`: Move window focus
- `Super + Shift + Arrow Keys`: Move windows

#### Application Launching
- `Super + Return`: Terminal (Alacritty)
- `Super + B`: Web browser
- `Super + E`: File manager
- `Super + D`: Application launcher
- `Super + R`: Run dialog

#### Workspace Management
- `Super + 1-9`: Switch to workspace
- `Super + Shift + 1-9`: Move window to workspace
- `Super + Mouse Wheel`: Cycle through workspaces
- `Super + Tab`: Application switcher

#### System Controls
- `Super + L`: Lock screen
- `Super + Shift + E`: Logout menu
- `Volume Keys`: Audio control
- `Brightness Keys`: Display brightness
- `Print`: Screenshot region
- `Shift + Print`: Screenshot full screen

#### Advanced Bindings
- `Super + Alt + Arrow Keys`: Resize windows
- `Super + Mouse`: Move/resize windows
- `Super + Shift + S`: Screenshot with selection
- `Super + P`: Power menu

### `hyprland/autostart.nix`
**Purpose**: Applications and services started with the desktop session
**What it manages**:
- Essential desktop services
- User applications
- Background processes
- System tray applications

**Autostart Categories**:

#### Essential Services
- **Waybar**: Desktop panel/taskbar
- **Mako**: Notification daemon
- **Authentication Agent**: Polkit authentication
- **Network Manager Applet**: Network connectivity

#### Background Services
- **Clipboard Manager**: Clipboard history
- **Wallpaper Setter**: Dynamic wallpapers
- **Idle Manager**: Screen timeout and locking
- **Audio Control**: Volume control daemon

#### User Applications (Optional)
- **File Manager**: Background file operations
- **Chat Applications**: Discord, Slack, etc.
- **Productivity Tools**: Note-taking, calendar
- **Development Tools**: IDEs, terminals

**Configuration Example**:
```nix
wayland.windowManager.hyprland.settings = {
  exec-once = [
    "waybar"
    "mako"
    "nm-applet --indicator"
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
  ];
};
```

### `hyprland/idle.nix`
**Purpose**: Idle management and screen locking
**What it configures**:
- Screen timeout settings
- Automatic screen locking
- Display power management
- Suspend/hibernate behavior

**Idle Management Features**:

#### Screen Locking
- Automatic lock after inactivity
- Manual lock with keybinding
- Grace period for quick unlock
- Secure lock screen (swaylock)

#### Display Management
- Screen dimming before lock
- Display turn-off timing
- Multiple monitor handling
- Brightness restoration

#### Power Management
- Suspend after extended idle
- Hibernate for long inactivity
- Wake-on-input configuration
- Battery-aware timeouts

**Configuration Options**:
```nix
services.hypridle = {
  enable = true;
  settings = {
    general = {
      after_sleep_cmd = "hyprctl dispatch dpms on";
      before_sleep_cmd = "loginctl lock-session";
      ignore_dbus_inhibit = false;
      lock_cmd = "pidof hyprlock || hyprlock";
    };

    listener = [
      {
        timeout = 300;  # 5 minutes
        on-timeout = "brightnessctl -s set 10";
        on-resume = "brightnessctl -r";
      }
      {
        timeout = 600;  # 10 minutes
        on-timeout = "loginctl lock-session";
      }
    ];
  };
};
```

## Window Management Features

### Tiling Behavior
- **Dynamic Tiling**: Automatic window arrangement
- **Manual Tiling**: User-controlled window placement
- **Floating Windows**: Support for floating applications
- **Split Layouts**: Horizontal and vertical splits

### Window Rules
- **Application-Specific Rules**: Size, position, workspace assignment
- **Floating Applications**: Always-float for certain apps
- **Workspace Assignment**: Auto-assign apps to specific workspaces
- **Focus Behavior**: Control focus stealing and new window focus

### Animation System
- **Window Animations**: Smooth open/close transitions
- **Workspace Transitions**: Fluid workspace switching
- **Resize Animations**: Smooth window resizing
- **Fade Effects**: Window fade in/out

## Desktop Integration

### Theme Integration
Desktop components automatically adapt to the selected theme:
- Window border colors
- Panel/taskbar theming
- Icon themes
- Cursor themes

### Hardware Integration
- **GPU Acceleration**: Optimal performance on all graphics hardware
- **Multi-Monitor**: Automatic detection and configuration
- **HiDPI Support**: Proper scaling for high-resolution displays
- **Input Devices**: Touchpad gestures, mouse sensitivity

### Audio Integration
- **Media Keys**: Hardware media key support
- **Volume Control**: On-screen volume indicators
- **Audio Device Switching**: Quick audio output switching
- **Notification Sounds**: System sound integration

## Performance Optimization

### GPU Optimization
- **Hardware Acceleration**: GPU-accelerated compositing
- **VSync Configuration**: Tear-free rendering
- **Frame Rate Management**: Adaptive refresh rates
- **Multi-GPU Support**: Optimal GPU selection

### Memory Management
- **Efficient Compositing**: Minimal memory usage
- **Background Process Limits**: Control background applications
- **Cache Management**: Optimal caching strategies
- **Resource Monitoring**: System resource awareness

### Battery Optimization (Laptops)
- **Power-Aware Rendering**: Reduced effects on battery
- **CPU Scaling**: Dynamic performance scaling
- **Display Brightness**: Automatic brightness adjustment
- **Background Process Management**: Suspend non-essential processes

## Customization Options

### Layout Customization
```nix
wayland.windowManager.hyprland.settings = {
  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 2;
    layout = "dwindle";  # or "master"
  };

  decoration = {
    rounding = 10;
    blur = {
      enabled = true;
      size = 8;
      passes = 1;
    };
    drop_shadow = true;
    shadow_range = 4;
    shadow_render_power = 3;
  };
};
```

### Animation Customization
```nix
animation = {
  enabled = true;
  bezier = [
    "wind, 0.05, 0.9, 0.1, 1.05"
    "winIn, 0.1, 1.1, 0.1, 1.1"
    "winOut, 0.3, -0.3, 0, 1"
  ];

  animation = [
    "windows, 1, 6, wind, slide"
    "windowsIn, 1, 6, winIn, slide"
    "windowsOut, 1, 5, winOut, slide"
    "fade, 1, 10, default"
    "workspaces, 1, 5, wind"
  ];
};
```

## Desktop Components Integration

### Panel (Waybar)
- System status display
- Workspace indicators
- System tray integration
- Custom module support

### Application Launcher
- Quick application access
- Search functionality
- Recent application history
- Customizable appearance

### File Manager Integration
- Desktop file operations
- Trash management
- Network location access
- Archive handling

### Notification System
- Desktop notifications
- Notification history
- Do-not-disturb modes
- Custom notification rules

## Troubleshooting

### Common Issues
- **Performance Problems**: Check GPU acceleration
- **Input Issues**: Verify input device configuration
- **Display Problems**: Check monitor configuration
- **Audio Issues**: Verify PipeWire integration

### Debugging Tools
- `hyprctl`: Hyprland control utility
- `waybar-log`: Panel debugging
- `journalctl`: System logs
- `htop`: Resource monitoring

This desktop configuration provides a modern, efficient, and highly customizable desktop environment that adapts to user preferences while maintaining excellent performance across various hardware configurations.