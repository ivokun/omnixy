#!/usr/bin/env bash
# OmniXY Disk Partitioning Module
# Comprehensive partitioning with LUKS encryption support
# Follows NixOS Installation Guide recommendations

set -e

# Color setup for output
setup_colors() {
    RED=$(printf '\033[38;2;247;118;142m')
    GREEN=$(printf '\033[38;2;158;206;106m')
    YELLOW=$(printf '\033[38;2;224;175;104m')
    CYAN=$(printf '\033[38;2;125;207;255m')
    BLUE=$(printf '\033[38;2;122;162;247m')
    PURPLE=$(printf '\033[38;2;187;154;247m')
    FG=$(printf '\033[38;2;192;202;245m')
    BOLD=$(printf '\033[1m')
    DIM=$(printf '\033[2m')
    RESET=$(printf '\033[0m')
}

setup_colors

# Utility functions
log_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

# VM Detection
detect_vm() {
    if systemd-detect-virt >/dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt)
        if [ "$virt_type" != "none" ]; then
            log_info "Running in virtualized environment: $virt_type"
            return 0
        fi
    fi
    return 1
}

# List available disks
list_disks() {
    log_info "Available disks:"
    echo
    lsblk -d -n -o NAME,SIZE,TYPE,MODEL | while read -r name size type model; do
        # Include both sd* and vd* devices
        if [[ "$name" =~ ^(sd|vd|nvme) ]]; then
            echo "  ${CYAN}/dev/$name${RESET} - $size - $model"
            # Show existing partitions if any
            lsblk /dev/$name -n -o NAME,SIZE,FSTYPE,MOUNTPOINT 2>/dev/null | tail -n +2 | while read -r part psize fstype mount; do
                echo "    └─ $part - $psize - ${fstype:-none} ${mount:+(mounted: $mount)}"
            done
        fi
    done
    echo
}

# Disk selection with VM support
select_disk() {
    list_disks

    local selected_disk=""
    while [ -z "$selected_disk" ]; do
        read -p "${CYAN}Enter disk device (e.g., /dev/sda, /dev/vda, /dev/nvme0n1): ${RESET}" disk_input

        # Normalize input
        if [[ ! "$disk_input" =~ ^/dev/ ]]; then
            disk_input="/dev/$disk_input"
        fi

        # Validate disk exists
        if [ -b "$disk_input" ]; then
            # Confirm destructive operation
            echo
            log_warn "WARNING: All data on $disk_input will be destroyed!"
            read -p "${YELLOW}Type 'yes' to confirm: ${RESET}" confirm
            if [ "$confirm" = "yes" ]; then
                selected_disk="$disk_input"
            else
                log_info "Disk selection cancelled"
            fi
        else
            log_error "Device $disk_input does not exist or is not a block device"
        fi
    done

    echo "$selected_disk"
}

# Partition scheme selection
select_partition_scheme() {
    echo
    log_info "Select partition scheme:"
    echo "  1) Automatic - Standard layout with optional encryption"
    echo "  2) Manual - Use existing partitions"
    echo "  3) Custom - Interactive partitioning"
    echo

    local scheme=""
    while [ -z "$scheme" ]; do
        read -p "${CYAN}Choice (1-3): ${RESET}" choice
        case $choice in
            1) scheme="automatic";;
            2) scheme="manual";;
            3) scheme="custom";;
            *) log_error "Invalid choice";;
        esac
    done

    echo "$scheme"
}

# Detect boot mode (UEFI or BIOS)
detect_boot_mode() {
    if [ -d /sys/firmware/efi/efivars ]; then
        echo "uefi"
    else
        echo "bios"
    fi
}

