#!/usr/bin/env bash
# Refreshes ~/dotfiles from my live settings and saves a git snapshot.
DEST="$HOME/dotfiles"

copy_dir() {
  local src="$1" dst="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dst"
    tar -C "$src" --exclude='*.bak*' --exclude='*.backup*' -cf - . | tar -C "$dst" -xf -
    echo "copied:  $src"
  fi
}

rm -rf "$DEST/config" "$DEST/bin"
mkdir -p "$DEST/config" "$DEST/bin"
for name in hypr waybar wofi alacritty matugen mako; do
  copy_dir "$HOME/.config/$name" "$DEST/config/$name"
done
copy_dir "$HOME/.local/bin" "$DEST/bin"
rm -f "$DEST/bin/moviebox-tui"

pacman -Qqen > "$DEST/packages-official.txt"
pacman -Qqem > "$DEST/packages-extra-aur.txt"

cd "$DEST" || exit 1
git add -A
if git -c user.name="tsilez" -c user.email="tsilez@localhost" commit -q -m "Update $(date +%F_%H-%M)"; then
  echo "saved a git snapshot"
else
  echo "nothing changed since the last snapshot"
fi
