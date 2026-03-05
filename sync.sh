#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source locations
NVIM_DIR="$HOME/.config/nvim"
ALACRITTY_DIR="$HOME/.config/alacritty"
TMUX_CONF="$HOME/.tmux.conf"
# Firefox profile with userChrome.css
FIREFOX_CHROME_DIR="$HOME/Library/Application Support/Firefox/Profiles/8hvurr5f.default-release-1717767901382/chrome"

echo "Syncing dotfiles into $DOTFILES_DIR ..."

# --- nvim ---
echo "  nvim"
rm -rf "$DOTFILES_DIR/nvim"
mkdir -p "$DOTFILES_DIR/nvim"
cp "$NVIM_DIR/init.lua" "$DOTFILES_DIR/nvim/"
[ -f "$NVIM_DIR/lazy-lock.json" ] && cp "$NVIM_DIR/lazy-lock.json" "$DOTFILES_DIR/nvim/"

# --- alacritty (config + active colorscheme) ---
echo "  alacritty"
rm -rf "$DOTFILES_DIR/alacritty"
mkdir -p "$DOTFILES_DIR/alacritty"
cp "$ALACRITTY_DIR/alacritty.toml" "$DOTFILES_DIR/alacritty/"

# Copy the active colorscheme and rewrite the import path
THEME_PATH=$(sed -n 's/.*"\(~\/.config\/alacritty\/themes\/themes\/[^"]*\)".*/\1/p' "$ALACRITTY_DIR/alacritty.toml")
if [ -n "$THEME_PATH" ]; then
  THEME_FILE=$(basename "$THEME_PATH")
  EXPANDED_PATH="${THEME_PATH/#\~/$HOME}"
  if [ -f "$EXPANDED_PATH" ]; then
    cp "$EXPANDED_PATH" "$DOTFILES_DIR/alacritty/$THEME_FILE"
    # Rewrite import in the repo copy to use a relative path
    sed -i '' "s|~/.config/alacritty/themes/themes/$THEME_FILE|~/.config/alacritty/$THEME_FILE|" "$DOTFILES_DIR/alacritty/alacritty.toml"
    echo "    bundled colorscheme: $THEME_FILE"
  else
    echo "    WARNING: theme file not found: $EXPANDED_PATH"
  fi
fi

# --- tmux ---
echo "  tmux"
cp "$TMUX_CONF" "$DOTFILES_DIR/tmux/.tmux.conf"

# --- firefox userChrome.css ---
echo "  firefox userChrome.css"
if [ -f "$FIREFOX_CHROME_DIR/userChrome.css" ]; then
  cp "$FIREFOX_CHROME_DIR/userChrome.css" "$DOTFILES_DIR/firefox/userChrome.css"
else
  echo "    WARNING: userChrome.css not found at expected path"
fi

echo "Done."
