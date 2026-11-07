#!/usr/bin/env bash
# Puts the saved settings back. Existing folders are copied to a backup first.
SRC="$(cd "$(dirname "$0")" && pwd)"
SAFE="$HOME/dotfiles-restore-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$SAFE"

for name in hypr waybar wofi alacritty matugen mako; do
  if [ -d "$SRC/config/$name" ]; then
    [ -d "$HOME/.config/$name" ] && cp -r "$HOME/.config/$name" "$SAFE/"
    mkdir -p "$HOME/.config/$name"
    cp -r "$SRC/config/$name/." "$HOME/.config/$name/"
    echo "restored: ~/.config/$name"
  fi
done

mkdir -p "$HOME/.local/bin"
cp -r "$SRC/bin/." "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"*
echo "restored: ~/.local/bin"

mkdir -p "$HOME/Pictures/Wallpapers/"{christianity,scifi,apocalypse,anime}
echo
echo "Old versions of replaced folders are in: $SAFE"
echo "Still to do by hand: programs, login screen theme, wallpapers (see README.md)."
