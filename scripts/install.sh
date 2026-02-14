#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="$PROJECT_ROOT/bin/legcord"
LEGcord_URL="https://github.com/Legcord/Legcord/releases/latest/download/Legcord-linux-arm64.AppImage"

echo "=== Legcord Headless Installer ==="

if [ "$EUID" -ne 0 ]; then
  echo "Requesting sudo for dependencies..."
  sudo apt update
  sudo apt install -y xvfb openbox x11vnc
else
  apt update
  apt install -y xvfb openbox x11vnc
fi

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
START_SCRIPT="$PROJECT_ROOT/scripts/start.sh"
HEALTH_CHECK_SCRIPT="$PROJECT_ROOT/scripts/health-check.sh"

chmod +x "$START_SCRIPT" "$HEALTH_CHECK_SCRIPT"

(crontab -l 2>/dev/null | grep -v "legcord"; echo "@reboot $START_SCRIPT") | crontab -
(crontab -l 2>/dev/null | grep -v "health-check"; echo "* * * * * $HEALTH_CHECK_SCRIPT") | crontab -

echo "Installation complete!"
echo "Run $START_SCRIPT to start Legcord"
