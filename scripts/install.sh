#!/bin/bash

set -e

INSTALL_DIR="/home/schiggity/legcord"
LEGcord_URL="https://github.com/Legcord/Legcord/releases/latest/download/Legcord-linux-arm64.AppImage"

echo "=== Legcord Headless Installer ==="

sudo apt update
sudo apt install -y xvfb openbox x11vnc xvfb

mkdir -p "$INSTALL_DIR"

if [ ! -f "$INSTALL_DIR/Legcord-latest-linux-arm64.AppImage" ]; then
    echo "Downloading Legcord..."
    wget -O "$INSTALL_DIR/Legcord-latest-linux-arm64.AppImage" "$LEGcord_URL"
    chmod +x "$INSTALL_DIR/Legcord-latest-linux-arm64.AppImage"
fi

if [ ! -L "$INSTALL_DIR/legcord_current" ]; then
    ln -sf "$INSTALL_DIR/Legcord-latest-linux-arm64.AppImage" "$INSTALL_DIR/legcord_current"
    echo "Created symlink: legcord_current -> Legcord-latest-linux-arm64.AppImage"
fi

echo "Installing crontab entries..."
(crontab -l 2>/dev/null | grep -v "legcord"; echo "@reboot $INSTALL_DIR/../scripts/start.sh") | crontab -
(crontab -l 2>/dev/null | grep -v "health-check"; echo "* * * * * $INSTALL_DIR/../scripts/health-check.sh") | crontab -

echo "Installation complete!"
echo "Run ./scripts/start.sh to start Legcord"
