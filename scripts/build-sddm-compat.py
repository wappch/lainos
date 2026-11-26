#!/usr/bin/env python3
"""Make the upstream Kawaiki theme follow the active display size."""
from pathlib import Path
import sys

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
destination.mkdir(parents=True, exist_ok=True)
main = (source / "Main.qml").read_text(encoding="utf-8")
if main.count("Screen.ScreenWidth") != 1:
    raise SystemExit("Unexpected upstream QML width expression; refusing an unreviewed rewrite")
main = main.replace("Screen.ScreenWidth", "Screen.width")
(destination / "Main.qml").write_text(main, encoding="utf-8")
theme = (source / "theme.conf").read_text(encoding="utf-8").splitlines()
theme = [line for line in theme if not line.startswith(("ScreenWidth=", "ScreenHeight="))]
(destination / "theme.conf").write_text("\n".join(theme) + "\n", encoding="utf-8")
