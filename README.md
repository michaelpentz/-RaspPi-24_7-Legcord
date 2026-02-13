# Legcord Headless Kiosk

A robust, self-healing automation system for running Legcord on a Raspberry Pi 3B+ using a virtual framebuffer and automated maintenance cycles.

## Overview

This project enables the Raspberry Pi to run a graphical application (Legcord) without a physical monitor attached. By utilizing a virtual display buffer and a lightweight window manager, the system maximizes the Pi 3B+'s limited resources while ensuring 24/7 availability through automated nightly maintenance.

## Tech Stack

- **Hardware**: Raspberry Pi 3B+
- **Display Server**: Xvfb (X Virtual Framebuffer)
- **Window Manager**: Openbox (Minimalist/High Performance)
- **Remote Access**: x11vnc
- **Automation**: Bash & Cron

## Features

1. **Virtual Display Management** - Xvfb provides a virtual 1280x720 display in memory
2. **Self-Healing** - Health-check script auto-restarts Legcord if it crashes
3. **Symlink Updates** - Use `legcord_current` symlink for easy Legcord updates
4. **Idempotent Launcher** - Safe to run multiple times
5. **VNC Access** - Remote GUI access via x11vnc

## Quick Install

```bash
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

## Usage

### Start Legcord
```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

### Manual Health Check
```bash
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

### Update Legcord
Download new AppImage to `bin/legcord/`, then update symlink:
```bash
ln -sf Legcord-new-version.AppImage bin/legcord/legcord_current
```

## Crontab

The installer sets up these cron jobs:
- `@reboot` - Starts Legcord on boot
- `* * * * *` - Health-check runs every minute

## Manual Crontab Setup

```bash
# Start on reboot
@reboot /home/schiggity/legcord/scripts/start.sh

# Nightly update and reboot (2 AM)
0 2 * * * sudo apt update && sudo apt upgrade -y && /sbin/reboot

# Health check every minute
* * * * * /home/schiggity/legcord/scripts/health-check.sh
```

## VNC Access

Connect to `raspberrypi:5900` with password configured during first run.

## Directory Structure

```
.
├── scripts/
│   ├── install.sh      # Installation script
│   ├── start.sh        # Main launcher
│   └── health-check.sh # Auto-restart monitor
├── bin/
│   └── legcord/        # Legcord AppImage storage
├── README.md
└── .gitignore
```