# Automatic partitioning with LUKS support
automatic_partition() {
    local disk="$1"
    local encrypt="${2:-false}"
    local boot_mode=$(detect_boot_mode)

    log_info "Starting automatic partitioning on $disk"
    log_info "Boot mode: $boot_mode"

    # Wipe disk
    log_info "Wiping disk..."
    wipefs -af "$disk" >/dev/null 2>&1
    sgdisk -Z "$disk" >/dev/null 2>&1

    # Create partition table
    if [ "$boot_mode" = "uefi" ]; then
        log_info "Creating GPT partition table..."
        parted -s "$disk" mklabel gpt

        # Create partitions
        log_info "Creating EFI partition..."
        parted -s "$disk" mkpart ESP fat32 1MiB 512MiB
        parted -s "$disk" set 1 esp on

        log_info "Creating boot partition..."
        parted -s "$disk" mkpart primary ext4 512MiB 1GiB

        log_info "Creating root partition..."
        parted -s "$disk" mkpart primary 1GiB 100%

        # Wait for kernel to recognize partitions
        partprobe "$disk"
        sleep 2

        # Determine partition naming
        if [[ "$disk" =~ nvme ]]; then
            local efi_part="${disk}p1"
            local boot_part="${disk}p2"
            local root_part="${disk}p3"
        else
            local efi_part="${disk}1"
            local boot_part="${disk}2"
            local root_part="${disk}3"
        fi
    else
        log_info "Creating MBR partition table..."
        parted -s "$disk" mklabel msdos

        log_info "Creating boot partition..."
        parted -s "$disk" mkpart primary ext4 1MiB 512MiB
        parted -s "$disk" set 1 boot on

        log_info "Creating root partition..."
        parted -s "$disk" mkpart primary 512MiB 100%

        # Wait for kernel to recognize partitions
        partprobe "$disk"
        sleep 2

        # Determine partition naming
        if [[ "$disk" =~ nvme ]]; then
            local boot_part="${disk}p1"
            local root_part="${disk}p2"
        else
            local boot_part="${disk}1"
            local root_part="${disk}2"
        fi
    fi

    # Setup encryption if requested
    if [ "$encrypt" = "true" ]; then
        log_info "Setting up LUKS encryption..."

        # Get passphrase
        local passphrase=""
        local passphrase_confirm=""
        while true; do
            read -s -p "${CYAN}Enter LUKS passphrase: ${RESET}" passphrase
            echo
            read -s -p "${CYAN}Confirm passphrase: ${RESET}" passphrase_confirm
            echo

            if [ "$passphrase" = "$passphrase_confirm" ]; then
                if [ ${#passphrase} -ge 8 ]; then
                    break
                else
                    log_error "Passphrase must be at least 8 characters"
                fi
            else
                log_error "Passphrases do not match"
            fi
        done

        # Encrypt root partition
        log_info "Encrypting root partition..."
        echo -n "$passphrase" | cryptsetup luksFormat --type luks2 "$root_part" -

        log_info "Opening encrypted partition..."
        echo -n "$passphrase" | cryptsetup open "$root_part" cryptroot -

        # Update root partition reference
        root_part="/dev/mapper/cryptroot"
    fi

    # Format partitions
    log_info "Formatting partitions..."

    if [ "$boot_mode" = "uefi" ]; then
        mkfs.fat -F32 -n ESP "$efi_part"
        mkfs.ext4 -L boot "$boot_part"
    else
        mkfs.ext4 -L boot "$boot_part"
    fi

    # Format root - offer filesystem choice
    echo
    log_info "Select root filesystem:"
    echo "  1) ext4 (recommended, stable)"
    echo "  2) btrfs (snapshots, compression)"
    echo "  3) zfs (advanced features, requires setup)"
    echo

    local fs_type="ext4"
    read -p "${CYAN}Choice (1-3) [default: 1]: ${RESET}" fs_choice
    case $fs_choice in
        2) fs_type="btrfs";;
        3) fs_type="zfs";;
        *) fs_type="ext4";;
    esac

    case $fs_type in
        ext4)
            mkfs.ext4 -L nixos "$root_part"
            ;;
        btrfs)
            mkfs.btrfs -L nixos "$root_part"
            ;;
        zfs)
            log_warn "ZFS requires additional setup"
            # Create ZFS pool
            zpool create -f -o ashift=12 -O compression=lz4 -O xattr=sa -O acltype=posixacl -O mountpoint=none rpool "$root_part"
            zfs create -o mountpoint=legacy rpool/root
            zfs create -o mountpoint=legacy rpool/home
            ;;
    esac

    # Mount partitions
    log_info "Mounting partitions..."

    # Mount root
    if [ "$fs_type" = "zfs" ]; then
        mount -t zfs rpool/root /mnt
        mkdir -p /mnt/home
        mount -t zfs rpool/home /mnt/home
    else
        mount "$root_part" /mnt
    fi

    # Mount boot
    mkdir -p /mnt/boot
    mount "$boot_part" /mnt/boot

    # Mount EFI if UEFI
    if [ "$boot_mode" = "uefi" ]; then
        mkdir -p /mnt/boot/efi
        mount "$efi_part" /mnt/boot/efi
    fi

    # Create swap file
    log_info "Creating swap file..."
    local ram_size=$(free -g | awk '/^Mem:/{print $2}')
    local swap_size=$((ram_size < 8 ? ram_size * 2 : ram_size))

    if [ "$fs_type" = "btrfs" ]; then
        # Btrfs requires special handling for swap
        btrfs subvolume create /mnt/swap
        truncate -s 0 /mnt/swap/swapfile
        chattr +C /mnt/swap/swapfile
        fallocate -l ${swap_size}G /mnt/swap/swapfile
    else
        fallocate -l ${swap_size}G /mnt/swapfile
    fi

    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile

    log_success "Automatic partitioning complete"

    # Return partition information
    cat <<EOF
PARTITION_INFO
DISK=$disk
BOOT_MODE=$boot_mode
ROOT_PART=$root_part
BOOT_PART=$boot_part
${boot_mode:+EFI_PART=$efi_part}
FS_TYPE=$fs_type
ENCRYPTED=$encrypt
EOF
}

