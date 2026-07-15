#!/bin/bash
# Rebuild this machine's config from the dotfiles repo.
# The *lists* of things to install live in manifest files (brew.txt, npm.txt,
# nvim/plugins.txt) so this script is just the logic that reads them.
set -e
DOTFILES="$HOME/dotfiles"

# Print the meaningful lines of a manifest: strips blank lines and # comments.
read_list() {
  [ -f "$1" ] || return 0
  grep -vE '^[[:space:]]*(#|$)' "$1" || true
}

echo "==> Linking config files"
ln -sf "$DOTFILES/tmux/.tmux.conf"   "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES/nvim/init.lua"     "$HOME/.config/nvim/init.lua"
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_DIR"
ln -sf "$DOTFILES/ghostty/config.ghostty" "$GHOSTTY_DIR/config.ghostty"

echo "==> Installing Homebrew formulae (from brew.txt)"
brew_pkgs=$(read_list "$DOTFILES/brew.txt")
[ -n "$brew_pkgs" ] && brew install $brew_pkgs

echo "==> Installing global npm packages (from npm.txt)"
npm_pkgs=$(read_list "$DOTFILES/npm.txt")
[ -n "$npm_pkgs" ] && npm install -g $npm_pkgs

# clangd (C/C++ LSP) comes from Xcode command line tools: xcode-select --install

echo "==> Cloning Neovim plugins (from nvim/plugins.txt)"
while read -r group url name _; do
  case "$group" in ''|\#*) continue ;; esac   # skip blank lines and # comments
  name="${name:-$(basename "$url" .git)}"
  dest="$HOME/.config/nvim/pack/$group/start/$name"
  if [ -d "$dest" ]; then
    echo "  - $name already present, skipping"
  else
    echo "  - cloning $name"
    git clone --depth 1 "$url" "$dest"
  fi
done < "$DOTFILES/nvim/plugins.txt"

echo "==> Done."
