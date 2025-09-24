{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./nvidia.nix
    ./amd.nix
    ./intel.nix
    ./audio.nix
    ./bluetooth.nix
    ./touchpad.nix
  ];

  # Common hardware support
  hardware = {
    # Enable all firmware
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    # CPU microcode updates
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # OpenGL/Graphics
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      # Common OpenGL packages
      extraPackages = with pkgs; [
        intel-media-driver # Intel VAAPI
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime # Intel OpenCL
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # USB support
    usb-modeswitch.enable = true;

    # Sensor support (for laptops)
    sensor.iio.enable = true;

    # Firmware updater
    fwupd.enable = true;
  };

  # Kernel modules
  boot.kernelModules = [
    # Virtualization
    "kvm-intel"
    "kvm-amd"

    # USB
    "usbhid"

    # Network
    "iwlwifi"
  ];

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  services = {
    # Thermal management
    thermald.enable = mkDefault true;

    # Power profiles daemon (modern power management)
    power-profiles-daemon.enable = true;

    # Firmware update service
    fwupd.enable = true;

    # Hardware monitoring
    smartd = {
      enable = true;
      autodetect = true;
    };

    # Automatic CPU frequency scaling
    auto-cpufreq = {
      enable = false; # Disabled by default, conflicts with power-profiles-daemon
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };

  # Additional hardware-specific packages
  environment.systemPackages = with pkgs; [
    # Hardware info
    lshw
    hwinfo
    inxi
    dmidecode
    lscpu
    lsusb
    lspci
    pciutils
    usbutils

    # Disk tools
    smartmontools
    hdparm
    nvme-cli

    # CPU tools
    cpufrequtils
    cpupower-gui

    # GPU tools
    glxinfo
    vulkan-tools

    # Sensors
    lm_sensors

    # Power management
    powertop
    acpi

    # Benchmarking
    stress
    stress-ng
    s-tui
  ];

  # Udev rules for hardware
  services.udev = {
    enable = true;

    extraRules = ''
      # Allow users in wheel group to control backlight
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="*", GROUP="wheel", MODE="0664"

      # Allow users in wheel group to control LEDs
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*", GROUP="wheel", MODE="0664"

      # Gaming controllers
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", GROUP="wheel", MODE="0664"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028f", GROUP="wheel", MODE="0664"
    '';
  };

  # Virtual console configuration
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = [ pkgs.terminus_font ];
  };
}