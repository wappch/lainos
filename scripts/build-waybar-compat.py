#!/usr/bin/env python3
"""Keep upstream Waybar styling while removing device-specific modules."""
import json
import re
import sys
from pathlib import Path

raw = Path(sys.argv[1]).read_text(encoding="utf-8")
# Upstream file uses JSONC comments and trailing commas.
def strip_comments(text: str) -> str:
    result, i, quoted, escaped, comment = [], 0, False, False, False
    while i < len(text):
        ch = text[i]
        if comment:
            if ch == "\n":
                comment = False
                result.append(ch)
            i += 1
            continue
        if quoted:
            result.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                quoted = False
            i += 1
            continue
        if ch == '"':
            quoted = True
            result.append(ch)
            i += 1
            continue
        if ch == "/" and i + 1 < len(text) and text[i + 1] == "/":
            comment = True
            i += 2
            continue
        result.append(ch)
        i += 1
    return "".join(result)

raw = strip_comments(raw)
raw = re.sub(r",\s*([}\]])", r"\1", raw)
data = json.loads(raw)
for bar in data:
    bar["modules-right"] = [m for m in bar.get("modules-right", []) if m not in {"backlight", "battery"}]
    for key in ("modules-left", "modules-center", "modules-right"):
        if key in bar:
            bar[key] = [m for m in bar[key] if m != "custom/crypto"]
    for group in ("group/performance",):
        if group in bar and "modules" in bar[group]:
            bar[group]["modules"] = [m for m in bar[group]["modules"] if m != "temperature"]
    for module in ("backlight", "battery", "temperature", "custom/crypto"):
        bar.pop(module, None)
    for module in ("custom/power", "wireplumber", "bluetooth", "custom/view-mode"):
        entry = bar.get(module)
        if not entry:
            continue
        if module == "custom/power":
            entry["on-click"] = "bash ~/.config/waybar/scripts/shutdown/main.sh"
        elif module == "wireplumber":
            entry["on-click"] = "bash ~/.config/waybar/scripts/volume-widget/main.sh"
        elif module == "bluetooth":
            entry["on-click"] = "bash ~/.config/waybar/scripts/bluetooth-widget/panel.sh"
            entry["on-click-right"] = "bash ~/.config/waybar/scripts/bluetooth-widget/mode.sh"
        elif module == "custom/view-mode":
            entry["exec"] = "python ~/.config/waybar/scripts/view-mode-widget/main.py"
    updates = bar.get("custom/updates", {})
    updates.pop("on-click-right", None)  # Garuda-specific updater
    if "custom/updates" in bar:
        bar["custom/updates"]["exec-if"] = "false"
    if "custom/notification" in bar:
        bar["custom/notification"]["exec-if"] = "false"
Path(sys.argv[2]).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
