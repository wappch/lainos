#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if (( EUID != 0 )); then
    command -v sudo >/dev/null 2>&1 || { echo 'Run as a regular user with sudo.' >&2; exit 1; }
    exec sudo bash "$ROOT/uninstall.sh" "$@"
fi
user=${LAINOS_TARGET_USER:-${SUDO_USER:-}}
[[ -n $user && $user != root ]] || { echo 'Run from the intended regular user account (sudo ./uninstall.sh).' >&2; exit 1; }
entry=$(getent passwd "$user") || { echo "Unknown user: $user" >&2; exit 1; }
IFS=: read -r _ _ uid _ _ home _ <<<"$entry"
home=$(realpath -e -- "$home")
[[ $uid != 0 && $home != / && -d $home && $(stat -c %u -- "$home") == "$uid" && ! -L $home/.config ]] || { echo 'Unsafe target home or ~/.config path; refusing.' >&2; exit 1; }
printf 'This removes the entire %s/.config directory and LainOS system assets. Type REMOVE LAINOS to continue: ' "$home"
IFS= read -r answer
[[ $answer == 'REMOVE LAINOS' ]] || { echo 'Uninstall cancelled.'; exit 1; }
rm -rf -- "$home/.config"
rm -rf -- /usr/share/sddm/themes/lainos-kawaiki /usr/share/backgrounds/lainos
rm -f -- /etc/sddm.conf.d/10-lainos.conf
systemctl disable sddm.service || true
if [[ $(systemctl get-default) == graphical.target ]]; then systemctl set-default multi-user.target; fi
printf 'LainOS configuration and visual assets were removed. Installed packages and NetworkManager/Bluetooth services were left in place.\n'
