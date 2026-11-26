# Minimal Arch-compatible shell startup. Upstream fish color files and variables
# are installed alongside this file; Garuda-only aliases are intentionally omitted.
set fish_greeting
if test -d ~/.local/bin; and not contains -- ~/.local/bin $PATH
    set -p PATH ~/.local/bin
end
