#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
export LAINOS_ROOT=$ROOT

die() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }
if (( EUID != 0 )); then
    command -v sudo >/dev/null 2>&1 || die 'Run as a regular user with sudo installed.'
    exec sudo bash "$ROOT/install.sh" "$@"
fi

TARGET_USER=${LAINOS_TARGET_USER:-${SUDO_USER:-}}
[[ -n $TARGET_USER && $TARGET_USER != root ]] || die 'Run from the intended regular user account (sudo ./install.sh). Root installs are refused.'
export LAINOS_TARGET_USER=$TARGET_USER

source "$ROOT/installer/common.sh"
source "$ROOT/installer/preflight.sh"
source "$ROOT/installer/packages.sh"
source "$ROOT/installer/install-desktop.sh"
source "$ROOT/installer/install-themes.sh"
source "$ROOT/installer/install-wallpapers.sh"
source "$ROOT/installer/install-fonts.sh"
source "$ROOT/installer/install-sddm.sh"
source "$ROOT/installer/install-dotfiles.sh"
source "$ROOT/installer/configure-services.sh"
source "$ROOT/installer/verify.sh"

trap 'fail "Installation stopped at line $LINENO. Read the message above."' ERR
banner
stage 'Preflight checks'
preflight
stage 'Install desktop packages'
warn 'The package stage performs a full Arch Linux update (pacman -Syu) before installing the desktop dependencies.'
install_packages
stage 'Install original visual assets and SDDM theme'
install_desktop_assets
stage 'Prepare full LainOS configuration'
prepare_config_tree
stage 'Replace target configuration'
replace_target_config
stage 'Configure system services and login'
configure_services
stage 'Verify installation'
verify_installation
report
