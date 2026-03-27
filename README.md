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
- **Automation**: systemd services + cron health checks
- **Reliability**: Hardware watchdog + memory-limited services + health monitor

## Features

1. Virtual Mode integration for stable headless operation.
2. Direct kiosk launch (Openbox + Legcord only) for low resource usage.
3. Automated nightly update/reboot maintenance.
4. systemd services with memory limits (replaces fragile cron `@reboot`).
5. Hardware watchdog for automatic recovery from system hangs.
6. Health check script (every 5 min) restarts Legcord if memory drops below 50MB.
7. Optimized Chromium flags to reduce memory/CPU footprint.
8. lightdm disabled to save resources on headless setup.

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

# 1. Start a lightweight window manager so Legcord can render properly
/usr/bin/openbox &

# 2. Launch Legcord with memory-optimized flags
exec /home/<user>/legcord/Legcord-<version>-linux-arm64.AppImage \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-extensions \
    --disable-background-networking \
    --disable-sync \
    --disable-translate \
    --disable-logging \
    --no-first-run \
    --js-flags="--max-old-space-size=192"
```

Then apply permissions:

```sh
chmod +x ~/.vnc/xstartup
```

## Systemd Services

### Legcord VNC Service

`/etc/systemd/system/legcord-vnc.service`:

```ini
[Unit]
Description=Legcord Discord Presence (VNC)
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=<user>
ExecStart=/usr/bin/vncserver-virtual :1
ExecStop=/usr/bin/vncserver-virtual -kill :1
Restart=on-failure
RestartSec=15
MemoryMax=550M
MemoryHigh=450M
CPUQuota=80%
OOMPolicy=stop

[Install]
WantedBy=multi-user.target
```

### Discord Forward Blocker Service

`/etc/systemd/system/discord-bot.service`:

```ini
[Unit]
Description=Discord Forward Blocker Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<user>
WorkingDirectory=/home/<user>/bot
ExecStart=/home/<user>/bot/venv/bin/python /home/<user>/bot/discord_bot.py
Restart=on-failure
RestartSec=30
MemoryMax=100M
MemoryHigh=80M
StandardOutput=append:/home/<user>/bot/bot.log
StandardError=append:/home/<user>/bot/bot.log

[Install]
WantedBy=multi-user.target
```

Enable both:

```sh
sudo systemctl daemon-reload
sudo systemctl enable legcord-vnc.service discord-bot.service
```

## Hardware Watchdog

Enables the Pi's built-in BCM2835 watchdog to automatically reboot on system hang:

```sh
sudo apt install watchdog
echo "bcm2835_wdt" | sudo tee /etc/modules-load.d/watchdog.conf
sudo systemctl enable watchdog
```

## Automation (Crontab)

Edit crontab with `crontab -e` and add:

```cron
# Nightly system update (2:00 AM)
0 2 * * * DEBIAN_FRONTEND=noninteractive /usr/bin/sudo /usr/bin/apt update -qq && DEBIAN_FRONTEND=noninteractive /usr/bin/sudo /usr/bin/apt upgrade -y -qq

# Nightly reboot (2:30 AM)
30 2 * * * /usr/bin/sudo /sbin/reboot

# Health check every 5 minutes
*/5 * * * * /usr/bin/sudo /usr/local/bin/pi-health-check.sh
```

> **Note**: Boot startup is handled by systemd services, not cron `@reboot`.

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
