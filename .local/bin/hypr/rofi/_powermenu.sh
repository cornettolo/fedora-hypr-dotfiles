#!/bin/bash

# Options to be displayed in Rofi
options="lock\nlogout\nsuspend\nreboot\nhybernate\nshutdown"

# Get the selected option from Rofi
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Execute action based on selected option
case "$selected_option" in
lock)
  # Replace with your screen locker command (e.g., swaylock, gtklock)
  hyprlock # Or whatever locker you use
  ;;
logout)
  # Replace with your actual logout command for Hyprland
  # This usually involves killing the Hyprland session
  hyprctl dispatch exit
  ;;
reboot)
  systemctl reboot
  ;;
shutdown)
  systemctl poweroff
  ;;
suspend)
  systemctl suspend
  ;;
hybernate)
  systemctl hibernate
  ;;
*)
  # Do nothing if no option is selected or Rofi is closed
  ;;
esac
