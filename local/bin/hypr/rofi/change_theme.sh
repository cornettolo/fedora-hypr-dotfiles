#!/bin/bash

# Define the path to your theme configurations
CONFIG_DIR="$HOME/.config"

# --- Rofi Menu ---
# Use Rofi to present a menu with "Light" and "Dark" options.
# The selected option will be stored in the 'selected' variable.
selected=$(printf "Light\nDark" | rofi -dmenu -p "Select Theme")

# --- Theme Switching Logic ---
# Exit if the user presses escape or closes the Rofi menu.
if [ -z "$selected" ]; then
  exit 0
fi

# Set the theme based on the user's selection.
if [ "$selected" == "Light" ]; then
  THEME="light"
  GTK_THEME="Gruvbox-Light"
  ICON_THEME="Gruvbox-Plus-Light"
elif [ "$selected" == "Dark" ]; then
  THEME="dark"
  GTK_THEME="Gruvbox-Dark"
  ICON_THEME="Gruvbox-Plus-Dark"
fi

# --- Apply GTK Theme ---
# Use gsettings to change the GTK theme and color-scheme preference.
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
if [ "$selected" == "Light" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
elif [ "$selected" == "Dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

# --- Application-Specific Theme Switching ---

# Function to switch configs for a given application
switch_config() {
  APP_NAME=$1
  # Check if a theme-specific config directory exists for the application.
  if [ -d "$CONFIG_DIR/$APP_NAME/$THEME" ]; then
    # Find all config files in the theme directory and symlink them to the parent config directory.
    find "$CONFIG_DIR/$APP_NAME/$THEME" -maxdepth 1 -type f | while read -r THEME_FILE; do
      ln -sf "$THEME_FILE" "$CONFIG_DIR/$APP_NAME/"
    done
    echo "Switched $APP_NAME theme to $THEME"
  fi
}

# Switch themes for your applications
switch_config "hypr"
switch_config "kitty"
switch_config "waybar"
switch_config "swaync"
switch_config "rofi"
switch_config "gtk-3.0"
switch_config "gtk-4.0"
switch_config "xsettingsd"
switch_config "theme"

# --- Reload Applications ---

# Reload Hyprland for color changes to take effect
hyprctl reload

# Reload running Kitty terminals by sending a SIGUSR1 signal.
if pgrep -x "kitty" >/dev/null; then
  killall -SIGUSR1 kitty
fi

# Reload Waybar by sending a SIGUSR2 signal.
if pgrep -x "waybar" >/dev/null; then
  pkill waybar && nohup waybar >/dev/null 2>&1 &
fi

# Reload SwayNC to apply the new theme.
if pgrep -x "swaync" >/dev/null; then
  swaync-client --reload-config && swaync-client --reload-css
fi

# Reload wallpaper
hyprctl hyprpaper reload ,"~/.config/theme/wallpaper1"

echo "Theme successfully switched to $THEME"
