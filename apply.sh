#!/bin/bash

# ==========================================
# VARIABLES & SETUP
# ==========================================
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$HOME/dotfiles_backup/$TIMESTAMP"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==========================================
# HELPER FUNCTION: MERGE
# ==========================================
# This function merges contents. It does NOT delete the destination folder.
merge_folder() {
  local source="$1"
  local dest="$2"
  local name="$(basename "$source")"

  if [ ! -d "$source" ]; then
    return
  fi

  echo -e "${BLUE}[MERGING]${NC} $name -> $dest"

  mkdir -p "$dest"

  rsync -ab \
    --backup-dir="$BACKUP_ROOT/$name" \
    --suffix="" \
    "$source/" "$dest/"

  echo -e "${GREEN}[OK]${NC} Merged $name"
}

# ==========================================
# 3. EXECUTION
# ==========================================

echo "------------------------------------------"
echo "Starting Merge Installation"
echo "Existing symlinks and extra files will stay untouched."
echo "Overwritten files backed up to: $BACKUP_ROOT"
echo "------------------------------------------"

# --- Home Directory Files ---
# We loop files here because we don't want to rsync the whole home folder!
if [ -d "$DOTFILES_DIR/home" ]; then
  echo "Processing Home Files..."
  # Loop through hidden files (.bashrc, etc)
  find "$DOTFILES_DIR/home" -mindepth 1 -maxdepth 1 | while read item; do
    item_name=$(basename "$item")
    # Use rsync for single files too, ensures backup logic is consistent
    rsync -avb --backup-dir="$BACKUP_ROOT/home" --suffix="" "$item" "$HOME/"
  done
fi

# --- Config Directory ---
# Loops through folders in repo/config (e.g. nvim, alacritty)
# and merges them into ~/.config/nvim, ~/.config/alacritty
if [ -d "$DOTFILES_DIR/config" ]; then
  echo "Processing .config folders..."
  find "$DOTFILES_DIR/config" -mindepth 1 -maxdepth 1 -type d | while read folder; do
    folder_name=$(basename "$folder")
    merge_folder "$folder" "$HOME/.config/$folder_name"
  done
fi

# --- Local Bin Hypr ---
# Merges repo/local/bin/hypr into ~/.local/bin/hypr
if [ -d "$DOTFILES_DIR/local/bin/hypr" ]; then
  echo "Processing Hypr scripts..."
  merge_folder "$DOTFILES_DIR/local/bin/hypr" "$HOME/.local/bin/hypr"
fi

# --- Zsh ---
# Merges repo/zsh into ~/.zsh
if [ -d "$DOTFILES_DIR/zsh" ]; then
  echo "Processing Zsh scripts..."
  merge_folder "$DOTFILES_DIR/zsh" "$HOME/.zsh"
fi

echo "------------------------------------------"
echo "Done! Backups at: $BACKUP_DIR"
echo "------------------------------------------"

# --- D. Restarting components ---
echo "Restarting components"

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
