#!/bin/bash
# Copies your configs into this repo. Run it, then commit.
D="$HOME/dotfiles"
copy() { mkdir -p "$D/$(dirname "$1")" && cp -r "$HOME/$1" "$D/$1" 2>/dev/null; }
copy .config/i3/config
copy .config/polybar/config.ini
copy .config/polybar/theme-colors.ini
copy .config/polybar/launch.sh
copy .config/polybar/scripts/wifi-menu.sh
copy .config/polybar/scripts/power-menu.sh
copy .config/rofi/config.rasi
copy .config/rofi/wallpaper.rasi
copy .config/rofi/colors.rasi
copy .config/rofi/theme-colors.rasi
copy .config/rofi/ios-spotlight.rasi
copy .config/rofi/wallpaper-picker.rasi
copy .config/alacritty/alacritty.toml
copy .config/alacritty/wallpaper-colors.toml
copy .config/picom/picom.conf
copy .config/themes/switch-theme.sh
copy .local/bin/choose-theme
copy .local/bin/choose-wallpaper
copy .local/bin/wallpaper-colors
copy .local/bin/apply-wallpaper-colors
copy .local/bin/screenshot
copy .local/bin/set-login-background
echo "Synced."
