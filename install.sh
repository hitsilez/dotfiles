#!/usr/bin/env bash
set -e
DOT="$(cd "$(dirname "$0")" && pwd)"

echo ">> Updating system and installing packages"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git pciutils dconf
sudo pacman -S --needed --noconfirm - < "$DOT/packages/official.txt"

echo ">> Detecting CPU and GPU"
grep -q GenuineIntel /proc/cpuinfo && sudo pacman -S --needed --noconfirm intel-ucode
grep -q AuthenticAMD /proc/cpuinfo && sudo pacman -S --needed --noconfirm amd-ucode
GPU="$(lspci | grep -iE 'vga|3d')"
echo "$GPU" | grep -qi intel && sudo pacman -S --needed --noconfirm vulkan-intel intel-media-driver vpl-gpu-rt libvpl
echo "$GPU" | grep -qiE 'amd|ati' && sudo pacman -S --needed --noconfirm vulkan-radeon
echo "$GPU" | grep -qi nvidia && echo "!! NVIDIA GPU detected: install its drivers manually (see the Arch wiki)"

if [ -s "$DOT/packages/aur.txt" ]; then
  echo ">> Installing AUR packages"
  if ! command -v yay &>/dev/null; then
    rm -rf /tmp/yay-bin
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
  fi
  yay -S --needed --noconfirm - < "$DOT/packages/aur.txt"
fi

echo ">> Copying configs"
mkdir -p ~/.config ~/.local/bin
cp -a "$DOT/config/." ~/.config/
cp -a "$DOT/bin/." ~/.local/bin/
cp -a "$DOT/home/." ~/
if [ -d "$DOT/wallpapers" ]; then
  mkdir -p ~/Pictures/Wallpapers
  cp -a "$DOT/wallpapers/." ~/Pictures/Wallpapers/
fi

if [ "$HOME" != "/home/tsilez" ]; then
  grep -rl "/home/tsilez" ~/.config ~/.local/bin 2>/dev/null | xargs -r sed -i "s|/home/tsilez|$HOME|g"
fi

echo ">> System files"
[ -f "$DOT/system/zram-generator.conf" ] && sudo cp "$DOT/system/zram-generator.conf" /etc/systemd/
[ -d "$DOT/system/sddm.conf.d" ] && sudo cp -r "$DOT/system/sddm.conf.d" /etc/
[ -f "$DOT/system/sddm.conf" ] && sudo cp "$DOT/system/sddm.conf" /etc/
[ -f "$DOT/system/nm-applet.dconf" ] && { dconf load /org/gnome/nm-applet/ < "$DOT/system/nm-applet.dconf" || echo "(dconf will need loading after first login)"; }

echo ">> Enabling services"
for s in NetworkManager bluetooth sddm systemd-timesyncd fstrim.timer; do
  sudo systemctl enable "$s"
done

echo
echo "Done! Reboot, log in, and connect to Wi-Fi (nmcli device wifi connect NAME --ask)."
