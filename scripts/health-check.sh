#!/bin/bash

INSTALL_DIR="/home/schiggity/legcord"
LOG_FILE="/var/log/legcord_health.log"

check_legcord() {
    if ! pgrep -f "Legcord" > /dev/null; then
        echo "$(date): Legcord not running, restarting..." | tee -a "$LOG_FILE"
        /bin/bash "$INSTALL_DIR/../scripts/start.sh" >> "$LOG_FILE" 2>&1
    fi
}

check_xvfb() {
    if ! pgrep -f "Xvfb" > /dev/null; then
        echo "$(date): Xvfb not running, restarting..." | tee -a "$LOG_FILE"
        /bin/bash "$INSTALL_DIR/../scripts/start.sh" >> "$LOG_FILE" 2>&1
    fi
}

check_legcord
check_xvfb
