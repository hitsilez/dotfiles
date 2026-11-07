# My Arch + Hyprland setup

Saved settings for my desktop: Hyprland (Lua config), Waybar, Wofi, Alacritty,
Matugen (wallpaper colors), Mako, my scripts, and the SDDM login theme.

## Restoring on a fresh Arch install
1. Install the programs:
   sudo pacman -S --needed - < packages-official.txt
   Then install what is in packages-extra-aur.txt (these came from outside the
   official repos, for example awww) using an AUR helper.
2. Run ./restore.sh  (it keeps a copy of anything it replaces).
3. Put wallpapers into ~/Pictures/Wallpapers/{christianity,scifi,apocalypse,anime}
   (wallpapers are not saved here).
4. Login screen: copy system/sddm/midnight-glass to /usr/share/sddm/themes/ and the
   .conf file(s) to /etc/sddm.conf.d/ (use sudo). See system/notes.txt for the
   wallpaper-sync folder, which must be writable by my user.
5. Set the timezone (see system/notes.txt), then reboot.

## Not saved on purpose
Wi-Fi passwords, browser data, and the wallpaper images.