# Manual partition selection
manual_partition() {
    log_info "Manual partition selection"
    echo
    log_info "Available partitions:"
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
    echo

    # Get root partition
    local root_part=""
    while [ -z "$root_part" ]; do
        read -p "${CYAN}Enter root partition (e.g., /dev/sda2): ${RESET}" root_part
        if [ ! -b "$root_part" ]; then
            log_error "Partition $root_part does not exist"
            root_part=""
        fi
    done

    # Check if encrypted
    local encrypted="false"
    if cryptsetup isLuks "$root_part" 2>/dev/null; then
        log_info "Detected LUKS encrypted partition"
        encrypted="true"
        read -s -p "${CYAN}Enter passphrase: ${RESET}" passphrase
        echo
        echo -n "$passphrase" | cryptsetup open "$root_part" cryptroot -
        root_part="/dev/mapper/cryptroot"
    fi

    # Get boot partition
    local boot_part=""
    read -p "${CYAN}Enter boot partition (leave empty if combined with root): ${RESET}" boot_part

    # Get EFI partition if UEFI
    local efi_part=""
    if [ "$(detect_boot_mode)" = "uefi" ]; then
        read -p "${CYAN}Enter EFI partition: ${RESET}" efi_part
        if [ ! -b "$efi_part" ]; then
            log_error "EFI partition required for UEFI systems"
            exit 1
        fi
    fi

    # Mount partitions
    log_info "Mounting partitions..."
    mount "$root_part" /mnt

    if [ -n "$boot_part" ]; then
        mkdir -p /mnt/boot
        mount "$boot_part" /mnt/boot
    fi

    if [ -n "$efi_part" ]; then
        mkdir -p /mnt/boot/efi
        mount "$efi_part" /mnt/boot/efi
    fi

    log_success "Manual partition setup complete"
}

# Custom interactive partitioning
custom_partition() {
    local disk="$1"

    log_info "Starting custom partitioning with gdisk/fdisk"
    log_warn "This will launch an interactive partitioning tool"
    echo
    echo "Guidelines:"
    echo "  - UEFI systems: Create EFI (512MB), boot (512MB), and root partitions"
    echo "  - BIOS systems: Create boot (512MB) and root partitions"
    echo "  - Consider leaving space for swap or using a swap file"
    echo
    read -p "${CYAN}Press Enter to continue...${RESET}"

    # Launch appropriate tool
    if command -v gdisk >/dev/null; then
        gdisk "$disk"
    elif command -v fdisk >/dev/null; then
        fdisk "$disk"
    else
        log_error "No partitioning tool available"
        exit 1
    fi

    # After partitioning, guide through formatting
    log_info "Partitioning complete. Now format and mount partitions."
    manual_partition
}

# Validate mount points
validate_mounts() {
    log_info "Validating mount points..."

    # Check root is mounted
    if ! mountpoint -q /mnt; then
        log_error "Root filesystem not mounted at /mnt"
        return 1
    fi

    # Check boot for UEFI
    if [ "$(detect_boot_mode)" = "uefi" ]; then
        if ! mountpoint -q /mnt/boot/efi && ! mountpoint -q /mnt/boot; then
            log_error "EFI partition not mounted"
            return 1
        fi
    fi

    log_success "Mount points validated"
    return 0
}

# Generate hardware configuration
generate_hardware_config() {
    log_info "Generating NixOS hardware configuration..."
    nixos-generate-config --root /mnt
    log_success "Hardware configuration generated"
}

# Main partitioning flow
main() {
    echo
    log_info "${BOLD}OmniXY Disk Partitioning Module${RESET}"
    echo

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi

    # Detect VM environment
    if detect_vm; then
        log_info "VM environment detected - looking for vda devices"
    fi

    # Check if already mounted
    if mountpoint -q /mnt; then
        log_warn "/mnt is already mounted"
        read -p "${YELLOW}Unmount and continue? (y/N): ${RESET}" unmount
        if [ "$unmount" = "y" ]; then
            umount -R /mnt 2>/dev/null || true
            swapoff -a 2>/dev/null || true
        else
            log_info "Using existing mount points"
            validate_mounts && generate_hardware_config
            exit 0
        fi
    fi

    # Select partitioning method
    local scheme=$(select_partition_scheme)

    case $scheme in
        automatic)
            local disk=$(select_disk)

            # Ask about encryption
            local encrypt="false"
            read -p "${CYAN}Enable LUKS encryption? (y/N): ${RESET}" use_encryption
            if [ "$use_encryption" = "y" ]; then
                encrypt="true"
            fi

            automatic_partition "$disk" "$encrypt"
            ;;

        manual)
            manual_partition
            ;;

        custom)
            local disk=$(select_disk)
            custom_partition "$disk"
            ;;
    esac

    # Validate and generate config
    if validate_mounts; then
        generate_hardware_config

        echo
        log_success "${BOLD}Partitioning complete!${RESET}"
        echo
        log_info "Next steps:"
        echo "  1. Install OmniXY configuration to /mnt/etc/nixos"
        echo "  2. Run nixos-install"
        echo "  3. Set root password when prompted"
        echo "  4. Reboot into your new system"
        echo

        # Save partition info for installer
        if [ -n "$PARTITION_INFO" ]; then
            echo "$PARTITION_INFO" > /tmp/omnixy-partition-info
            log_info "Partition information saved to /tmp/omnixy-partition-info"
        fi
    else
        log_error "Mount validation failed"
        exit 1
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi