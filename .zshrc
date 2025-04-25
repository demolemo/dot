#!/usr/bin/env zsh

# ===== General Settings =====
# Unlimited command history
export HISTSIZE=100000
export HISTFILE="$HOME/.zsh_history"
export SAVEHIST=$HISTSIZE
export HISTTIMEFORMAT="%F %T: "
setopt INC_APPEND_HISTORY
alias history='history -100000'

# ===== Aliases =====
# Remap commands to Rust alternatives (BLAZINGLY FAST!)
alias cat=bat
alias grep=rg
alias ls=eza

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Git aliases
alias ga="git add"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias gca="git commit --amend --no-edit"
alias gl="git log"
alias gs="git status"
alias gp="git push"
alias gd="git diff"
alias gb="git branch"
alias gbd="git branch -d"
alias gpl="git pull"
alias gst="git stash"
alias grb="git rebase"

# Docker aliases
alias dcl="docker container list"
alias de="docker exec"
alias d="docker"
alias dps="docker ps"
alias dpsa="docker ps -a"

# Modern directory listing (eza)
alias ll='eza -lah --icons --git'
alias la='eza -A --icons'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Python aliases
alias python=python3
alias py=python3
alias pip=pip3
alias venv="source venv/bin/activate"

# ===== Plugins =====
# zsh-autosuggestions (if installed)
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias fzf="fzf --style minimal"

# ===== Environment Variables =====
export XDG_CONFIG_HOME=~/.config       # Consistent config location
export TERM=xterm-256color            # Terminal compatibility
export DOCKER_DEFAULT_PLATFORM=linux/amd64  # Docker platform

# ===== Shell Options =====
setopt AUTO_CD              # Type dir name to cd
setopt AUTO_PUSHD           # Auto-push directories
setopt PUSHD_IGNORE_DUPS    # No duplicates in dir stack

