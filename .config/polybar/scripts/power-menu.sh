#!/bin/bash
choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nShut down\n' | rofi -dmenu -i -p "Power" -no-custom)
[ -z "$choice" ] && exit 0

confirm() {
  ans=$(printf 'No\nYes\n' | rofi -dmenu -i -p "$1?" -no-custom)
  [ "$ans" = "Yes" ]
}

case "$choice" in
  "Lock")      i3lock ;;
  "Suspend")   systemctl suspend ;;
  "Log out")   confirm "Log out" && i3-msg exit ;;
  "Reboot")    confirm "Reboot" && systemctl reboot ;;
  "Shut down") confirm "Shut down" && systemctl poweroff ;;
esac
