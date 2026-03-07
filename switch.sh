#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.colorscheme"

usage() {
  echo "Usage: $0 [dark|light]"
  echo "  No argument toggles the current mode."
  exit 1
}

# Determine target mode
if [ $# -eq 1 ]; then
  MODE="$1"
  [[ "$MODE" == "dark" || "$MODE" == "light" ]] || usage
else
  current="light"
  [ -f "$STATE_FILE" ] && current=$(cat "$STATE_FILE")
  [ "$current" = "light" ] && MODE="dark" || MODE="light"
fi

echo "Switching to $MODE mode..."

# Save state
echo "$MODE" > "$STATE_FILE"

# macOS system appearance
if [ "$MODE" = "dark" ]; then
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
else
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
fi
echo "  macOS"

# Alacritty — swap the imported color theme and opacity
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONFIG" ]; then
  if [ "$MODE" = "dark" ]; then
    sed -i '' 's|tokyonight-day\.toml|tokyonight.toml|g' "$ALACRITTY_CONFIG"
    sed -i '' 's/opacity = 0\.92/opacity = 0.88/' "$ALACRITTY_CONFIG"
  else
    sed -i '' 's|tokyonight\.toml|tokyonight-day.toml|g' "$ALACRITTY_CONFIG"
    sed -i '' 's/opacity = 0\.88/opacity = 0.92/' "$ALACRITTY_CONFIG"
  fi
  echo "  alacritty"
fi

# Tmux — swap the sourced theme file and reload
TMUX_CONF="$HOME/.tmux.conf"
if [ -f "$TMUX_CONF" ]; then
  if [ "$MODE" = "dark" ]; then
    sed -i '' 's|source-file ~/\.tmux/light\.conf|source-file ~/.tmux/dark.conf|' "$TMUX_CONF"
  else
    sed -i '' 's|source-file ~/\.tmux/dark\.conf|source-file ~/.tmux/light.conf|' "$TMUX_CONF"
  fi
  if tmux info &>/dev/null 2>&1; then
    tmux source-file "$TMUX_CONF"
  fi
  echo "  tmux"
fi

# Neovim — swap tokyonight style (day=light, night=dark)
NVIM_CONFIG="$HOME/.config/nvim/init.lua"
if [ -f "$NVIM_CONFIG" ]; then
  if [ "$MODE" = "dark" ]; then
    sed -i '' 's/style = "day"/style = "night"/' "$NVIM_CONFIG"
    sed -i '' 's/colorscheme tokyonight-day/colorscheme tokyonight-night/' "$NVIM_CONFIG"
  else
    sed -i '' 's/style = "night"/style = "day"/' "$NVIM_CONFIG"
    sed -i '' 's/colorscheme tokyonight-night/colorscheme tokyonight-day/' "$NVIM_CONFIG"
  fi
  echo "  nvim (restart nvim to apply)"
fi

# Claude Code theme
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  if [ "$MODE" = "dark" ]; then
    python3 -c "import json; s=json.load(open('$CLAUDE_SETTINGS')); s['theme']='dark'; json.dump(s, open('$CLAUDE_SETTINGS','w'), indent=2); open('$CLAUDE_SETTINGS','a').write('\n')"
  else
    python3 -c "import json; s=json.load(open('$CLAUDE_SETTINGS')); s['theme']='light'; json.dump(s, open('$CLAUDE_SETTINGS','w'), indent=2); open('$CLAUDE_SETTINGS','a').write('\n')"
  fi
  echo "  claude code"
fi

echo "Done. Mode: $MODE"
