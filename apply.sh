#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Destination locations
NVIM_DIR="$HOME/.config/nvim"
ALACRITTY_DIR="$HOME/.config/alacritty"
TMUX_CONF="$HOME/.tmux.conf"
ZED_DIR="$HOME/.config/zed"
FIREFOX_CHROME_DIR="$HOME/Library/Application Support/Firefox/Profiles/8hvurr5f.default-release-1717767901382/chrome"

usage() {
  echo "Usage: $0 [app ...] | all"
  echo ""
  echo "Apps: nvim, alacritty, tmux, zed, firefox"
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

apply_alacritty() {
  echo "  alacritty"
  mkdir -p "$ALACRITTY_DIR"
  for f in "$DOTFILES_DIR/alacritty/"*.toml; do
    [ -f "$f" ] || continue
    cp "$f" "$ALACRITTY_DIR/"
    echo "    copied: $(basename "$f")"
  done
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

apply_firefox() {
  echo "  firefox"
  mkdir -p "$FIREFOX_CHROME_DIR"
  cp "$DOTFILES_DIR/firefox/userChrome.css" "$FIREFOX_CHROME_DIR/userChrome.css"
}

if [ $# -eq 0 ]; then
  usage
fi

echo "Applying dotfiles from $DOTFILES_DIR ..."

for arg in "$@"; do
  case "$arg" in
    all)
      apply_nvim
      apply_alacritty
      apply_tmux
      apply_zed
      apply_firefox
      ;;
    nvim)       apply_nvim ;;
    alacritty)  apply_alacritty ;;
    tmux)       apply_tmux ;;
    zed)        apply_zed ;;
    firefox)    apply_firefox ;;
    *)
      echo "Unknown app: $arg"
      usage
      ;;
  esac
done

echo "Done."
