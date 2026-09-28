#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Destination locations
NVIM_DIR="$HOME/.config/nvim"
TMUX_CONF="$HOME/.tmux.conf"
ZED_DIR="$HOME/.config/zed"
GHOSTTY_DIR="$HOME/.config/ghostty"

usage() {
  echo "Usage: $0 [app ...] | all"
  echo ""
  echo "Apps: nvim, tmux, zed, ghostty"
  echo ""
  echo "Examples:"
  echo "  $0 all"
  echo "  $0 nvim tmux"
  exit 1
}

apply_nvim() {
  echo "  nvim"
  mkdir -p "$NVIM_DIR"
  cp "$DOTFILES_DIR/nvim/init.lua" "$NVIM_DIR/"
  [ -f "$DOTFILES_DIR/nvim/lazy-lock.json" ] && cp "$DOTFILES_DIR/nvim/lazy-lock.json" "$NVIM_DIR/"
}

apply_tmux() {
  echo "  tmux"
  cp "$DOTFILES_DIR/tmux/.tmux.conf" "$TMUX_CONF"
  # Copy bundled theme files (if any)
  for f in "$DOTFILES_DIR/tmux/"*.conf; do
    [ -f "$f" ] || continue
    mkdir -p "$HOME/.tmux"
    cp "$f" "$HOME/.tmux/"
    echo "    theme: $(basename "$f")"
  done
}

apply_zed() {
  echo "  zed"
  mkdir -p "$ZED_DIR"
  [ -f "$DOTFILES_DIR/zed/settings.json" ] && cp "$DOTFILES_DIR/zed/settings.json" "$ZED_DIR/"
  [ -f "$DOTFILES_DIR/zed/keymap.json" ] && cp "$DOTFILES_DIR/zed/keymap.json" "$ZED_DIR/"
}

apply_ghostty() {
  echo "  ghostty"
  mkdir -p "$GHOSTTY_DIR"
  [ -f "$DOTFILES_DIR/ghostty/config" ] && cp "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
}

if [ $# -eq 0 ]; then
  usage
fi

echo "Applying dotfiles from $DOTFILES_DIR ..."

for arg in "$@"; do
  case "$arg" in
    all)
      apply_nvim
      apply_tmux
      apply_zed
      apply_ghostty
      ;;
    nvim)       apply_nvim ;;
    tmux)       apply_tmux ;;
    zed)        apply_zed ;;
    ghostty)    apply_ghostty ;;
    *)
      echo "Unknown app: $arg"
      usage
      ;;
  esac
done

echo "Done."
