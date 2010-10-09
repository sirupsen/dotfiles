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
# 
parse_git_branch ()
{
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    gitver=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
  else
    return 0
  fi
  echo "($gitver)"
}

branch_color ()
{
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    color=""
    if git diff --quiet 2>/dev/null >&2 
    then
      color='\[${GREEN}\]'
    else
      color='\[${RED}\]'
    fi
  else
    return 0
  fi
  echo -ne $color
}

function __my_rvm_ruby_version {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')

  [ "$gemset" != "" ] && gemset="@$gemset"
  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')

  [ "$version" == "1.9.2" ] && version=""

  local full="$version$gemset"

  [ "$full" != "" ] && echo "$full "
}

# Description of PS1
#
# Blue: Current Directory
# Red (uncomitted changes)/Green: Branch
# No color for input
# Picture: http://ahb.me/BYp

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
