#!/usr/bin/env bash
# Prints the Bluetooth icon and state for Polybar. The icon takes the wallpaper accent color.
ICON_ON=$(printf '\U000f00af')
ICON_CONN=$(printf '\U000f00b1')
ICON_OFF=$(printf '\U000f00b2')
ACCENT="$(sed -n 's/^accent *= *\(#[0-9A-Fa-f]\{6\}\)$/\1/p' "$HOME/.config/polybar/theme-colors.ini" 2>/dev/null | head -1)"
ACCENT="${ACCENT:-#BA272D}"

if ! command -v bluetoothctl >/dev/null || ! systemctl is-active --quiet bluetooth; then
  echo "%{F$ACCENT}$ICON_OFF%{F-} N/A"; exit 0
fi
if [ "$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}')" != "yes" ]; then
  echo "%{F$ACCENT}$ICON_OFF%{F-} Off"; exit 0
fi
name="$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)"
if [ -n "$name" ]; then
  echo "%{F$ACCENT}$ICON_CONN%{F-} ${name:0:16}"
else
  echo "%{F$ACCENT}$ICON_ON%{F-} On"
fi
