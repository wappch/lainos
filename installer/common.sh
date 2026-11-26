#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=${LAINOS_ROOT:?}
export VENDOR="$ROOT/vendor/Lain-linux-rice"
TARGET_USER=${LAINOS_TARGET_USER:?}

info() { printf '\033[1;36m[ LainOS ]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARNING]\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }
stage() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
banner() {
    printf '\033[1;35m'
    printf '  _       _       ____   _____\n  | | __ _(_)_ __ / ___| / ___/\n  | |/ _` | |  _ \\___ \\| |\n  | | (_| | | | | |___) | |___\n  |_|\\__,_|_|_| |_|____/ \\____|\n'
    printf '\033[0m  LainOS — Arch Linux desktop installer\n'
}

target_entry() {
    getent passwd "$TARGET_USER" || fail "No local account named '$TARGET_USER'."
}
target_home() {
    local entry home uid
    entry=$(target_entry)
    IFS=: read -r _ _ uid _ _ home _ <<<"$entry"
    [[ $uid =~ ^[0-9]+$ && $uid -ne 0 ]] || fail 'Target account resolves to root.'
    [[ $home == /* && $home != / && -d $home ]] || fail "Unsafe or missing home directory: $home"
    home=$(realpath -e -- "$home") || fail 'Could not resolve target home.'
    [[ $home != / && -d $home && $(stat -c %u -- "$home") == "$uid" ]] || fail 'Home directory ownership or path check failed.'
    printf '%s\n' "$home"
}
target_uid() { awk -F: -v u="$TARGET_USER" '$1==u {print $3}' /etc/passwd; }
