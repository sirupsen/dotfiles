#!/bin/bash

# Colors
export COLOR_NC='\033[0m' # No Color
export COLOR_WHITE='\033[1;37m'
export COLOR_BLACK='\033[0;30m'
export COLOR_BLUE='\033[0;34m'
export COLOR_LIGHT_BLUE='\033[1;34m'
export COLOR_GREEN='\033[0;32m'
export COLOR_LIGHT_GREEN='\033[1;32m'
export COLOR_CYAN='\033[0;36m'
export COLOR_LIGHT_CYAN='\033[1;36m'
export COLOR_RED='\033[0;31m'
export COLOR_LIGHT_RED='\033[1;31m'
export COLOR_PURPLE='\033[0;35m'
export COLOR_LIGHT_PURPLE='\033[1;35m'
export COLOR_BROWN='\033[0;33m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_GRAY='\033[1;30m'
export COLOR_LIGHT_GRAY='\033[0;37m'

# Append to the history file, don't overwrite it!
shopt -s histappend
HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Vi command mode
set -o vi

# Defaults
export BROWSER=google-chrome # Default browser

# Setting up editor 
export EDITOR=vim # Default editor
git config --global --replace-all core.editor $EDITOR

PS1="\[\033]0;${USER} ${PWD}\007\]\[${COLOR_BLUE}\]\W/\[${COLOR_GRAY}\]\[${COLOR_NC}\] "
#PS1="\[${COLOR_BLUE}\]\W\[${COLOR_NC}\] "
#PS1=""

# Add user Bin to path
PATH=$PATH:~/Bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:/opt/java/jre/bin
PATH=$PATH:~/Code/Bin/gsutil

# Load aliases
. ~/.bash_aliases

# Load git completion
. ~/.git_completion

# Git configuration
USER_NAME="Sirupsen"
USER_EMAIL="sirup@sirupsen.com"
# Setting up git.
if [ -f ~/.gitconfig ]; then
  if [ "$(git config --global user.name)" != "$USER_NAME" ]; then
    echo "WARNING: git's user.name is $(git config --global user.name)"
  fi
  if [ "$(git config --global user.email)" != "$USER_EMAIL" ]; then
    echo "WARNING: git's user.email is $(git config --global user.email)"
  fi
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
