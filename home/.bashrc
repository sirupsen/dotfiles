#!/bin/bash

# Load credentials, sets a few environment variables
# used e.g. in the Mutt config.
#
# Sets the following variables (not in the Git tree :-)
# USERNAME=""
# PASSWORD1=""
# PASSWORD2=""
# EMAIL=""
# FULLNAME=""

if [ -f ~/.credentials ]; then
  . ~/.credentials
fi

# Load colors
. ~/.colors

# Load functions
. ~/.bash_functions

# Vi Bash command mode
set -o vi
# Case insensitive
shopt -s nocaseglob
# Ignore case while completing
set completion-ignore-case on

# Default browser
BROWSER="chromium-browser" # Default browser

# Setting up editor 
export EDITOR=/usr/bin/vim

# Pager
PAGER="vimpager"
alias less='vimpager'

# Set the environment to KDE because xdg ignoes its config file
# otherwise, yeah I'm wtfing too
DE="kde"

# Add user bins to path
PATH=$PATH:~/.bin:/usr/local/bin

if [[ $platform == 'darwin' ]]; then
  PATH=$PATH:/usr/local/lib/node
fi

# Load Git completion
. ~/.git_completion

# Load PS1 theme
. ~/.bash_theme

# Load aliases at end to not conflict with anything
. ~/.bash_aliases

# Only perform these actions on Linux
# On OS X Dropbox starts automatically and
# RVM is initialized from .cinderella.profile
if [[ $platform == 'linux' ]]; then
  dropbox start > /dev/null
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
