# dotfiles

My tmux + Neovim config, managed with symlinks.

## Layout
- `tmux/.tmux.conf`   → symlinked to `~/.tmux.conf`
- `nvim/init.lua`     → symlinked to `~/.config/nvim/init.lua`
- `brew.txt`          → Homebrew formulae to install
- `npm.txt`           → global npm packages to install
- `nvim/plugins.txt`  → Neovim plugins to git-clone into `pack/`
- `install.sh`        → recreates the symlinks + installs everything above

## New machine setup
    git clone <this-repo> ~/dotfiles
    ~/dotfiles/install.sh

## Adding things later
- A tool from Homebrew → add a line to `brew.txt`
- A global npm package → add a line to `npm.txt`
- A Neovim plugin      → add a line to `nvim/plugins.txt`
Then rerun `./install.sh` (it skips anything already installed).

## Note
`clangd` (C/C++ LSP) is not in a manifest — it ships with Xcode's command
line tools: `xcode-select --install`.
