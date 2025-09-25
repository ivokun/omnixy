# Hardware Directory - Hardware Support Modules

The `modules/hardware/` directory contains specialized modules for hardware detection, configuration, and optimization. These modules automatically detect available hardware and configure appropriate drivers, settings, and optimizations.

## Hardware Architecture

The hardware system uses conditional configuration based on detected hardware:
```nix
config = lib.mkIf cfg.hardware.nvidia.enable {
  # NVIDIA-specific configuration only when NVIDIA hardware is present
};
```

## Core Hardware Module

### `default.nix`
**Purpose**: Main hardware detection and coordination module
**What it does**:
- Detects available hardware components
- Enables appropriate hardware-specific modules
- Coordinates between different hardware configurations
- Provides common hardware configuration options

**Detection Logic**:
- GPU detection (Intel, AMD, NVIDIA)
- Audio hardware identification
- Input device configuration
- Network hardware setup

**Module Coordination**:
```nix
imports = [
  ./audio.nix
  ./bluetooth.nix
  ./intel.nix
  ./amd.nix
  ./nvidia.nix
  ./touchpad.nix
];
```

## Graphics Hardware

### `intel.nix`
**Purpose**: Intel integrated graphics configuration
**Hardware Support**:
- Intel HD Graphics (all generations)
- Intel Iris Graphics
- Intel Arc discrete graphics

**What it configures**:
- Intel graphics drivers (i915)
- Hardware acceleration (VA-API)
- Power management optimizations
- Display output configuration

**Features**:
- Vulkan support for gaming
- Hardware video decoding
- Power-efficient graphics scaling
- Multi-monitor support

**Configuration Options**:
```nix
omnixy.hardware.intel = {
  enable = true;
  powerSaving = true;  # Enable power optimizations
  vulkan = true;       # Enable Vulkan API support
};
```

### `amd.nix`
**Purpose**: AMD graphics card configuration
**Hardware Support**:
- AMD Radeon RX series
- AMD Radeon Pro series
- AMD APU integrated graphics

**What it configures**:
- AMDGPU drivers (open-source)
- RADV Vulkan drivers
- Hardware acceleration (VA-API/VDPAU)
- OpenCL compute support

**Features**:
- Gaming optimizations
- Content creation acceleration
- Multi-GPU configurations
- FreeSync support

**Performance Tuning**:
- Dynamic frequency scaling
- Power management profiles
- Thermal management
- Memory clock optimization

### `nvidia.nix`
**Purpose**: NVIDIA graphics card configuration
**Hardware Support**:
- NVIDIA GeForce RTX/GTX series
- NVIDIA Quadro professional cards
- NVIDIA Tesla compute cards

**What it configures**:
- Proprietary NVIDIA drivers
- CUDA toolkit integration
- Hardware acceleration
- Power management

**Features**:
- Game-ready drivers
- NVENC/NVDEC hardware encoding
- CUDA development support
- G-Sync compatibility
- Optimus laptop support

**Special Considerations**:
- Wayland compatibility configuration
- Hybrid graphics laptop support
- Multiple monitor setup
- Custom kernel parameters

## Audio Hardware

### `audio.nix`
**Purpose**: Audio system configuration and optimization
**Audio Stack**: PipeWire with ALSA/PulseAudio compatibility

**What it configures**:
- PipeWire audio server
- Low-latency audio for content creation
- Multiple audio device management
- Bluetooth audio support

**Supported Hardware**:
- Built-in laptop audio
- USB audio interfaces
- Professional audio equipment
- Bluetooth headphones and speakers

**Features**:
- Real-time audio processing
- Multi-channel audio support
- Audio routing and mixing
- Professional audio plugin support

**Optimizations**:
- Low-latency configuration
- Buffer size optimization
- Audio priority scheduling
- Hardware-specific tweaks

## Input Devices

