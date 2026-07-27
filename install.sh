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
# Guarded: a locked-down work machine may have no Homebrew at all, and with
# `set -e` an unguarded `brew` would abort the whole install before the config
# symlinks below ever ran. Skip loudly instead of dying.
if command -v brew >/dev/null 2>&1; then
  brew_pkgs=$(read_list "$DOTFILES/brew.txt")
  [ -n "$brew_pkgs" ] && brew install $brew_pkgs
else
  echo "  - no brew on this machine, skipping (install these by hand)"
fi

echo "==> Installing global npm packages (from npm.txt)"
if command -v npm >/dev/null 2>&1; then
  npm_pkgs=$(read_list "$DOTFILES/npm.txt")
  [ -n "$npm_pkgs" ] && npm install -g $npm_pkgs
else
  echo "  - no npm on this machine, skipping"
fi

# clangd (C/C++ LSP) comes from Xcode command line tools: xcode-select --install

echo "==> Installing jdtls (Java LSP)"
# jdtls has no package to install -- it's a tarball of JARs from Eclipse, which
# is exactly why it works on a machine with no Homebrew. We unpack it to
# ~/.local/share/jdtls and Neovim launches it with `java -jar` (see init.lua).
#
# Santa note: the ONLY executable in that chain is `java`, which is already
# approved on any machine where you write Java. The JARs are read as data by
# the JVM, never exec'd, so there's no new binary for Santa to judge. (This is
# why jdtls installs cleanly where the treesitter parsers did not.)
#
# Pin a version by setting JDTLS_URL; the default tracks the latest snapshot.
JDTLS_HOME="${JDTLS_HOME:-$HOME/.local/share/jdtls}"
JDTLS_URL="${JDTLS_URL:-https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz}"
if [ -d "$JDTLS_HOME/plugins" ]; then
  echo "  - jdtls already present at $JDTLS_HOME, skipping"
elif command -v curl >/dev/null 2>&1; then
  mkdir -p "$JDTLS_HOME"
  echo "  - downloading jdtls (~51MB)"
  curl -fsSL "$JDTLS_URL" | tar -xz -C "$JDTLS_HOME"
  echo "  - unpacked to $JDTLS_HOME"
else
  echo "  - no curl, skipping jdtls"
fi
# jdtls needs a JDK 21+ to RUN (independent of what your projects target).
# If `java -version` is older, point JAVA_HOME_FOR_JDTLS at a 21 JDK -- init.lua
# reads it. On macOS, `/usr/libexec/java_home -V` lists what's installed.

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
