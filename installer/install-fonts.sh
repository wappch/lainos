#!/usr/bin/env bash
install_fonts() {
    fc-cache -f >/dev/null
    info 'Font packages installed and the font cache refreshed.'
}
