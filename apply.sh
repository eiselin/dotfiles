#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Destination locations
NVIM_DIR="$HOME/.config/nvim"
ALACRITTY_DIR="$HOME/.config/alacritty"
TMUX_CONF="$HOME/.tmux.conf"
FIREFOX_CHROME_DIR="$HOME/Library/Application Support/Firefox/Profiles/8hvurr5f.default-release-1717767901382/chrome"

usage() {
  echo "Usage: $0 [app ...] | all"
  echo ""
  echo "Apps: nvim, alacritty, tmux, firefox"
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
  cp "$DOTFILES_DIR/alacritty/alacritty.toml" "$ALACRITTY_DIR/"
  # Copy bundled colorscheme file (if any)
  THEME_FILE=$(sed -n 's/.*"\(~\/.config\/alacritty\/[^/]*\.toml\)".*/\1/p' "$DOTFILES_DIR/alacritty/alacritty.toml" | xargs basename 2>/dev/null || true)
  if [ -n "$THEME_FILE" ] && [ -f "$DOTFILES_DIR/alacritty/$THEME_FILE" ]; then
    cp "$DOTFILES_DIR/alacritty/$THEME_FILE" "$ALACRITTY_DIR/"
    echo "    colorscheme: $THEME_FILE"
  fi
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
      apply_firefox
      ;;
    nvim)       apply_nvim ;;
    alacritty)  apply_alacritty ;;
    tmux)       apply_tmux ;;
    firefox)    apply_firefox ;;
    *)
      echo "Unknown app: $arg"
      usage
      ;;
  esac
done

echo "Done."
