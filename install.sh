#!/bin/bash
# Rebuild this machine's config from the dotfiles repo.
set -e
DOTFILES="$HOME/dotfiles"

echo "==> Linking config files"
ln -sf "$DOTFILES/tmux/.tmux.conf"   "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES/nvim/init.lua"     "$HOME/.config/nvim/init.lua"

echo "==> Installing external tools"
brew install ripgrep fd lua-language-server tmux neovim
npm install -g pyright
# clangd (C/C++) comes from Xcode command line tools: xcode-select --install

echo "==> Cloning Neovim plugins (native pack/)"
PLUG="$HOME/.config/nvim/pack/plugins/start"
COLR="$HOME/.config/nvim/pack/colors/start"
mkdir -p "$PLUG" "$COLR"
git clone --depth 1 https://github.com/nvim-lua/plenary.nvim         "$PLUG/plenary.nvim"   || true
git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim "$PLUG/telescope.nvim" || true
git clone --depth 1 https://github.com/tpope/vim-fugitive            "$PLUG/vim-fugitive"   || true
git clone --depth 1 https://github.com/rose-pine/neovim              "$COLR/rose-pine"      || true

echo "==> Done."
Then make it executable:
chmod +x ~/dotfiles/install.sh

Step 5 — Write a README.md

A short note to future-you. Create ~/dotfiles/README.md:
# dotfiles

My tmux + Neovim config.

## Layout
- `tmux/.tmux.conf`  → ~/.tmux.conf
- `nvim/init.lua`    → ~/.config/nvim/init.lua

## New machine setup
    git clone <this-repo> ~/dotfiles
    ~/dotfiles/install.sh

## External tools (not in this repo)
ripgrep, fd, lua-language-server (brew) · pyright (npm) · clangd (Xcode)