# arm64-headless-presence

Persistent headless client deployment on ARM64 (Raspberry Pi) with automated service management, health monitoring, and self-healing capabilities.

## Overview

Deploys and maintains a 24/7 headless application on ARM64 hardware using systemd service orchestration, VNC virtual display rendering, and automated health recovery. Built for reliability on resource-constrained edge devices.

## Architecture

- **Platform**: Raspberry Pi 3B+/4/5 (ARM64, Bookworm 64-bit)
- **Display**: X11 + Openbox via RealVNC Virtual Mode (no physical monitor)
- **Process Management**: systemd with memory limits and CPU quotas
- **Reliability**: Hardware watchdog (BCM2835), 5-minute health checks, automatic service restart
- **Maintenance**: Unattended nightly updates and scheduled reboots

## Key Engineering Decisions

**systemd over cron @reboot**: Services are managed as proper systemd units with `MemoryMax`, `CPUQuota`, and `OOMPolicy` constraints rather than fragile cron boot scripts.

**Hardware watchdog**: The BCM2835 watchdog timer automatically reboots the device on kernel hangs, eliminating manual intervention for edge-deployed hardware.

**Memory-optimized Chromium flags**: The Electron-based client runs with `--max-old-space-size=192` and disabled background services to stay within the Pi's memory budget.

## Service Configuration

Two systemd units manage the deployment:

| Service | Purpose | Memory Limit | CPU Quota |
|---------|---------|-------------|-----------|
| VNC Presence | Headless display + client application | 550MB (hard) / 450MB (high) | 80% |
| Policy Enforcer | Companion message enforcement service | 100MB (hard) / 80MB (high) | Default |

Both services auto-restart on failure with configurable backoff.

## Automated Maintenance

| Schedule | Task |
|----------|------|
| Every 5 min | Health check: restart service if available memory drops below 50MB |
| 02:00 daily | Unattended system updates (`apt upgrade -y`) |
| 02:30 daily | Scheduled reboot for clean state |

## Setup

1. Switch display server from Wayland to X11 via `raspi-config`
2. Configure VNC virtual display startup (`~/.vnc/xstartup`)
3. Enable systemd services and hardware watchdog
4. Deploy via `systemctl enable` and reboot

Full configuration details are documented in the source files.

## License

MIT License. Copyright (c) 2026 Michael Pentz.
