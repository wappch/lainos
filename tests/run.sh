#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$ROOT"
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

for script in install.sh uninstall.sh installer/*.sh tests/*.sh scripts/*.sh; do bash -n "$script"; done
while IFS= read -r -d '' script; do bash -n "$script"; done < <(find vendor/Lain-linux-rice -type f -name '*.sh' -print0)
python - <<'PY'
from pathlib import Path
for script in (Path("scripts/build-hyprland-compat.py"), Path("scripts/build-waybar-compat.py"), Path("scripts/build-sddm-compat.py")):
    compile(script.read_text(encoding="utf-8"), str(script), "exec")
PY
python scripts/build-waybar-compat.py vendor/Lain-linux-rice/dotfiles/waybar/config "$tmp/waybar.json"
python -m json.tool "$tmp/waybar.json" >/dev/null
python scripts/build-hyprland-compat.py vendor/Lain-linux-rice/dotfiles/hypr/hyprland.conf "$tmp/hyprland.conf"
python scripts/build-sddm-compat.py vendor/Lain-linux-rice/sddm-theme/plasma-login-kawaiki "$tmp/sddm"
if grep -Eq '^[[:space:]]*monitor=|intel_backlight|brightnessctl -c backlight|/home/flexander|Garuda|garuda-' "$tmp/hyprland.conf"; then
    echo 'Hardware-specific or author-specific active Hyprland configuration found.' >&2; exit 1
fi
if grep -Eq '"(backlight|battery|temperature|custom/crypto)"[[:space:]]*:' "$tmp/waybar.json"; then
    echo 'Hardware-specific Waybar module remains enabled.' >&2; exit 1
fi
[[ $(find 'vendor/Lain-linux-rice/wallpapers and backgrounds' -type f | wc -l) -eq 9 ]]
for file in Main.qml Components/LoginForm.qml Components/VirtualKeyboard.qml Backgrounds/background.png Assets/User.svgz theme.conf metadata.desktop COPYING; do
    [[ -s vendor/Lain-linux-rice/sddm-theme/plasma-login-kawaiki/$file ]]
done
grep -q 'width: config.ScreenWidth || Screen.width' "$tmp/sddm/Main.qml"
if grep -Eq '^Screen(Width|Height)=' "$tmp/sddm/theme.conf"; then
    echo 'Fixed display size remains in generated SDDM theme.' >&2; exit 1
fi
python - <<'PY'
import re
from pathlib import Path
manifest = {line.strip() for line in Path("packages/arch-official.txt").read_text().splitlines() if line.strip() and not line.startswith("#")}
theme = Path("vendor/Lain-linux-rice/sddm-theme/plasma-login-kawaiki")
imports = set()
for qml in theme.rglob("*.qml"):
    imports.update(re.findall(r"^import ([A-Za-z][\w.]*)\s", qml.read_text(encoding="utf-8"), re.M))
required = {
    "QtQuick": "qt5-declarative",
    "QtQuick.Layouts": "qt5-declarative",
    "QtQuick.Controls": "qt5-quickcontrols2",
    "QtQuick.VirtualKeyboard": "qt5-virtualkeyboard",
    "QtGraphicalEffects": "qt5-graphicaleffects",
    "SddmComponents": "sddm",
}
for module in imports:
    if module not in required:
        raise SystemExit(f"Unmapped SDDM QML import: {module}")
    if required[module] not in manifest:
        raise SystemExit(f"Missing package for SDDM QML import {module}: {required[module]}")
background = theme / "Backgrounds/background.png"
assert background.is_file()
assert all(package in manifest for package in required.values())
assert "InputMethod=qtvirtualkeyboard" in Path("installer/install-sddm.sh").read_text()
PY

# Exercise the actual replacement function against a disposable mock home.
export LAINOS_ROOT=$ROOT
LAINOS_TARGET_USER=$(id -un)
export LAINOS_TARGET_USER
source installer/common.sh
source installer/install-dotfiles.sh
test_home="$tmp/home"
mkdir -p "$test_home/.config" "$test_home/Documents"
printf old > "$test_home/.config/old-file"
printf keep > "$test_home/Documents/keep-file"
PREPARED_HOME=$test_home
PREPARED_CONFIG="$tmp/new-config"
mkdir -p "$PREPARED_CONFIG"
printf new > "$PREPARED_CONFIG/lainos-file"
target_home() { printf '%s\n' "$PREPARED_HOME"; }
target_uid() { printf '12345\n'; }
rsync() { cp -a "$3"/. "$4"/; }
chown() { :; }
export PREPARED_HOME PREPARED_CONFIG
printf 'DELETE %s/.config\n' "$test_home" | replace_target_config >/dev/null
[[ ! -e $test_home/.config/old-file && -s $test_home/.config/lainos-file ]]
[[ -s $test_home/Documents/keep-file ]]
[[ $(find "$test_home" -maxdepth 1 -type d -name '*backup*' | wc -l) -eq 0 ]]

(cd vendor/Lain-linux-rice && sha256sum --check --quiet "$ROOT/checksums/original-source.sha256")
echo 'PASS: Bash/Python syntax, generated config validation, upstream asset checks, source checksum, and config replacement isolation.'
