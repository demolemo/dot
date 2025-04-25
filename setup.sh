#!/usr/bin/env bash
set -euo pipefail

# ===== Configuration =====
DOTFILES_REPO="https://github.com/demolemo/dot.git"
ZSHRC_PATH="$HOME/.zshrc"
WGETRC_PATH="$HOME/.wgetrc"
ZSH_AUTOSUGGESTIONS_DIR="$HOME/.zsh/zsh-autosuggestions"

# ===== Helper Functions =====
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

function install_package() {
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -qq -y "$@"
    elif command_exists apt; then
        sudo apt update && sudo apt install -qq -y "$@"
    elif command_exists yum; then
        sudo yum install -q -y "$@"
    elif command_exists brew; then
        brew install -q "$@"
    else
        echo "Package manager not recognized. Please install $@ manually."
        exit 1
    fi
}

# ===== Main Installation =====
function install_zsh() {
    if command_exists zsh; then
        echo "zsh already installed"
        return
    fi
        
    echo "Installing zsh..."
    install_package zsh
    # Set as default shell
    sudo chsh -s "$(which zsh)" "$(whoami)"
}

function install_zsh_autosuggestions() {
    if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
        echo "Installing zsh-autosuggestions..."
        mkdir -p ~/.zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
    else
        echo "zsh-autosuggestions already installed"
    fi
}

function install_eza() {
    if command_exists eza; then
        echo "eza already installed"
        return
    fi

    local OS="$1"
    local ARCH="$2"
    local VERSION="v0.21.2"
    local BINARY_NAME
    local URL

    case "$OS-$ARCH" in
        "linux-amd64") BINARY_NAME="eza_x86_64-unknown-linux-gnu.tar.gz" ;;
        "linux-arm64") BINARY_NAME="eza_aarch64-unknown-linux-gnu.tar.gz" ;;
        "linux-arm32") BINARY_NAME="eza_arm-unknown-linux-gnueabihf.tar.gz" ;;
        *) 
            echo "Unsupported arch: ${ARCH}, go to eza releases to figure out which one you need"
            exit 1
            ;;
    esac
    
    URL="https://github.com/eza-community/eza/releases/download/${VERSION}/${BINARY_NAME}"
    local temp_file
    temp_file=$(mktemp)

    echo "Downloading eza from $URL"
    if ! wget -qO "$temp_file" "$URL"; then
        echo "Download failed" >&2
        rm -f "$temp_file"
        exit 1
    fi

    if ! sudo tar xzf "$temp_file" -C /usr/local/bin --wildcards '*/eza' --strip-components=1; then
        echo "Extraction failed" >&2
        rm -f "$temp_file"
        exit 1
    fi

    rm -f "$temp_file"
    echo "eza installed into /usr/local/bin"
}

function install_dotfiles() {
    echo "Installing dotfiles..."
    git clone "$DOTFILES_REPO" "dot"

    # move dotfiles to home directory
    mv "dot/.zshrc" $ZSHRC_PATH
    mv "dot/.wgetrc" $WGETRC_PATH

    rm -fr dot
    echo "dotfiles installed"
}

function install_additional_packages() {
    echo "Installing recommended packages..."
    local packages=(
        ripgrep
        #fd-find
        bat
    )
    install_package "${packages[@]}"
}

function set_nvim_editor() {
    local nvim_editor="nvim"

    echo "Installing the nvim editor ${nvim_editor}..."
    install_package "$nvim_editor"

    echo "Setting default editor to $nvim_editor..."
    if command_exists update-alternatives; then
        sudo update-alternatives --install /usr/bin/editor editor "$(which "$nvim_editor")" 100
        sudo update-alternatives --set editor "$(which "$nvim_editor")"
    fi

    echo "Setting EDITOR and VISUAL environment variables..."
    echo "export EDITOR=$(which "$nvim_editor")" >> ~/.zshrc
    echo "export VISUAL=$(which "$nvim_editor")" >> ~/.zshrc

    echo "Default editor set to $(which "$nvim_editor")"
}

function install_fzf() {
    if command_exists fzf; then
        echo "fzf already installed"
        return
    fi

    local OS="$1"
    local ARCH="$2"
    local VERSION="0.61.3"
    local ARCHIVE_NAME="fzf-${VERSION}-${OS}_${ARCH}.tar.gz"
    local FZF_URL="https://github.com/junegunn/fzf/releases/download/v$VERSION/${ARCHIVE_NAME}"
    local temp_file
    temp_file=$(mktemp)

    echo "Downloading fzf from $FZF_URL"
    if ! curl -sSL "$FZF_URL" -o "$temp_file"; then
        echo "Download failed, trying package manager fallback..." >&2
        rm -f "$temp_file"
        install_package fzf
        return
    fi

    if ! sudo tar xzf "$temp_file" -C /usr/local/bin; then
        echo "Extraction failed" >&2
        rm -f "$temp_file"
        exit 1
    fi

    rm -f "$temp_file"

    if [ -f /usr/local/bin/fzf ]; then
        echo "fzf installed successfully to /usr/local/bin/fzf"
    else
        echo "Installation failed - binary not found"
        exit 1
    fi
}

# ===== Main Execution =====
function main() {
    # Install basic dependencies first
    install_package git curl wget

    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Normalize architecture names
    case "$ARCH" in
        "x86_64")       ARCH="amd64" ;;
        "arm")          ARCH="arm32" ;;
        "aarch64")      ARCH="arm64" ;;
        "armv7l")       ARCH="armv7" ;;
        "armv6l")       ARCH="armv6" ;;
        "armv5l")       ARCH="armv5" ;;
        *)              echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    # Run installations
    install_zsh
    install_eza "$OS" "$ARCH"
    install_fzf "$OS" "$ARCH"
    install_zsh_autosuggestions
    install_dotfiles
    install_additional_packages
    
    # Optional installations
    # set_nvim_editor
    
    # Source the new zsh configuration
    if [ -f ~/.zshrc ]; then
        source ~/.zshrc
    fi

    # Finish the installation
    echo "=== Setup complete! ==="
    echo "Current shell is $(which zsh)"
    echo "You may need to log out and back in for changes to take effect"
}

main "$@"
