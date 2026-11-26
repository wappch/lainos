#!/usr/bin/env bash
install_packages() {
    local -a packages missing
    mapfile -t packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$ROOT/packages/arch-official.txt")
    ((${#packages[@]} > 0)) || fail 'Package manifest is empty.'
    pacman -Syu --noconfirm
    missing=()
    local pkg
    for pkg in "${packages[@]}"; do
        pacman -Si "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    ((${#missing[@]} == 0)) || fail "Packages unavailable in enabled official repositories: ${missing[*]}"
    info 'Official repository package names verified.'
    pacman -S --needed --noconfirm "${packages[@]}"
}
