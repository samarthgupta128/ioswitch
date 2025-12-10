#!/bin/bash
# IO Switch - Native Messaging Host Installer for Linux
# Run this script with sudo to install the native messaging host

set -e

echo "============================================"
echo "  IO Switch - Native Host Installer (Linux)"
echo "============================================"
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script requires root privileges."
    echo "Please run with: sudo ./install_host.sh"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/lib/ioswitch"
MANIFEST_DIR_SYSTEM="/usr/lib/mozilla/native-messaging-hosts"
MANIFEST_DIR_USER="$HOME/.mozilla/native-messaging-hosts"

echo "Installing to: $INSTALL_DIR"
echo ""

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Copy files
echo "Copying files..."
cp "$SCRIPT_DIR/ioswitch_host.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/ioswitch_host.sh"

# Create the manifest with the correct path
echo "Creating native messaging manifest..."
cat > "$INSTALL_DIR/ioswitch.json" << EOF
{
  "name": "ioswitch",
  "description": "IO Switch Native Messaging Host - Opens URLs in external browser",
  "path": "$INSTALL_DIR/ioswitch_host.sh",
  "type": "stdio",
  "allowed_extensions": ["ioswitch@example.com"]
}
EOF

# Install manifest for system-wide Firefox
echo "Installing manifest for Firefox..."
mkdir -p "$MANIFEST_DIR_SYSTEM"
ln -sf "$INSTALL_DIR/ioswitch.json" "$MANIFEST_DIR_SYSTEM/ioswitch.json"

# Also try to install for user's Firefox (for Snap/Flatpak versions)
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    USER_MANIFEST_DIR="$USER_HOME/.mozilla/native-messaging-hosts"
    mkdir -p "$USER_MANIFEST_DIR"
    ln -sf "$INSTALL_DIR/ioswitch.json" "$USER_MANIFEST_DIR/ioswitch.json"
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_MANIFEST_DIR"
    echo "Also installed for user: $SUDO_USER"
fi

# Handle Firefox Snap (Ubuntu 22.04+)
SNAP_MANIFEST_DIR="/snap/firefox/common/.mozilla/native-messaging-hosts"
if [ -d "/snap/firefox" ]; then
    echo "Detected Firefox Snap installation..."
    if [ -n "$SUDO_USER" ]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        SNAP_USER_DIR="$USER_HOME/snap/firefox/common/.mozilla/native-messaging-hosts"
        mkdir -p "$SNAP_USER_DIR"
        ln -sf "$INSTALL_DIR/ioswitch.json" "$SNAP_USER_DIR/ioswitch.json"
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/snap/firefox/common/.mozilla"
        echo "Installed for Firefox Snap"
    fi
fi

# Handle Firefox Flatpak
if command -v flatpak &> /dev/null && flatpak list | grep -q "org.mozilla.firefox"; then
    echo "Detected Firefox Flatpak installation..."
    if [ -n "$SUDO_USER" ]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        FLATPAK_DIR="$USER_HOME/.var/app/org.mozilla.firefox/.mozilla/native-messaging-hosts"
        mkdir -p "$FLATPAK_DIR"
        ln -sf "$INSTALL_DIR/ioswitch.json" "$FLATPAK_DIR/ioswitch.json"
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.var/app/org.mozilla.firefox/.mozilla"
        echo "Installed for Firefox Flatpak"
    fi
fi

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "The native messaging host has been installed."
echo ""
echo "Next steps:"
echo "1. Load the extension in Firefox (about:debugging)"
echo "2. Restart Firefox"
echo "3. Click the IO Switch icon to configure domains"
echo ""
echo "Files installed:"
echo "  - $INSTALL_DIR/ioswitch_host.sh"
echo "  - $INSTALL_DIR/ioswitch.json"
echo "  - $MANIFEST_DIR_SYSTEM/ioswitch.json (symlink)"
echo ""
