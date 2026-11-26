#!/usr/bin/env bash
prepare_config_tree() {
    local home
    home=$(target_home)
    PREPARED_CONFIG=$(mktemp -d /var/tmp/lainos-config.XXXXXXXX)
    export PREPARED_CONFIG
    install -d "$PREPARED_CONFIG"/{hypr,mako,neofetch,rofi,waybar,foot,kitty,fish,clipse}
    rsync -a "$VENDOR/dotfiles/hypr/" "$PREPARED_CONFIG/hypr/"
    rsync -a "$VENDOR/dotfiles/mako/" "$PREPARED_CONFIG/mako/"
    rsync -a "$VENDOR/dotfiles/neofetch/" "$PREPARED_CONFIG/neofetch/"
    rsync -a "$VENDOR/dotfiles/rofi/" "$PREPARED_CONFIG/rofi/"
    rsync -a "$VENDOR/dotfiles/waybar/" "$PREPARED_CONFIG/waybar/"
    rsync -a "$VENDOR/dotfiles/clipse/" "$PREPARED_CONFIG/clipse/"
    rsync -a "$VENDOR/terminal-colors/foot/" "$PREPARED_CONFIG/foot/"
    rsync -a "$VENDOR/terminal-colors/kitty/" "$PREPARED_CONFIG/kitty/"
    rsync -a "$VENDOR/terminal-colors/fish/" "$PREPARED_CONFIG/fish/"
    python "$ROOT/scripts/build-hyprland-compat.py" "$VENDOR/dotfiles/hypr/hyprland.conf" "$PREPARED_CONFIG/hypr/hyprland.conf"
    python "$ROOT/scripts/build-waybar-compat.py" "$VENDOR/dotfiles/waybar/config" "$PREPARED_CONFIG/waybar/config"
    sed -i 's/FiraCode Nerd Font/JetBrainsMono Nerd Font/g; s/, "cryptofont"//g; s/, cryptofont//g' "$PREPARED_CONFIG/waybar/style.css"
    install -m 0644 "$ROOT/configs/compat/hyprpaper.conf" "$PREPARED_CONFIG/hypr/hyprpaper.conf"
    install -m 0644 "$ROOT/configs/compat/hypridle.conf" "$PREPARED_CONFIG/hypr/hypridle.conf"
    install -m 0644 "$ROOT/configs/compat/hyprlock.conf" "$PREPARED_CONFIG/hypr/hyprlock.conf"
    install -m 0644 "$ROOT/configs/compat/rofi-config.rasi" "$PREPARED_CONFIG/rofi/config.rasi"
    install -m 0644 "$ROOT/configs/compat/foot.ini" "$PREPARED_CONFIG/foot/foot.ini"
    install -m 0644 "$ROOT/configs/compat/fish-config.fish" "$PREPARED_CONFIG/fish/config.fish"
    sed -i 's/^font_family[[:space:]].*/font_family JetBrainsMono Nerd Font/' "$PREPARED_CONFIG/kitty/kitty.conf"
    cat > "$PREPARED_CONFIG/waybar/scripts/bluetooth-widget/panel.sh" <<'EOF'
#!/usr/bin/env bash
exec blueman-manager
EOF
    chmod 0755 "$PREPARED_CONFIG/waybar/scripts/bluetooth-widget/panel.sh"
    install -m 0755 "$ROOT/scripts/lainos-power-menu.sh" "$PREPARED_CONFIG/waybar/scripts/shutdown/main.sh"
    install -m 0755 "$ROOT/scripts/toggle-bluetooth.sh" "$PREPARED_CONFIG/waybar/scripts/bluetooth-widget/mode.sh"
    cat > "$PREPARED_CONFIG/waybar/scripts/volume-widget/main.sh" <<'EOF'
#!/usr/bin/env bash
if pgrep -x pavucontrol >/dev/null; then
    pkill -x pavucontrol
else
    pavucontrol
fi
EOF
    chmod 0755 "$PREPARED_CONFIG/waybar/scripts/volume-widget/main.sh"
    [[ -s $PREPARED_CONFIG/hypr/hyprland.conf && -s $PREPARED_CONFIG/waybar/config && -s $PREPARED_CONFIG/rofi/menu.rasi ]] || fail 'Prepared desktop configuration is incomplete.'
    PREPARED_HOME=$home
    export PREPARED_HOME
    info 'Complete upstream config trees copied to a staging directory; compatibility files applied.'
}

replace_target_config() {
    local home answer
    home=$(target_home)
    [[ $home == "$PREPARED_HOME" ]] || fail 'Target home changed after staging; refusing to remove configuration.'
    [[ -d $PREPARED_CONFIG && ! -L $home/.config ]] || fail 'Staged config missing or target ~/.config is a symlink; refusing unsafe replacement.'
    warn "This will permanently remove $home/.config and replace all of it with LainOS configuration. No backup or merge is made."
    printf 'Type DELETE %s/.config to continue: ' "$home"
    IFS= read -r answer
    [[ $answer == "DELETE $home/.config" ]] || fail 'Configuration replacement was not confirmed.'
    [[ $(target_home) == "$home" && ! -L $home/.config ]] || fail 'Target home or ~/.config path changed; refusing unsafe replacement.'
    rm -rf -- "$home/.config"
    install -d -m 0755 "$home/.config"
    rsync -a --delete "$PREPARED_CONFIG/" "$home/.config/"
    chown -R "$TARGET_USER:$(id -gn "$TARGET_USER")" "$home/.config"
    rm -rf -- "$PREPARED_CONFIG"
    unset PREPARED_CONFIG
    info 'Old ~/.config was removed; the fresh LainOS configuration is installed.'
}
