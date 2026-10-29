#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
warn() { echo "WARNING: $*"; }

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not root."
  exit 1
fi

echo "== 1/8 Core packages =="
sudo pacman -S --needed --noconfirm \
  xorg-server xorg-xinit xorg-xinput xf86-input-libinput \
  i3-wm i3lock xss-lock polybar rofi picom feh alacritty \
  thunar gvfs thunar-archive-plugin file-roller \
  python-pillow tk brightnessctl pavucontrol \
  networkmanager network-manager-applet \
  maim slop xclip satty \
  ttf-jetbrains-mono-nerd noto-fonts \
  lightdm lightdm-gtk-greeter \
  git base-devel unrar unzip xdg-utils bluez bluez-utils

echo "== 2/8 Audio and extras (a failure here only warns) =="
sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber libpulse pamixer playerctl \
  || warn "audio packages failed (an older pulseaudio may be installed)"
sudo pacman -S --needed --noconfirm chromium mpv imagemagick bluez bluez-utils fzf htop \
  || warn "some extra packages failed"

echo "== 3/8 Services =="
other=0
for s in systemd-networkd iwd; do
  if systemctl is-enabled "$s" &>/dev/null; then other=1; fi
done
if [ "$other" = 0 ]; then
  sudo systemctl enable NetworkManager
else
  echo "Another network service is enabled, leaving networking alone."
fi
systemctl is-enabled display-manager.service &>/dev/null || sudo systemctl enable lightdm
command -v bluetoothctl >/dev/null && sudo systemctl enable bluetooth || true

echo "== 4/8 AUR apps (yay) =="
if ! command -v yay >/dev/null; then
  rm -rf /tmp/yay-build
  if git clone https://aur.archlinux.org/yay.git /tmp/yay-build; then
    (cd /tmp/yay-build && makepkg -si --noconfirm) || warn "yay build failed"
  else
    warn "could not download yay"
  fi
  rm -rf /tmp/yay-build
fi
if command -v yay >/dev/null; then
  yay -S --needed --noconfirm brave-bin localsend-bin || warn "Brave or LocalSend failed, install later with: yay -S brave-bin localsend-bin"
  yay -S --needed --noconfirm ani-cli || warn "ani-cli skipped"
  [ -f /usr/share/applications/brave-browser.desktop ] && xdg-settings set default-web-browser brave-browser.desktop || true
else
  warn "yay not available, skipping AUR apps"
fi

echo "== 5/8 Config files (differing existing files are backed up) =="
FILES=(
  .config/i3/config
  .config/polybar/config.ini
  .config/polybar/theme-colors.ini
  .config/polybar/launch.sh
  .config/polybar/scripts/wifi-menu.sh
  .config/polybar/scripts/power-menu.sh
  .config/polybar/scripts/bluetooth-menu.sh
  .config/polybar/scripts/bluetooth-status.sh
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
  .local/bin/apply-accent
  .local/bin/refresh-login-bg
  .local/bin/setup-wallpapers
)
for f in "${FILES[@]}"; do
  if [ ! -f "$DIR/$f" ]; then warn "missing in repo: $f"; continue; fi
  mkdir -p "$HOME/$(dirname "$f")"
  if [ -f "$HOME/$f" ] && ! cmp -s "$DIR/$f" "$HOME/$f"; then
    cp "$HOME/$f" "$HOME/$f.backup-before-install"
  fi
  cp "$DIR/$f" "$HOME/$f"
  sed -i "s|/home/[A-Za-z0-9_.-]*|$HOME|g" "$HOME/$f"
done

chmod +x "$HOME"/.config/polybar/launch.sh "$HOME"/.config/polybar/scripts/*.sh "$HOME"/.config/themes/switch-theme.sh \
  "$HOME"/.local/bin/{choose-theme,choose-wallpaper,wallpaper-colors,apply-wallpaper-colors,screenshot,set-login-background,setup-wallpapers,apply-accent,refresh-login-bg} 2>/dev/null || true

WIFI="$(ls /sys/class/net | grep -E '^wl' | head -1 || true)"
if [ -n "$WIFI" ] && [ "$WIFI" != "wlan0" ]; then
  sed -i "s/wlan0/$WIFI/g" "$HOME/.config/polybar/config.ini"
  echo "Polybar Wi-Fi interface set to $WIFI"
fi

echo "== 6/8 Touchpad and theme state =="
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
fi
mkdir -p "$HOME/Pictures/Wallpapers/Christian" "$HOME/Pictures/Wallpapers/Sci-fi" "$HOME/Pictures/Wallpapers/Motivational" "$HOME/Pictures/Screenshots"
[ -f "$HOME/.config/themes/current-theme" ] || echo "Sci-fi" > "$HOME/.config/themes/current-theme"
touch "$HOME/.config/themes/wallpaper-colors-on"

echo "== 7/8 Wallpapers =="
echo "The wallpapers are too big for GitHub."
echo "Download the archive from https://t.me/hitsilez and save it in ~/Downloads."
read -r -p "Press Enter to continue (it is fine if you have not downloaded it yet): " _ || true
"$HOME/.local/bin/setup-wallpapers" || warn "wallpaper setup skipped, run setup-wallpapers later"

echo "== 8/8 Login screen =="
"$HOME/.local/bin/set-login-background" || warn "login background skipped"
# let the wallpaper picker refresh the login image without sudo
[ -f /usr/share/backgrounds/login-bg.png ] && sudo chown "$USER" /usr/share/backgrounds/login-bg.png || true

echo ""
echo "===================================================="
echo "Install finished."
echo "1. Connect to Wi-Fi if needed:  nmtui"
echo "2. No wallpapers yet? Put the archive in ~/Downloads and run: setup-wallpapers"
echo "3. Log out, choose i3 at the login screen, log in."
echo "===================================================="
