#!/bin/bash
set -e

echo "Installing packages..."
sudo pacman -S --needed --noconfirm i3-wm polybar rofi picom feh alacritty thunar gvfs thunar-archive-plugin file-roller python-pillow brightnessctl networkmanager

echo "Copying config files..."
mkdir -p ~/.config/i3 ~/.config/polybar/scripts ~/.config/rofi ~/.config/alacritty ~/.config/picom ~/.config/themes ~/.local/bin

cp ~/dotfiles/.config/i3/config ~/.config/i3/config
cp ~/dotfiles/.config/polybar/config.ini ~/.config/polybar/config.ini
cp ~/dotfiles/.config/polybar/launch.sh ~/.config/polybar/launch.sh
cp ~/dotfiles/.config/polybar/scripts/wifi-menu.sh ~/.config/polybar/scripts/wifi-menu.sh
cp ~/dotfiles/.config/polybar/scripts/power-menu.sh ~/.config/polybar/scripts/power-menu.sh
cp ~/dotfiles/.config/rofi/config.rasi ~/.config/rofi/config.rasi
cp ~/dotfiles/.config/rofi/wallpaper.rasi ~/.config/rofi/wallpaper.rasi
cp ~/dotfiles/.config/rofi/colors.rasi ~/.config/rofi/colors.rasi
cp ~/dotfiles/.config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp ~/dotfiles/.config/alacritty/wallpaper-colors.toml ~/.config/alacritty/wallpaper-colors.toml
cp ~/dotfiles/.config/picom/picom.conf ~/.config/picom/picom.conf
cp ~/dotfiles/.config/themes/switch-theme.sh ~/.config/themes/switch-theme.sh
cp ~/dotfiles/.local/bin/choose-theme ~/.local/bin/choose-theme
cp ~/dotfiles/.local/bin/choose-wallpaper ~/.local/bin/choose-wallpaper
cp ~/dotfiles/.local/bin/wallpaper-colors ~/.local/bin/wallpaper-colors
cp ~/dotfiles/.local/bin/apply-wallpaper-colors ~/.local/bin/apply-wallpaper-colors

echo "Making scripts executable..."
chmod +x ~/.config/polybar/launch.sh ~/.config/polybar/scripts/*.sh ~/.config/themes/switch-theme.sh ~/.local/bin/choose-theme ~/.local/bin/choose-wallpaper ~/.local/bin/wallpaper-colors ~/.local/bin/apply-wallpaper-colors

echo "Done! Log out and start i3 to see your setup."
