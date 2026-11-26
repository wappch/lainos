#!/usr/bin/env bash
write_sddm_config() {
    install -d -m 0755 /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/10-lainos.conf <<'EOF'
[General]
InputMethod=qtvirtualkeyboard

[Theme]
Current=lainos-kawaiki
EOF
    [[ -s /usr/share/sddm/themes/lainos-kawaiki/Main.qml ]] || fail 'SDDM theme was not installed before selecting it.'
    [[ -s /usr/share/wayland-sessions/hyprland.desktop ]] || fail 'Hyprland login session is not installed.'
}
