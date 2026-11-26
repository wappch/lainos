#!/usr/bin/env bash
verify_installation() {
    local home
    home=$(target_home)
    local -a files=(hypr/hyprland.conf hypr/hypridle.conf hypr/hyprpaper.conf waybar/config waybar/style.css rofi/config.rasi rofi/menu.rasi foot/foot.ini kitty/kitty.conf mako/config)
    local f
    for f in "${files[@]}"; do [[ -s $home/.config/$f ]] || fail "Missing installed config: $f"; done
    [[ -s /usr/share/sddm/themes/lainos-kawaiki/Main.qml ]] || fail 'SDDM theme verification failed.'
    [[ -s /usr/share/wayland-sessions/hyprland.desktop ]] || fail 'Hyprland session verification failed.'
    [[ $(find /usr/share/backgrounds/lainos -type f | wc -l) -eq 9 ]] || fail 'Wallpaper verification failed.'
    systemctl is-enabled sddm.service >/dev/null || fail 'SDDM is not enabled.'
    systemctl is-enabled NetworkManager.service >/dev/null || fail 'NetworkManager is not enabled.'
    info 'PASS: configs, theme assets, wallpaper count, Hyprland session, and service enablement.'
}
report() {
    printf '\n\033[1;32mLainOS installation finished.\033[0m\n'
    printf '  User: %s\n  Theme: original Kawaiki SDDM theme\n  Session: Hyprland\n  Bar/launcher/terminal: original Waybar/Rofi/Foot and Kitty configs\n  Restart: log out or reboot when ready; this installer never reboots automatically.\n' "$TARGET_USER"
}
