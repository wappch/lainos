# LainOS

LainOS installs the upstream [Lain Linux Rice](https://github.com/FlexUnder/Lain-linux-rice) desktop files and original art on a fresh Arch Linux Minimal x86_64 system. It is an installer package, not an ISO or a distribution. The complete cloned repository is preserved under `vendor/Lain-linux-rice/`; its source checksum manifest is in `checksums/original-source.sha256`.

## Requirements

- Fresh, bootable Arch Linux Minimal x86_64 with a regular user account.
- Working internet and `sudo` access.
- At least 3 GB free space for the package set and font files.
- Run from the intended user's account, not from a root shell.

## Install

Unzip the archive, then run:

```sh
cd LainOS
chmod +x install.sh
./install.sh
```

The installer checks Arch and x86_64, verifies the source checksums, refreshes and fully upgrades the Arch package database/system with `pacman -Syu`, checks each package against the enabled official repositories, installs the packages and assets, stages all configuration, then asks for the exact text `DELETE /home/your-user/.config` before replacing that directory. Enter the path shown by the installer. It does not reboot automatically.

**Configuration replacement warning:** installation permanently removes the target user's entire `~/.config` directory and replaces it with LainOS configuration. It does not create backups, merge files, or preserve old `~/.config` contents. Other home folders such as Documents, Downloads, Pictures, Videos, Desktop, browser profiles outside `~/.config`, and passwords outside `~/.config` are not removed. The installer validates the account, home ownership, and `.config` path before removal. It refuses root and symlinked `.config` paths.

After installation, log out or reboot when ready. SDDM is enabled as the graphical login manager and the default boot target becomes `graphical.target`. A TTY login remains available if the graphical session cannot start.

## Included desktop

- Full upstream Hyprland rules and keybinds, with a portable Arch compatibility copy at install time.
- Original Waybar config and stylesheet; device-specific Intel backlight, battery, and temperature modules are omitted in the deployed version.
- Original Rofi themes, with the installed Papirus icon set.
- Original Kitty and Foot colors; Fish color files and Fish shell.
- Hyprpaper wallpaper manager with all nine upstream images installed beneath `/usr/share/backgrounds/lainos/`.
- Hypridle and a Lain wallpaper Hyprlock setup, Mako notifications, Thunar, Hyprland desktop portals, clipboard tools, screenshots, PipeWire audio, NetworkManager, and Bluetooth.
- Firefox as the official repository browser replacing the upstream Librewolf launch shortcut.
- The actual upstream `plasma-login-kawaiki` SDDM theme, installed as `lainos-kawaiki`, plus its original QML, SVG, preview and background assets. Its Qt 5 virtual keyboard is enabled.

The upstream repository does not contain standalone GTK themes, cursor themes, icon packs, or font files. LainOS installs Papirus icons and JetBrains Mono Nerd Font from Arch's official repositories for the upstream configs' glyphs; it does not claim these are upstream assets. The deployed SDDM compatibility copy removes the upstream 1920×1080 override and corrects its width fallback so it uses the actual display dimensions; the vendored theme is unchanged.

Some original startup commands reference Garuda-only utilities, external programs, missing videos, fixed screen coordinates, and a specific Intel backlight. Those active incompatible settings are omitted from the deployed compatibility copies. The original files remain byte-for-byte represented by the vendored source and checksum. The unused `clipse` config and original scripts remain in the project; clipboard actions use the official `cliphist` and Rofi packages.

## Shortcuts

- `Super+Enter` or `Super+T`: terminal
- `Super+X`: application launcher
- `Super+E`: file manager
- `Super+V`: clipboard history
- `Super+Q`: close active window
- `Super+Shift+R`: reload Hyprland
- `Print`: select and capture an area; `Ctrl+Print` captures a window; `Shift+Print` captures the focused output
- `Super+1` through `Super+0`: switch workspaces

The original complete keybind list is in `vendor/Lain-linux-rice/dotfiles/hypr/hyprland.conf`; installed compatibility adjustments are in `scripts/build-hyprland-compat.py`.

## Packages and services

`packages/arch-official.txt` is the explicit dependency manifest. It includes Hyprland/SDDM/Waybar/Rofi/Foot/Kitty, wallpaper/lock/idle/notification components, Thunar, PipeWire, NetworkManager, BlueZ/Blueman, screenshots, clipboard, Qt 5 QML imports needed by the original theme, fonts, and icons. The installer fails if any listed name is unavailable in the enabled official repos. No AUR packages are used. NetworkManager and Bluetooth are enabled; PipeWire user sockets/services are enabled globally. SDDM is enabled only after its theme and session are verified.

## Troubleshooting

- If SDDM does not appear, use a TTY and check `systemctl status sddm` and `journalctl -u sddm -b`. The Hyprland session is installed at `/usr/share/wayland-sessions/hyprland.desktop`.
- If the SDDM theme fails, check `/etc/sddm.conf.d/10-lainos.conf`, `/usr/share/sddm/themes/lainos-kawaiki/`, and Qt 5 QML import packages from the manifest.
- If the wallpaper does not appear, check `~/.config/hypr/hyprpaper.conf` and that the files exist under `/usr/share/backgrounds/lainos/wallpapers and backgrounds/`.
- If Waybar or Rofi reports a config issue, run `waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css` and `rofi -show drun` from a Hyprland terminal.
- Package downloads require a working connection and current Arch mirrors. The installer performs a full system update because Arch does not support partial upgrades.

## Uninstall

Run `sudo ./uninstall.sh` from the intended user account and type `REMOVE LAINOS`. It removes the entire target `~/.config`, the LainOS SDDM theme/config, and installed wallpaper assets. It disables SDDM and returns `graphical.target` to `multi-user.target` when applicable. It leaves installed packages and NetworkManager/Bluetooth services in place. The same `~/.config` deletion warning applies.

## Validation and limits

Run `tests/run.sh` for shell/Python syntax, generated Waybar JSON, portable Hyprland checks, SDDM/wallpaper file checks, source checksum verification, and a disposable-home configuration replacement test. ShellCheck is run separately and currently reports no findings in LainOS installer scripts; retained upstream shell files have the findings expected in untouched upstream source. A clean Arch VM and graphical screenshot checks are not available in this build environment. Runtime parser and visual behavior must be checked on the target Arch system.

## Credits and license

All upstream visual assets, configs, and theme authorship remain credited in the repository README and the included SDDM theme `AUTHORS`, `CREDITS`, and `COPYING` files. The upstream repository has no root-level license file in the cloned revision; the SDDM theme carries its own license. LainOS integration scripts and compatibility files are provided under the MIT license in `LICENSE`.
