# dotfiles

My Arch Linux + i3 desktop: Polybar, Rofi, Picom, Alacritty, with colors that can follow the wallpaper.

## Install on a fresh Arch + i3 system

    sudo pacman -S --needed git
    git clone https://github.com/tzmar/dotfiles.git
    cd dotfiles && ./install.sh

The script installs the packages, copies the configs (backing up anything it replaces), and detects your Wi-Fi interface.

## After installing

1. Connect to Wi-Fi with `nmtui`.
2. Put wallpapers in `~/Pictures/Wallpapers/Christian`, `Sci-fi` and `Motivational`.
3. Log out and start i3.

## Keybinds

- Super + Space: app launcher
- Super + T: theme switcher
- Super + Ctrl + Space: wallpaper picker (bar, launcher and terminal colors follow the image)
- Super + Shift + F: file manager
- Super + B: browser
- Super + Shift + E: power menu
- Print Screen: screenshot with editor

To turn off wallpaper-based colors, delete `~/.config/themes/wallpaper-colors-on`.

## Updating this repo from my machine

    ~/dotfiles/sync.sh && cd ~/dotfiles && git add -A && git commit -m "Update" && git push
