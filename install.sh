#!/usr/bin/env bash
#
# devenv_hj installer: Neovim + tmux development environment (Linux / macOS)
#
#   git clone <this repo> ~/Desktop/devenv_hj
#   cd ~/Desktop/devenv_hj && ./install.sh
#
# Safe to run again: existing files are backed up, finished steps are skipped.
# Run ./install.sh --help for options.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"     # Linux | Darwin
ARCH="$(uname -m)"   # x86_64 | aarch64 | arm64

NVIM_MIN_VERSION="0.11.0"                       # vim.lsp.config / vim.lsp.enable need 0.11+
NVIM_RELEASE="${NVIM_RELEASE:-stable}"          # GitHub release tag for the Linux tarball
MASON_TOOLS="clangd bash-language-server rust-analyzer"

DO_PACKAGES=1
DO_NVIM=1
DO_FONT=1
DO_PLUGINS=1

# ------------------------------------------------------------------ helpers
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# version_ge A B : true if version A >= version B
version_ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; }

nvim_version() { "$1" --version 2>/dev/null | head -n1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'; }

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Installs Neovim + tmux configs from this repo and everything they need.

Options:
  --no-packages   Skip system packages (apt / dnf / brew)
  --no-nvim       Skip installing Neovim itself (use the one already on PATH)
  --no-font       Skip Nerd Font (icon) install
  --no-plugins    Skip downloading Neovim/tmux plugins and language servers
  -h, --help      Show this help

Environment:
  NVIM_RELEASE    Neovim release tag for Linux (default: stable, e.g. v0.12.0)
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-packages) DO_PACKAGES=0 ;;
    --no-nvim)     DO_NVIM=0 ;;
    --no-font)     DO_FONT=0 ;;
    --no-plugins)  DO_PLUGINS=0 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage; die "unknown option: $arg" ;;
  esac
done

case "$OS" in
  Linux|Darwin) ;;
  *) die "unsupported OS: $OS (Linux and macOS only)" ;;
esac

# Backup an existing file/dir/link (unless it already points to $2), then symlink.
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst already linked"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak-$STAMP"
    warn "backed up existing $dst -> $dst.bak-$STAMP"
  fi
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}

# ------------------------------------------------------------------ steps
install_packages() {
  log "System packages"
  if [ "$OS" = "Darwin" ]; then
    have brew || die "Homebrew is required on macOS: https://brew.sh (then run this script again)"
    brew install git curl tmux ripgrep fd node neovim
  elif have apt-get; then
    sudo apt-get update
    sudo apt-get install -y git curl unzip tar gzip tmux ripgrep fd-find fontconfig \
      wl-clipboard xclip nodejs npm
  elif have dnf; then
    sudo dnf install -y git curl unzip tar gzip tmux ripgrep fd-find fontconfig \
      wl-clipboard xclip nodejs npm
  else
    warn "no apt-get/dnf found: install these yourself: git curl unzip tar tmux ripgrep fontconfig nodejs npm"
  fi
  ok "packages done"
}

