#!/usr/bin/env bash
pkill -x polybar 2>/dev/null
sleep 1
polybar -c "$HOME/.config/polybar/config.ini" main \
  >> "$HOME/.config/polybar/polybar.log" 2>&1 &
