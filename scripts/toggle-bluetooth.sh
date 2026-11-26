#!/usr/bin/env bash
set -Eeuo pipefail
if bluetoothctl show | grep -q 'Powered: yes'; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
