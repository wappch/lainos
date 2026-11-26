#!/usr/bin/env bash
install_theme() {
    local source="$VENDOR/sddm-theme/plasma-login-kawaiki" destination=/usr/share/sddm/themes/lainos-kawaiki
    local compatibility_dir
    [[ -s $source/Main.qml && -s $source/metadata.desktop && -s $source/theme.conf ]] || fail 'Original SDDM theme is incomplete.'
    install -d -m 0755 "$destination"
    rsync -a --delete "$source/" "$destination/"
    compatibility_dir=$(mktemp -d /var/tmp/lainos-sddm.XXXXXXXX)
    python "$ROOT/scripts/build-sddm-compat.py" "$source" "$compatibility_dir"
    install -m 0644 "$compatibility_dir/Main.qml" "$destination/Main.qml"
    install -m 0644 "$compatibility_dir/theme.conf" "$destination/theme.conf"
    rm -rf -- "$compatibility_dir"
    local required
    for required in Main.qml Components/LoginForm.qml Components/Clock.qml Assets/User.svgz Backgrounds/background.png theme.conf metadata.desktop COPYING; do
        [[ -s $destination/$required ]] || fail "Missing SDDM theme file: $required"
    done
    info 'Complete upstream Kawaiki SDDM theme installed.'
}
