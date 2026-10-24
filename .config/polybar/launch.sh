#!/usr/bin/env bash
CFG="$HOME/.config/polybar/config.ini"
COLORS="$HOME/.config/polybar/theme-colors.ini"

# Copy the current accent into the fixed-color icon tags (icons only).
ACCENT="$(sed -n 's/^accent *= *#\([0-9A-Fa-f]\{6\}\)$/\1/p' "$COLORS" 2>/dev/null | head -1)"
if [ -n "$ACCENT" ]; then
  sed -i "s/%{F#[0-9A-Fa-f]\{6\}}/%{F#$ACCENT}/g" "$CFG"
fi

pkill -x polybar 2>/dev/null
sleep 1
polybar -c "$CFG" main \
  >> "$HOME/.config/polybar/polybar.log" 2>&1 &
