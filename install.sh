#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing packages..."
sudo pacman -S --needed --noconfirm i3-wm polybar rofi picom feh alacritty thunar gvfs thunar-archive-plugin file-roller python-pillow brightnessctl networkmanager pavucontrol i3lock ttf-jetbrains-mono-nerd git chromium satty maim slop xclip xf86-input-libinput tk lightdm lightdm-gtk-greeter

echo "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

FILES=(
  .config/i3/config
  .config/polybar/config.ini
  .config/polybar/theme-colors.ini
  .config/polybar/launch.sh
  .config/polybar/scripts/wifi-menu.sh
  .config/polybar/scripts/power-menu.sh
  .config/rofi/config.rasi
  .config/rofi/wallpaper.rasi
  .config/rofi/colors.rasi
  .config/rofi/theme-colors.rasi
  .config/rofi/ios-spotlight.rasi
  .config/rofi/wallpaper-picker.rasi
  .config/alacritty/alacritty.toml
  .config/alacritty/wallpaper-colors.toml
  .config/picom/picom.conf
  .config/themes/switch-theme.sh
  .local/bin/choose-theme
  .local/bin/choose-wallpaper
  .local/bin/wallpaper-colors
  .local/bin/apply-wallpaper-colors
  .local/bin/screenshot
  .local/bin/set-login-background
)

echo "Copying config files (existing different files are backed up)..."
for f in "${FILES[@]}"; do
  mkdir -p "$HOME/$(dirname "$f")"
  if [ -f "$HOME/$f" ] && ! cmp -s "$DIR/$f" "$HOME/$f"; then
    cp "$HOME/$f" "$HOME/$f.backup-before-install"
  fi
  cp "$DIR/$f" "$HOME/$f"
done

echo "Fixing home paths for this user..."
sed -i "s|/home/[A-Za-z0-9_.-]*|$HOME|g" "$HOME/.config/polybar/config.ini" "$HOME"/.config/polybar/scripts/*.sh "$HOME"/.config/rofi/*.rasi "$HOME/.config/themes/switch-theme.sh" "$HOME/.local/bin/choose-theme" "$HOME/.local/bin/choose-wallpaper"
echo "Making scripts executable..."
chmod +x ~/.config/polybar/launch.sh ~/.config/polybar/scripts/*.sh ~/.config/themes/switch-theme.sh ~/.local/bin/choose-theme ~/.local/bin/choose-wallpaper ~/.local/bin/wallpaper-colors ~/.local/bin/apply-wallpaper-colors ~/.local/bin/screenshot ~/.local/bin/set-login-background

echo "Detecting Wi-Fi interface..."
WIFI="$(ls /sys/class/net | grep -E '^wl' | head -1 || true)"
if [ -n "$WIFI" ] && [ "$WIFI" != "wlan0" ]; then
  sed -i "s/wlan0/$WIFI/g" ~/.config/polybar/config.ini
  echo "Polybar Wi-Fi interface set to $WIFI"
fi

echo "Setting up theme state..."
mkdir -p ~/Pictures/Wallpapers/Christian ~/Pictures/Wallpapers/Sci-fi ~/Pictures/Wallpapers/Motivational
[ -f ~/.config/themes/current ] || echo "Sci-fi" > ~/.config/themes/current
touch ~/.config/themes/wallpaper-colors-on

echo ""
echo "===================================================="
echo "Install finished. A few things you must do yourself:"
echo "1. Connect to Wi-Fi:  nmtui"
echo "2. Add wallpaper images into:"
echo "   ~/Pictures/Wallpapers/Christian"
echo "   ~/Pictures/Wallpapers/Sci-fi"
echo "   ~/Pictures/Wallpapers/Motivational"
echo "3. Log out, choose i3 at the login screen, log in."
echo "===================================================="

echo "Enabling touchpad tap-to-click..."
sudo mkdir -p /etc/X11/xorg.conf.d
if [ ! -f /etc/X11/xorg.conf.d/30-touchpad.conf ]; then
  sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf > /dev/null << EOC
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
    Option "NaturalScrolling" "false"
    Option "ClickMethod" "clickfinger"
EndSection
EOC
  echo "Touchpad config written. Log out and back in for it to apply."
fi

echo "Enabling touchpad tap-to-click..."
sudo mkdir -p /etc/X11/xorg.conf.d
if [ ! -f /etc/X11/xorg.conf.d/30-touchpad.conf ]; then
  sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf > /dev/null << EOC
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
    Option "NaturalScrolling" "false"
    Option "ClickMethod" "clickfinger"
EndSection
EOC
  echo "Touchpad config written. Log out and back in for it to apply."
fi

echo "Installing AUR helper and extra apps..."
if ! command -v yay >/dev/null; then
  sudo pacman -S --needed --noconfirm base-devel git
  rm -rf /tmp/yay-build
  git clone https://aur.archlinux.org/yay.git /tmp/yay-build
  (cd /tmp/yay-build && makepkg -si --noconfirm) || echo "yay build failed"
  rm -rf /tmp/yay-build
fi
if command -v yay >/dev/null; then
  yay -S --needed --noconfirm brave-bin localsend-bin ani-cli || echo "Some AUR packages failed, install them later with yay"
  if [ -f /usr/share/applications/brave-browser.desktop ]; then
    xdg-settings set default-web-browser brave-browser.desktop || true
  fi
else
  echo "yay could not be installed, skipping AUR apps"
fi

echo "Styling the login screen..."
systemctl is-enabled display-manager.service &>/dev/null || sudo systemctl enable lightdm
~/.local/bin/set-login-background || echo "Login background skipped"
