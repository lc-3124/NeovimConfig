#!/bin/bash

# Power menu — uses wlogout if available, otherwise wofi
# Icons: ⏻ shutdown  🔄 reboot  🚪 logout  ⏾ suspend

if command -v wlogout &>/dev/null; then
  wlogout --protocol layer-shell
  exit 0
fi

SELECTION=$(printf "⏻  Shutdown\n🔄  Reboot\n🚪  Logout\n⏾  Suspend\n🔒  Lock" | wofi --dmenu --width 200 --height 250 -p "Power")

case "$SELECTION" in
  *Shutdown) systemctl poweroff ;;
  *Reboot)   systemctl reboot ;;
  *Logout)   hyprctl dispatch exit ;;
  *Suspend)  systemctl suspend ;;
  *Lock)     loginctl lock-session ;;
esac
