#!/usr/bin/env bash
preflight() {
    [[ -r /etc/arch-release ]] || fail 'This installer supports Arch Linux only.'
    [[ $(uname -m) == x86_64 ]] || fail 'This package targets x86_64.'
    local tool
    for tool in pacman systemctl getent realpath sha256sum timeout; do
        command -v "$tool" >/dev/null 2>&1 || fail "Required system tool is missing: $tool"
    done
    target_entry >/dev/null
    local home
    home=$(target_home)
    [[ -d $VENDOR && -s $VENDOR/README.md ]] || fail 'Bundled upstream repository is incomplete.'
    timeout 15 bash -c 'exec 3<>/dev/tcp/archlinux.org/443' || fail 'Internet connectivity check failed.'
    [[ -f $ROOT/checksums/original-source.sha256 ]] || fail 'Original source checksum manifest is missing.'
    (cd "$VENDOR" && sha256sum --check --quiet "$ROOT/checksums/original-source.sha256") || fail 'Upstream source checksum verification failed.'
    info "Arch Linux x86_64, internet, tools, and original source verified. Target: $TARGET_USER ($home)"
}
