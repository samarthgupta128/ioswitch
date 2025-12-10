#!/bin/bash
# IO Switch - Native Messaging Host Uninstaller for Linux
# Run this script with sudo to uninstall the native messaging host

set -e

echo "============================================"
echo "  IO Switch - Native Host Uninstaller (Linux)"
echo "============================================"
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script requires root privileges."
    echo "Please run with: sudo ./uninstall_host.sh"
    exit 1
fi

INSTALL_DIR="/usr/lib/ioswitch"
MANIFEST_DIR_SYSTEM="/usr/lib/mozilla/native-messaging-hosts"

echo "Removing native messaging host..."

# Remove system manifest symlink
if [ -L "$MANIFEST_DIR_SYSTEM/ioswitch.json" ]; then
    rm -f "$MANIFEST_DIR_SYSTEM/ioswitch.json"
    echo "Removed: $MANIFEST_DIR_SYSTEM/ioswitch.json"
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed: $INSTALL_DIR"
fi

# Try to remove user manifests
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    
    # Regular Firefox
    USER_MANIFEST="$USER_HOME/.mozilla/native-messaging-hosts/ioswitch.json"
    if [ -L "$USER_MANIFEST" ] || [ -f "$USER_MANIFEST" ]; then
        rm -f "$USER_MANIFEST"
        echo "Removed: $USER_MANIFEST"
    fi
    
    # Firefox Snap
    SNAP_MANIFEST="$USER_HOME/snap/firefox/common/.mozilla/native-messaging-hosts/ioswitch.json"
    if [ -L "$SNAP_MANIFEST" ] || [ -f "$SNAP_MANIFEST" ]; then
        rm -f "$SNAP_MANIFEST"
        echo "Removed: $SNAP_MANIFEST"
    fi
    
    # Firefox Flatpak
    FLATPAK_MANIFEST="$USER_HOME/.var/app/org.mozilla.firefox/.mozilla/native-messaging-hosts/ioswitch.json"
    if [ -L "$FLATPAK_MANIFEST" ] || [ -f "$FLATPAK_MANIFEST" ]; then
        rm -f "$FLATPAK_MANIFEST"
        echo "Removed: $FLATPAK_MANIFEST"
    fi
fi

echo ""
echo "============================================"
echo "  Uninstallation Complete!"
echo "============================================"
echo ""
echo "The native messaging host has been removed."
echo "You can also remove the extension from Firefox (about:addons)"
echo ""
