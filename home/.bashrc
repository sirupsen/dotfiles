# #!/bin/bash

# Normal Colors
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
BLUE=$'\e[0;34m'
WHITE=$'\e[1;37m'
BLACK=$'\e[0;30m'
YELLOW=$'\e[0;33m'
PURPLE=$'\e[0;35m'
CYAN=$'\e[0;36m'
GRAY=$'\e[1;30m'
PINK=$'\e[37;1;35m'
ORANGE=$'\e[33;40m'

# Revert color back to the normal color
NORMAL=$'\e[00m'

# LIGHT COLORS
LIGHT_BLUE=$'\e[1;34m'
LIGHT_GREEN=$'\e[1;32m'
LIGHT_CYAN=$'\e[1;36m'
LIGHT_RED=$'\e[1;31m'
LIGHT_PURPLE=$'\e[1;35m'
LIGHT_YELLOW=$'\e[1;33m'
LIGHT_GRAY=$'\e[0;37m'

# Vi command mode
set -o vi

# Default browser
BROWSER=chromium-dev # Default browser

# Setting up editor 
EDITOR=vim # Default editor
GIT_EDITOR=$EDITOR

# Add user Bin to path
PATH=$PATH:~/.bin:/usr/local/bin

# Load git completion for PS1 feature
. ~/.git_completion

# For unstaged(*) and staged(+) values next to branch name in __git_ps1
GIT_PS1_SHOWDIRTYSTATE="enabled"

# Enclosing (\[\]) around colors to avoid word-wrap weirdo stuff(http://ubuntuforums.org/showthread.php?t=234232)
PS1='\[$BLUE\]\W/\[$LIGHT_BLUE\]$(__my_rvm_ruby_version)\[$LIGHT_GREEN\]$(__git_ps1 "(%s)") \[${NORMAL}\]$ '

# Git configuration
USER_NAME="Sirupsen"
USER_EMAIL="sirup@sirupsen.com"
# Setting up git.
if [ -f ~/.gitconfig ]; then
  if [ "$(git config --global user.name)" != "$USER_NAME" ]; then
    echo "WARNING: git's user.name is $(git config --global user.name)"
    echo "Set username to $USER_NAME by issuing:"
    echo "git config --global user.name $USER_NAME"
  fi
  if [ "$(git config --global user.email)" != "$USER_EMAIL" ]; then
    echo "WARNING: git's user.email is $(git config --global user.email)"
    echo "Set email to $USER_EMAIL by issuing:"
    echo "git config --global user.email $USER_EMAIL"
  fi
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Load aliases
. ~/.bash_aliases
