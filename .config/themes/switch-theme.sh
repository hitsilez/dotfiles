#!/bin/bash

THEME="$1"
WALL="$HOME/Pictures/Wallpapers"
POLY="$HOME/.config/polybar/config.ini"
BASE="$HOME/.config/polybar/config.ini.backup-themes"

case "$THEME" in
  Christian)
    WALLPAPER="$WALL/Christian/christian-sunrise.jpg"
    BG="#10151C"
    BGALT="#252D36"
    FG="#F0E9DB"
    MUTED="#A9A397"
    ACCENT="#D8A653"
    RED="#E06C75"
    GREEN="#A6B88A"
    ;;
  Sci-fi)
    WALLPAPER="$WALL/Sci-fi/cyberpunk-city.jpg"
    BG="#050B18"
    BGALT="#10213A"
    FG="#E0F7FF"
    MUTED="#7E9CB8"
    ACCENT="#00D9FF"
    RED="#FF3D9A"
    GREEN="#62F5C8"
    ;;
  Motivational)
    WALLPAPER="$WALL/Motivational/mountain-hiker.jpg"
    BG="#11110F"
    BGALT="#29251E"
    FG="#F5F0E6"
    MUTED="#B1A58E"
    ACCENT="#FFAA32"
    RED="#F06A3B"
    GREEN="#A7D477"
    ;;
  *)
    echo "Usage: $0 Christian | Sci-fi | Motivational"
    exit 1
    ;;
esac

if [[ ! -f "$WALLPAPER" ]]; then
  echo "Wallpaper not found: $WALLPAPER"
  exit 1
fi

# Save the selected theme's palette into Polybar's config.
sed -i \
  -e "s/^background = .*/background = $BG/" \
  -e "s/^background-alt = .*/background-alt = $BGALT/" \
  -e "s/^foreground = .*/foreground = $FG/" \
  -e "s/^muted = .*/muted = $MUTED/" \
  -e "s/^accent = .*/accent = $ACCENT/" \
  -e "s/^red = .*/red = $RED/" \
  -e "s/^green = .*/green = $GREEN/" \
  "$POLY"

# Change wallpaper, restart Polybar, and record the current theme.
feh --bg-fill "$WALLPAPER"
killall -q polybar
sleep 1
polybar -c "$POLY" main >> "$HOME/.config/polybar/polybar.log" 2>&1 &
printf '%s\n' "$THEME" > "$HOME/.config/themes/current"
echo "Theme applied: $THEME"
