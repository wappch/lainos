#!/usr/bin/env bash
configure_services() {
    write_sddm_config
    systemctl enable NetworkManager.service
    systemctl enable bluetooth.service
    systemctl --global enable pipewire.socket pipewire-pulse.socket wireplumber.service
    systemctl set-default graphical.target
    systemctl enable sddm.service
    info 'NetworkManager, Bluetooth, PipeWire user services, graphical boot, and SDDM are configured. No reboot or graphical-session stop was triggered.'
}
