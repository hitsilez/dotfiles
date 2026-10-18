#!/bin/bash
IFACE="wlan0"
note() { command -v notify-send >/dev/null && notify-send "Wi-Fi" "$1"; }

nmcli device wifi rescan ifname "$IFACE" >/dev/null 2>&1
sleep 1

list=$(nmcli -t -f SIGNAL,SECURITY,SSID device wifi list ifname "$IFACE" \
  | awk -F: '{ssid=$3; for(i=4;i<=NF;i++) ssid=ssid":"$i; gsub(/\\/,"",ssid); if(ssid!="") print $1"%  "($2==""?"open":"secured")"  "ssid}' \
  | sort -rn)

[ -z "$list" ] && { note "No networks found"; exit 1; }

choice=$(echo "$list" | rofi -dmenu -i -p "Wi-Fi" -no-custom)
[ -z "$choice" ] && exit 0

ssid=$(echo "$choice" | sed -E 's/^[0-9]+%  (open|secured)  //')

if nmcli device wifi connect "$ssid" ifname "$IFACE" >/dev/null 2>&1; then
  note "Connected to $ssid"
  exit 0
fi

pw=$(rofi -dmenu -password -p "Password for $ssid" -lines 0)
[ -z "$pw" ] && exit 0

if nmcli device wifi connect "$ssid" password "$pw" ifname "$IFACE" >/dev/null 2>&1; then
  note "Connected to $ssid"
else
  note "Could not connect to $ssid (wrong password?)"
fi
