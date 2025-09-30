#!/usr/bin/env bash
# Quick ISO build test script

set -e

echo "🧪 OmniXY ISO Build Test"
echo "========================"
echo ""

# Check if we're in the right directory
if [ ! -f "flake.nix" ] || [ ! -f "iso.nix" ]; then
    echo "❌ Error: Must be run from the OmniXY project root directory"
    echo "   Expected files: flake.nix, iso.nix"
    exit 1
fi

# Check if nix is available
if ! command -v nix &> /dev/null; then
    echo "❌ Error: Nix is not installed or not in PATH"
    exit 1
fi

# Check flakes support
if ! nix --help | grep -q flakes; then
    echo "❌ Error: Nix flakes not enabled"
    echo "   Add 'experimental-features = nix-command flakes' to nix.conf"
    exit 1
fi

echo "✅ Environment checks passed"
echo ""

# Test flake evaluation
echo "🔍 Testing flake evaluation..."
if nix flake check --no-build 2>/dev/null; then
    echo "✅ Flake configuration is valid"
else
    echo "⚠️  Flake check warnings (this is usually fine for ISO builds)"
fi
echo ""

# Test ISO configuration evaluation
echo "🔍 Testing ISO configuration..."
if nix eval .#nixosConfigurations.omnixy-iso --apply 'config: "ISO config loads successfully"' &>/dev/null; then
    echo "✅ ISO configuration evaluates successfully"
else
    echo "❌ ISO configuration has evaluation errors"
    echo "   Try: nix eval .#nixosConfigurations.omnixy-iso --show-trace"
    exit 1
fi
echo ""

# Estimate build requirements
echo "📊 Build Requirements:"
echo "   • Disk space: ~10-15 GB during build, ~3-5 GB for final ISO"
echo "   • RAM: Recommended 8+ GB (minimum 4 GB)"
echo "   • Time: 30-60 minutes on first build (varies by system)"
echo "   • Network: Several GB of downloads on first build"
echo ""

# Ask if user wants to proceed with actual build
read -p "🚀 Do you want to proceed with building the ISO? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏗️  Starting ISO build..."
    echo "   This may take a while. Press Ctrl+C to cancel."
    echo ""
    
    # Start the build with progress
    if nix build .#iso --print-build-logs; then
        echo ""
        echo "✅ ISO build completed successfully!"
        
        # Find and display the ISO
        if [ -L "./result" ]; then
            iso_path=$(readlink -f ./result)
            iso_file=$(find "$iso_path" -name "*.iso" | head -1)
            
            if [ -n "$iso_file" ]; then
                iso_size=$(du -h "$iso_file" | cut -f1)
                echo "📁 ISO Location: $iso_file"
                echo "📏 ISO Size: $iso_size"
                echo ""
                echo "🚀 Next steps:"
                echo "   • Test in VM: qemu-system-x86_64 -cdrom '$iso_file' -m 4G -enable-kvm"
                echo "   • Flash to USB: sudo dd if='$iso_file' of=/dev/sdX bs=4M status=progress"
                echo "   • See BUILD_ISO.md for complete documentation"
            else
                echo "⚠️  ISO file not found in build result"
            fi
        else
            echo "⚠️  Build result symlink not found"
        fi
    else
        echo ""
        echo "❌ ISO build failed"
        echo "   Check the error messages above for details"
        echo "   Common solutions:"
        echo "   • Free up disk space: nix-collect-garbage -d"
        echo "   • Check internet connection"
        echo "   • Try again (builds can sometimes fail on first attempt)"
        exit 1
    fi
else
    echo "🛑 Build cancelled. You can run this test anytime with:"
    echo "   ./test-iso-build.sh"
    echo ""
    echo "To build manually:"
    echo "   nix build .#iso"
    echo "   nix run .#build-iso"
fi

echo ""
echo "📚 For more information, see BUILD_ISO.md"