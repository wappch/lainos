#!/usr/bin/env bash
install_wallpapers() {
    local destination=/usr/share/backgrounds/lainos
    install -d -m 0755 "$destination"
    rsync -a --delete "$VENDOR/wallpapers and backgrounds/" "$destination/wallpapers and backgrounds/"
    [[ $(find "$destination/wallpapers and backgrounds" -type f | wc -l) -eq 9 ]] || fail 'Wallpaper asset count does not match the upstream source.'
    info 'All nine original wallpaper and background images installed with their names preserved.'
}
