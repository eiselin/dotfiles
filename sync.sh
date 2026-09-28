#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source locations
NVIM_DIR="$HOME/.config/nvim"
TMUX_CONF="$HOME/.tmux.conf"
ZED_DIR="$HOME/.config/zed"
GHOSTTY_DIR="$HOME/.config/ghostty"

echo "Syncing dotfiles into $DOTFILES_DIR ..."

# --- nvim ---
echo "  nvim"
rm -rf "$DOTFILES_DIR/nvim"
mkdir -p "$DOTFILES_DIR/nvim"
cp "$NVIM_DIR/init.lua" "$DOTFILES_DIR/nvim/"
[ -f "$NVIM_DIR/lazy-lock.json" ] && cp "$NVIM_DIR/lazy-lock.json" "$DOTFILES_DIR/nvim/"

# --- tmux (config + theme files) ---
echo "  tmux"
cp "$TMUX_CONF" "$DOTFILES_DIR/tmux/.tmux.conf"
for f in "$HOME/.tmux/"*.conf; do
  [ -f "$f" ] || continue
  cp "$f" "$DOTFILES_DIR/tmux/"
  echo "    bundled theme: $(basename "$f")"
done

# --- zed ---
echo "  zed"
rm -rf "$DOTFILES_DIR/zed"
mkdir -p "$DOTFILES_DIR/zed"
[ -f "$ZED_DIR/settings.json" ] && cp "$ZED_DIR/settings.json" "$DOTFILES_DIR/zed/"
[ -f "$ZED_DIR/keymap.json" ] && cp "$ZED_DIR/keymap.json" "$DOTFILES_DIR/zed/"

# --- ghostty (config only, follows macOS light/dark via theme = light:...,dark:...) ---
echo "  ghostty"
rm -rf "$DOTFILES_DIR/ghostty"
mkdir -p "$DOTFILES_DIR/ghostty"
[ -f "$GHOSTTY_DIR/config" ] && cp "$GHOSTTY_DIR/config" "$DOTFILES_DIR/ghostty/config"

echo "Done."
