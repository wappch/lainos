#!/usr/bin/env python3
"""Generate a portable deployed config while preserving the vendored source."""
from pathlib import Path
import re
import sys

source, target = map(Path, sys.argv[1:3])
lines = source.read_text(encoding="utf-8").splitlines()
out: list[str] = [
    "# LainOS compatibility copy generated from the complete upstream file.",
    "# Upstream stays intact in vendor/Lain-linux-rice/dotfiles/hypr/hyprland.conf.",
]
skip_prefixes = (
    "monitor=",  # preferred mode was a local display assumption
    "exec-once = mpv ",
    "exec-once = [float;",  # fixed window coordinates and sizes
    "exec-once = [workspace 2 silent] librewolf",
    "exec-once = [workspace 3 silent; pseudo; size",
    "exec-once = [workspace 5 silent] spotify",
    "exec-once = bluetoothctl power off",
    "exec-once = apply-gsettings",
    "exec-once=exec xrdb",
    "exec-once = clipse -listen",
    "exec-once = [workspace 4 silent; pseudo; size",
    "bind = $mainMod, CTRL, E, exec, footclient --window-size-pixels=1200x600 sudo yazi",
    "bind = $mainMod SHIFT, G, exec, footclient -e ~/.local/bin/bear/implement_gum.sh enable",
    "bind = $mainMod, I, exec, .local/bin/calamares.sh",
    "misc:vfr = true",
    "bind = ,232,exec,brightnessctl -c backlight set 5%-",
    "bind = ,233,exec,brightnessctl -c backlight set +5%",
    "bind = SUPER, code:60, exec, flatpak run io.github.vemonet.EmojiMart",
    "exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
)
skip_contains = (
    "Garuda", "garuda-", "firedragon", "telegram-desktop", "vesktop", "spotify",
    "github-desktop", "gparted", "inkscape", "blender", "meld", "joplin-desktop",
    "snapper-tools", "galculator", "unimatrix", "tty-clock",
)
for line in lines:
    if line.replace("= ", "=").startswith("exec-once =/usr/lib/polkit-gnome/"):
        continue
    if line.startswith(skip_prefixes) or any(term in line for term in skip_contains):
        continue
    if re.search(r"(?:^|[, ])(?:move|size)\s+\d+\s+\d+", line):
        continue
    if "~/.config/wpaperd/" in line or "brightnessctl -c backlight" in line:
        continue
    if "killall -9 wpaperd" in line:
        continue
    if line.strip() == "misc:vfr = true":
        continue
    if "~/Scripts/rofi-run-on-current-workspace/main.sh" in line:
        line = "bind = $mainMod, X, exec, rofi -show drun"
    elif "exec, nwgbar" in line:
        line = line.split("exec,", 1)[0] + "exec, rofi -show drun"
    elif "bind = $mainMod, B, exec, librewolf" in line:
        line = "bind = $mainMod, B, exec, firefox"
    elif "footclient --window-size-pixels=1200x600 yazi" in line:
        line = line.split("exec,", 1)[0] + "exec, thunar"
    elif "killall waybar || waybar" in line:
        line = line.replace("killall waybar", "pkill waybar")
    elif "bind = SUPER, V, exec, pkill clipse" in line:
        line = 'bind = SUPER, V, exec, sh -c "cliphist list | rofi -dmenu | cliphist decode | wl-copy"'
    elif line.strip() == "exec-once = mako":
        out.append("exec-once = mako")
        out.append("exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
        continue
    out.append(line)
out.extend([
    "",
    "# LainOS wallpaper launcher (all upstream image names are preserved).",
    'bind = $mainMod, W, exec, hyprctl hyprpaper wallpaper \\,"/usr/share/backgrounds/lainos/wallpapers and backgrounds/empty-Lain.png"',
])
target.write_text("\n".join(out) + "\n", encoding="utf-8")
