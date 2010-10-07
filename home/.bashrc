#!/bin/bash

# Cock="$(tput setaf 0)"
BlackBG="$(tput setab 0)"

DarkGrey="$(tput bold ; tput setaf 0)"
LightGrey="$(tput setaf 7)"
LightGreyBG="$(tput setab 7)"

White="$(tput bold ; tput setaf 7)"

Red="$(tput setaf 1)"
RedBG="$(tput setab 1)"
LightRed="$(tput bold ; tput setaf 1)"

Green="$(tput setaf 2)"
GreenBG="$(tput setab 2)"
LightGreen="$(tput bold ; tput setaf 2)"

Brown="$(tput setaf 3)"
BrownBG="$(tput setab 3)"

Yellow="$(tput bold ; tput setaf 3)"

Blue="$(tput setaf 4)"
BlueBG="$(tput setab 4)"
LightBlue="$(tput bold ; tput setaf 4)"

Purple="$(tput setaf 5)"
PurpleBG="$(tput setab 5)"

Pink="$(tput bold ; tput setaf 5)"

Cyan="$(tput setaf 6)"
CyanBG="$(tput setab 6)"
LightCyan="$(tput bold ; tput setaf 6)"

NC="$(tput sgr0)"

# Append to the history file, don't overwrite it!
shopt -s histappend
HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Vi command mode
set -o vi

# Default browser
export BROWSER=chromium-dev # Default browser
# Setting up editor 
export EDITOR=vim # Default editor
git config --global --replace-all core.editor $EDITOR


# Add user Bin to path
PATH=$PATH:~/.bin:/usr/local/bin

# Load aliases
. ~/.bash_aliases

# Load git completion
. ~/.git_completion

parse_git_branch ()
{
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    gitver=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
  else
    return 0
  fi
  echo -e $gitver
}

branch_color ()
{
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    color=""
    if git diff --quiet 2>/dev/null >&2 
    then
      color="${Green}"
    else
      color=${Red}
    fi
  else
    return 0
  fi
  echo -ne $color' '
}

PS1="${Blue}\W/\$(branch_color)\$(parse_git_branch)${NC} "


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
