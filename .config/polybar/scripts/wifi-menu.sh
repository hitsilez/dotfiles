#!/usr/bin/env bash

set -u

ROFI="rofi -dmenu -i -p Wi-Fi"

# Refresh the list of nearby Wi-Fi networks.
nmcli device wifi rescan >/dev/null 2>&1
sleep 2

mapfile -t networks < <(
    nmcli -t -f SSID device wifi list --rescan no |
    sed 's/\\:/\:/g' |
    sed '/^[[:space:]]*$/d' |
    sort -u
)

if [ "${#networks[@]}" -eq 0 ]; then
    notify-send "Wi-Fi" "No networks found. Check that Wi-Fi is enabled."
    exit 1
fi

ssid=$(printf '%s\n' "${networks[@]}" | eval "$ROFI")

[ -n "$ssid" ] || exit 0

# Prefer an existing saved connection when its profile name matches.
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" ||
        notify-send "Wi-Fi" "Could not connect to $ssid"
    exit
fi

# Try connecting without a password first (for open networks).
if nmcli --wait 15 device wifi connect "$ssid"; then
    notify-send "Wi-Fi" "Connected to $ssid"
    exit 0
fi

# If a password is required, ask for it using Rofi.
password=$(rofi -dmenu -password -p "Password for $ssid")

[ -n "$password" ] || exit 0

if nmcli --wait 30 device wifi connect "$ssid" password "$password"; then
    notify-send "Wi-Fi" "Connected to $ssid"
else
    notify-send "Wi-Fi" "Connection failed. Check the password or try again."
fi
