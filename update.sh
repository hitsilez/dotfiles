#!/usr/bin/env bash
# Refreshes ~/dotfiles from the live system, commits, and pushes if GitHub is set up.
DEST="$HOME/dotfiles"
CONFIGS=(hypr waybar wofi alacritty kitty matugen mako btop mpv gtk-3.0 Thunar xfce4 systemd)

copy_dir() {
  local src="$1" dst="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dst"
    tar -C "$src" --exclude='*.bak*' --exclude='*.backup*' --exclude='__pycache__' --exclude='*.disabled*' -cf - . | tar -C "$dst" -xf -
    echo "copied:  $src"
  fi
}

rm -rf "$DEST/config" "$DEST/bin" "$DEST/home" "$DEST/system" "$DEST/packages"
rm -f "$DEST"/packages-*.txt
mkdir -p "$DEST/config" "$DEST/bin" "$DEST/home" "$DEST/system" "$DEST/packages"

for name in "${CONFIGS[@]}"; do
  copy_dir "$HOME/.config/$name" "$DEST/config/$name"
done
copy_dir "$HOME/.local/bin" "$DEST/bin"
rm -f "$DEST/bin/moviebox-tui"

for f in .bashrc .bash_profile .bash_logout; do
  [ -f "$HOME/$f" ] && cp "$HOME/$f" "$DEST/home/"
done

WP="$HOME/Pictures/Wallpapers"
if [ -d "$WP" ]; then
  size=$(du -sm "$WP" | cut -f1)
  if [ "$size" -lt 150 ]; then
    rm -rf "$DEST/wallpapers"
    copy_dir "$WP" "$DEST/wallpapers"
  else
    echo "wallpapers are ${size} MB, too big for git, skipped"
  fi
fi

pacman -Qqen > "$DEST/packages/all-official.txt"
pacman -Qqen | grep -v -E '^(base|linux|linux-firmware|intel-ucode|amd-ucode|mkinitcpio|efibootmgr|xf86-video-.*|vulkan-(intel|radeon|nouveau)|intel-media-driver|libva-intel-driver|vpl-gpu-rt|libvpl)$' > "$DEST/packages/official.txt"
pacman -Qqem > "$DEST/packages/aur.txt"

dconf dump /org/gnome/nm-applet/ > "$DEST/system/nm-applet.dconf" 2>/dev/null
[ -f /etc/systemd/zram-generator.conf ] && cp /etc/systemd/zram-generator.conf "$DEST/system/"
[ -d /etc/sddm.conf.d ] && cp -r /etc/sddm.conf.d "$DEST/system/"
[ -f /etc/sddm.conf ] && cp /etc/sddm.conf "$DEST/system/"
[ -f "$HOME/.cache/last-wallpaper" ] && cp "$HOME/.cache/last-wallpaper" "$DEST/system/last-wallpaper"
if [ -d /usr/share/sddm/themes/midnight-glass ]; then
  mkdir -p "$DEST/system/sddm-themes"
  cp -r /usr/share/sddm/themes/midnight-glass "$DEST/system/sddm-themes/"
  rm -f "$DEST"/system/sddm-themes/midnight-glass/*.backup*
fi

cd "$DEST" || exit 1
git add -A
if git commit -q -m "Update $(date +%F_%H-%M)"; then
  echo "saved a git snapshot"
else
  echo "nothing changed since the last snapshot"
fi
if git remote | grep -q origin; then
  git push -q && echo "pushed to GitHub" || echo "push failed (are you logged in? run: gh auth login)"
fi
