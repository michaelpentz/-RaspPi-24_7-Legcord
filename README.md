# Legcord Headless Kiosk (RPi Bookworm Edition)

A robust, self-healing setup for running Legcord on Raspberry Pi (3B+ and newer) using RealVNC Virtual Mode for 24/7 headless availability.

## Overview

This project enables a Raspberry Pi to maintain a 24/7 Discord presence without a physical monitor. It uses RealVNC Virtual Mode with Openbox to run Legcord in a lightweight kiosk environment.

## Tech Stack

- **Hardware**: Raspberry Pi 3B+ / 4 / 5
- **OS**: Raspberry Pi OS Bookworm (64-bit)
- **Display Engine**: X11 (required for RealVNC Virtual Mode stability)
- **Window Manager**: Openbox
- **VNC Server**: RealVNC Server (Virtual Mode)
- **Automation**: Cron + custom `~/.vnc/xstartup`

## Features

1. Virtual Mode integration for stable headless operation.
2. Direct kiosk launch (Openbox + Legcord only) for low resource usage.
3. Automated nightly update/reboot maintenance.
4. Self-healing boot behavior via cron.
5. Optimized for persistent DND presence.

## Installation

### 1. System Preparation (Switch Wayland to X11)

Raspberry Pi OS Bookworm defaults to Wayland. Switch to X11:

1. Run `sudo raspi-config`
2. Go to `Advanced Options > Wayland`
3. Select `X11` and reboot

### 2. Configure Virtual Startup

Create `~/.vnc/xstartup`:

```sh
#!/bin/sh
# Start lightweight window manager
/usr/bin/openbox &

# Launch Legcord (update path/version as needed)
/home/<user>/legcord/Legcord-linux-arm64.AppImage --no-sandbox --disable-gpu --disable-dev-shm-usage
```

Then apply permissions:

```sh
chmod +x ~/.vnc/xstartup
```

## Automation (Crontab)

Edit crontab with `crontab -e` and add:

```cron
# Nightly system update (2:00 AM)
0 2 * * * /usr/bin/sudo /usr/bin/apt update && /usr/bin/sudo /usr/bin/apt upgrade -y

# Nightly reboot (2:30 AM)
30 2 * * * /usr/bin/sudo /sbin/reboot

# Launch virtual room on boot (with network delay)
@reboot sleep 15 && /usr/bin/vncserver-virtual > /tmp/vnc_boot.log 2>&1
```

## Usage

### Remote Access

Connect with RealVNC Viewer to your host on display `:1`:

```text
<raspberry-pi-host-or-ip>:1
```

### Manual Commands

- Start virtual room: `vncserver-virtual`
- Stop virtual room: `vncserver-virtual -kill :1`
- Check VNC listener: `sudo ss -ltnp | grep 590`

## Directory Structure

```text
.
+-- README.md
+-- AGENTS.md
+-- .gitignore
```
