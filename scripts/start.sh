#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="$PROJECT_ROOT/bin/legcord"
DISPLAY_NUM=1

echo "=== Starting Legcord Headless ==="

pkill -f Legcord || true
pkill -f Xvfb || true
sleep 2

rm -f /tmp/.X${DISPLAY_NUM}-lock
rm -f /tmp/.X11-unix/X${DISPLAY_NUM}

export DISPLAY=:${DISPLAY_NUM}

/usr/bin/Xvfb :${DISPLAY_NUM} -screen 0 1280x720x24 -ac &
XVFB_PID=$!
echo "Started Xvfb (PID: $XVFB_PID)"
sleep 5

/usr/bin/openbox &
OPENBOX_PID=$!
echo "Started Openbox (PID: $OPENBOX_PID)"
sleep 2

if [ -L "$INSTALL_DIR/legcord_current" ]; then
    LEGCORD_BIN=$(readlink -f "$INSTALL_DIR/legcord_current")
else
    LEGCORD_BIN="$INSTALL_DIR/Legcord-latest-linux-arm64.AppImage"
fi

echo "Starting Legcord: $LEGCORD_BIN"
$LEGCORD_BIN &
LEGCORD_PID=$!
echo "Started Legcord (PID: $LEGCORD_PID)"
sleep 5

/usr/bin/x11vnc -display :${DISPLAY_NUM} -forever -usepw -bg
echo "Started x11vnc"

echo "=== Legcord is running ==="
