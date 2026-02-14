#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="$PROJECT_ROOT/bin/legcord"
LOG_FILE="/tmp/legcord_health.log"

check_legcord() {
    if ! pgrep -f "Legcord" > /dev/null; then
        echo "$(date): Legcord not running, restarting..." | tee -a "$LOG_FILE"
        /bin/bash "$PROJECT_ROOT/scripts/start.sh" >> "$LOG_FILE" 2>&1
    fi
}

check_xvfb() {
    if ! pgrep -f "Xvfb" > /dev/null; then
        echo "$(date): Xvfb not running, restarting..." | tee -a "$LOG_FILE"
        /bin/bash "$PROJECT_ROOT/scripts/start.sh" >> "$LOG_FILE" 2>&1
    fi
}

check_legcord
check_xvfb