# Prints the nvim binary to use (>= NVIM_MIN_VERSION), installing it if needed.
NVIM_BIN=""
install_nvim() {
  log "Neovim (>= $NVIM_MIN_VERSION)"
  local cur v
  cur="$(command -v nvim || true)"
  if [ -n "$cur" ]; then
    v="$(nvim_version "$cur")"
    if [ -n "$v" ] && version_ge "$v" "$NVIM_MIN_VERSION"; then
      NVIM_BIN="$cur"; ok "found nvim $v at $cur"; return
    fi
    warn "nvim ${v:-?} at $cur is too old"
  fi

  if [ "$DO_NVIM" -eq 0 ]; then
    die "Neovim >= $NVIM_MIN_VERSION not found and --no-nvim was given"
  fi

  if [ "$OS" = "Darwin" ]; then
    brew install neovim
    NVIM_BIN="$(command -v nvim)"
  else
    local asset
    case "$ARCH" in
      x86_64)        asset="nvim-linux-x86_64" ;;
      aarch64|arm64) asset="nvim-linux-arm64" ;;
      *) die "no Neovim Linux release for arch $ARCH" ;;
    esac
    local tmp; tmp="$(mktemp -d)"
    curl -fL --progress-bar -o "$tmp/nvim.tar.gz" \
      "https://github.com/neovim/neovim/releases/download/$NVIM_RELEASE/$asset.tar.gz"
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    rm -rf "$HOME/.local/opt/$asset"
    tar -C "$HOME/.local/opt" -xzf "$tmp/nvim.tar.gz"
    rm -rf "$tmp"
    ln -sfn "$HOME/.local/opt/$asset/bin/nvim" "$HOME/.local/bin/nvim"
    NVIM_BIN="$HOME/.local/bin/nvim"
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;
      *) warn "add ~/.local/bin to PATH (e.g. in ~/.bashrc): export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
    esac
  fi
  ok "installed nvim $(nvim_version "$NVIM_BIN") at $NVIM_BIN"
}

install_font() {
  log "Nerd Font symbols (icons for file tree / statusline)"
  if [ "$OS" = "Darwin" ]; then
    brew install --cask font-symbols-only-nerd-font
  else
    local fontdir="$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
    if [ -f "$fontdir/SymbolsNerdFont-Regular.ttf" ]; then
      ok "already installed in $fontdir"
    else
      local tmp; tmp="$(mktemp -d)"
      curl -fL --progress-bar -o "$tmp/nf.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip"
      mkdir -p "$fontdir"
      unzip -o -q "$tmp/nf.zip" -d "$fontdir"
      rm -rf "$tmp"
    fi
    # Prefer the symbols font for icon codepoints (avoids other fonts grabbing them)
    mkdir -p "$HOME/.config/fontconfig/conf.d"
    cp "$fontdir/10-nerd-font-symbols.conf" "$HOME/.config/fontconfig/conf.d/"
    have fc-cache && fc-cache -f >/dev/null
    ok "font installed (restart the terminal app to see icons)"
  fi
}

link_configs() {
  log "Linking configs to this repo"
  link "$REPO_DIR/nvim" "$HOME/.config/nvim"
  link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
}

install_tmux_plugins() {
  log "tmux plugins (tpm)"
  have tmux || { warn "tmux not found: skipped"; return; }
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$tpm" ]; then
    git clone -q https://github.com/tmux-plugins/tpm "$tpm"
  fi
  "$tpm/bin/install_plugins" >/dev/null
  ok "tmux plugins installed (in a running tmux: prefix + r to reload)"
}

install_nvim_plugins() {
  log "Neovim plugins (lazy.nvim, versions from lazy-lock.json)"
  "$NVIM_BIN" --headless "+Lazy! restore" +qa >/dev/null 2>&1 \
    || die "plugin install failed (open nvim and run :Lazy to check)"
  ok "plugins installed"

  log "Language servers via mason: $MASON_TOOLS"
  # Installs only missing ones; fails the script if any install fails.
  if MASON_TOOLS="$MASON_TOOLS" "$NVIM_BIN" --headless -c "luafile $REPO_DIR/scripts/mason-install.lua" 2>/dev/null; then
    ok "language servers ready (~/.local/share/nvim/mason)"
  else
    die "language server install failed (open nvim and run :Mason to check)"
  fi
}

# ------------------------------------------------------------------ main
log "devenv_hj: $OS $ARCH, repo $REPO_DIR"
[ "$DO_PACKAGES" -eq 1 ] && install_packages
install_nvim
[ "$DO_FONT" -eq 1 ] && install_font
link_configs
if [ "$DO_PLUGINS" -eq 1 ]; then
  install_tmux_plugins
  install_nvim_plugins
fi

log "Done"
cat <<EOF
  - Restart the terminal app (fonts) and open nvim.
  - C/C++ projects need compile_commands.json for clangd (see README).
  - Configs are symlinks into $REPO_DIR: edit there, then git commit / push.
EOF
