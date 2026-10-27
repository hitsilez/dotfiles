#!/usr/bin/env bash
# Bluetooth menu for Polybar (rofi + bluetoothctl). Two bluetoothctl calls to build the list.
I_CONN=$(printf '\U000f00b1')
I_PAIR=$(printf '\U000f00af')

WIDTH='window { width: 520px; }'
mac_of() { grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' <<< "$1" | tail -1; }
err() { rofi -e "$1" -theme-str "$WIDTH"; }
menu() { rofi -dmenu -i -p "$1" -mesg "$2" -theme-str "$WIDTH"; }
BUSY=""
busy() { rofi -e "$1" -theme-str "$WIDTH" & BUSY=$!; }
unbusy() { [ -n "$BUSY" ] && kill "$BUSY" 2>/dev/null; BUSY=""; }

if ! command -v bluetoothctl >/dev/null; then
  err "bluetoothctl not found. Install it with: sudo pacman -S bluez bluez-utils"; exit 1
fi
if ! systemctl is-active --quiet bluetooth; then
  err "Bluetooth service is not running. Run: sudo systemctl enable --now bluetooth"; exit 1
fi

powered="$(bluetoothctl show | awk '/Powered:/ {print $2}')"
if [ "$powered" != "yes" ]; then
  choice="$(printf 'Turn Bluetooth on\n' | menu "Bluetooth" "Bluetooth is off")"
  if [ "$choice" = "Turn Bluetooth on" ]; then
    rfkill unblock bluetooth 2>/dev/null
    bluetoothctl power on >/dev/null || err "Could not turn Bluetooth on."
  fi
  exit 0
fi

connected="$(bluetoothctl devices Connected)"
paired="$(bluetoothctl devices Paired)"
count=0; [ -n "$connected" ] && count="$(wc -l <<< "$connected")"

top=""; rest=""
while read -r _ mac name; do
  [ -z "$mac" ] && continue
  if grep -q "$mac" <<< "$connected"; then
    top+="${I_CONN}  ${name}  ·  connected  [${mac}]"$'\n'
  else
    rest+="${I_PAIR}  ${name}  [${mac}]"$'\n'
  fi
done <<< "$paired"

status="Bluetooth on  ·  ${count} connected"
choice="$( { printf '%s%s' "$top" "$rest"; printf 'Scan for new devices\nTurn Bluetooth off\n'; } | menu "Bluetooth" "$status")"

case "$choice" in
  "") exit 0 ;;
  "Turn Bluetooth off") bluetoothctl power off >/dev/null ;;
  "Scan for new devices")
    busy "Scanning for devices...  (8 seconds)"
    bluetoothctl --timeout 8 scan on >/dev/null 2>&1
    unbusy
    paired="$(bluetoothctl devices Paired)"
    new=""
    while read -r _ mac name; do
      [ -z "$mac" ] && continue
      grep -q "$mac" <<< "$paired" && continue
      [ "${name//-/:}" = "$mac" ] && continue
      new+="${name}  [${mac}]"$'\n'
    done < <(bluetoothctl devices)
    if [ -z "$new" ]; then
      err "No new devices found. Put the device in pairing mode and try again."; exit 0
    fi
    pick="$(printf '%s' "$new" | menu "Pair" "Select a device to pair")"
    [ -z "$pick" ] && exit 0
    mac="$(mac_of "$pick")"
    busy "Pairing..."
    if timeout 30 bluetoothctl pair "$mac" >/dev/null 2>&1; then
      bluetoothctl trust "$mac" >/dev/null
      timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1; rc=$?
      unbusy
      [ "$rc" -ne 0 ] && err "Paired, but connecting failed."
    else
      unbusy
      err "Pairing failed. Some devices need a code or a special mode."
    fi
    ;;
  *)
    mac="$(mac_of "$choice")"
    [ -z "$mac" ] && exit 0
    if grep -q "$mac" <<< "$connected"; then
      bluetoothctl disconnect "$mac" >/dev/null
    else
      busy "Connecting..."
      timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1; rc=$?
      unbusy
      [ "$rc" -ne 0 ] && err "Could not connect. Is the device on and nearby?"
    fi
    ;;
esac
