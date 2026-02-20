# Legcord Headless Kiosk (RPi Bookworm Edition)

A robust, self-healing automation system for running Legcord on a Raspberry Pi (optimized for 3B+ and newer) using RealVNC Virtual Mode for 24/7 headless availability.

## Overview

This project enables a Raspberry Pi to maintain a 24/7 Discord presence without a physical monitor. By utilizing RealVNC's native Virtual Mode and the Openbox window manager, the system runs Legcord in a lightweight "Kiosk" environment. This approach is 100% ToS-compliant, as it uses the full Electron engine (Legcord), appearing as a legitimate human login rather than a "self-bot."

## Tech Stack

- **Hardware**: Raspberry Pi 3B+ / 4 / 5
- **OS**: Raspberry Pi OS Bookworm (64-bit)
- **Display Engine**: X11 (Required for RealVNC Virtual Mode stability)
- **Window Manager**: Openbox (Minimalist/High Performance)
- **VNC Server**: RealVNC Server (Virtual Mode)
- **Automation**: Cron & Custom xstartup

## Features

1. **Virtual Mode Integration** - Uses RealVNC's native virtual desktop for superior stability over Xvfb.
2. **Direct Kiosk Launch** - Custom xstartup bypasses the heavy LXDE desktop, loading only Openbox and Legcord to save RAM.
3. **Automated Maintenance** - Guaranteed nightly reboots and update cycles to prevent Electron memory leaks.
4. **Self-Healing Boot** - Cron-based automation ensures the virtual room and Legcord recover immediately after power loss.
5. **DND Presence** - Optimized for "Do Not Disturb" accounts to maintain 24/7 green/red status without mouse-jiggling scripts.

## Installation

### 1. System Preparation (X11 Switch)
Raspberry Pi OS Bookworm defaults to Wayland, which must be switched to X11 for Virtual VNC stability:
1. Run: sudo raspi-config
2. Navigate to: Advanced Options > Wayland
3. Select: X11 and reboot the Pi.

### 2. Configure Virtual Startup
Create the startup instructions for the virtual room:
nano ~/.vnc/xstartup

Paste the following:
--------------------------------------------------
#!/bin/sh
# Start the window manager
/usr/bin/openbox &

# Launch Legcord with high-stability flags
/home/schiggity/legcord/Legcord-1.1.5-linux-arm64.AppImage --no-sandbox --disable-gpu --disable-dev-shm-usage
--------------------------------------------------
Apply permissions: chmod +x ~/.vnc/xstartup

## Automation (Crontab)

The system is designed to be fully autonomous. Edit your crontab (crontab -e) and add:

# Nightly System Update (2:00 AM)
0 2 * * * /usr/bin/sudo /usr/bin/apt update && /usr/bin/sudo /usr/bin/apt upgrade -y

# Nightly Reboot (2:30 AM) - Flushes RAM and clears zombie processes
30 2 * * * /usr/bin/sudo /sbin/reboot

# Launch Legcord Virtual Room on Boot (with network delay)
@reboot sleep 15 && /usr/bin/vncserver-virtual > /tmp/vnc_boot.log 2>&1

## Usage

### Remote Access
Connect via RealVNC Viewer to the Pi's IP on Display :1:
192.168.1.10:1

### Manual Commands
- Start Virtual Room: vncserver-virtual
- Kill Virtual Room: vncserver-virtual -kill :1
- Check if running: sudo ss -ltnp | grep 590

## Directory Structure

.
├── legcord/
│   └── Legcord-1.1.5-linux-arm64.AppImage  # Main Binary
├── .vnc/
│   └── xstartup                            # Virtual Kiosk Configuration
├── README.md                               # Project Documentation
└── .gitignore