### `touchpad.nix`
**Purpose**: Laptop touchpad configuration and gestures
**What it configures**:
- Touchpad sensitivity and acceleration
- Multi-touch gesture support
- Palm rejection
- Scrolling behavior

**Gesture Support**:
- Two-finger scrolling
- Pinch-to-zoom
- Three-finger swipe navigation
- Four-finger workspace switching

**Customization Options**:
- Sensitivity adjustment
- Acceleration curves
- Gesture threshold tuning
- Disable-while-typing settings

## Connectivity

### `bluetooth.nix`
**Purpose**: Bluetooth hardware and device management
**What it configures**:
- BlueZ Bluetooth stack
- Device pairing and authentication
- Audio codec support (A2DP, aptX)
- Power management

**Supported Devices**:
- Bluetooth headphones/speakers
- Keyboards and mice
- Game controllers
- File transfer devices

**Features**:
- Automatic device reconnection
- Multiple device management
- Profile switching
- Battery level monitoring

## Hardware Detection Logic

### Automatic Detection
The hardware system automatically detects:

```nix
# GPU Detection
gpu = if builtins.pathExists "/sys/class/drm/card0" then
  # Detect GPU vendor from driver information
  # Enable appropriate GPU module
else null;

# Audio Detection
audio = if config.sound.enable then
  # Configure audio hardware
else null;
```

### Manual Override
Users can override automatic detection:

```nix
# Force NVIDIA configuration even if not detected
omnixy.hardware.nvidia.enable = true;
omnixy.hardware.nvidia.prime = {
  enable = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

## Power Management

### Laptop Optimization
- Battery life optimization
- CPU frequency scaling
- GPU power states
- Display brightness control

### Desktop Performance
- Maximum performance profiles
- Gaming optimizations
- Content creation acceleration
- Thermal management

## Multi-GPU Systems

### Hybrid Graphics (Optimus/Prime)
- Automatic GPU switching
- Application-specific GPU assignment
- Power saving when not gaming
- External display routing

### Multi-GPU Rendering
- SLI/CrossFire support where applicable
- Compute workload distribution
- Mining/AI acceleration setup

## Hardware-Specific Optimizations

### Gaming Configuration
```nix
omnixy.hardware.gaming = {
  enable = true;
  performance = "high";
  gpu = "nvidia";  # or "amd" or "intel"
};
```

### Content Creation
```nix
omnixy.hardware.creation = {
  enable = true;
  audio.lowLatency = true;
  gpu.acceleration = true;
};
```

### Development Workstation
```nix
omnixy.hardware.development = {
  enable = true;
  containers = true;
  virtualization = true;
};
```

## Troubleshooting

### Hardware Detection Issues
- Check `lspci` output for hardware presence
- Verify kernel module loading
- Check hardware compatibility lists

### Driver Problems
- Use hardware-specific logs
- Check driver version compatibility
- Verify configuration syntax

### Performance Issues
- Monitor hardware utilization
- Check thermal throttling
- Verify power management settings

## Adding New Hardware Support

### Creating Hardware Modules

1. **Create Module File**:
```nix
# modules/hardware/my-hardware.nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.omnixy.hardware.myHardware;
in {
  options.omnixy.hardware.myHardware = {
    enable = mkEnableOption "My Hardware support";
    # Additional options...
  };

  config = mkIf cfg.enable {
    # Hardware configuration
  };
}
```

2. **Add to Hardware Module**:
```nix
# In modules/hardware/default.nix
imports = [
  # ... existing imports
  ./my-hardware.nix
];
```

3. **Implement Detection**:
```nix
# Add automatic detection logic
config.omnixy.hardware.myHardware.enable = mkDefault (
  # Detection logic here
);
```

### Hardware Module Guidelines
- Use conditional configuration (`mkIf`)
- Provide sensible defaults
- Include performance optimizations
- Document hardware requirements
- Test on multiple hardware configurations

This comprehensive hardware support system ensures OmniXY works optimally across a wide variety of hardware configurations while providing easy customization for specific needs.