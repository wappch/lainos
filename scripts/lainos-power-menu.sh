#!/usr/bin/env bash
set -Eeuo pipefail
choice=$(printf '%s\n' Lock 'Log out' Suspend Reboot 'Power off' | rofi -dmenu -i -p 'Power') || exit 0
case "$choice" in
    Lock) hyprlock ;;
    'Log out') hyprctl dispatch exit ;;
    Suspend) systemctl suspend ;;
    Reboot) systemctl reboot ;;
    'Power off') systemctl poweroff ;;
    *) exit 0 ;;
esac
