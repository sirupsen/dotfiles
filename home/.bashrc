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

. ~/.credentials

# Load colors
. ~/.colors

# Load functions
. ~/.bash_functions

# Vi Bash command mode
set -o vi

# Default browser
BROWSER="chromium-browser" # Default browser

# Setting up editor 
EDITOR="vim" # Default editor

# Add user bins to path
PATH=$PATH:~/.bin:/usr/local/bin

# Load Git completion
. ~/.git_completion

# Load PS1 theme
. ~/.bash_theme

# Source RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Load aliases at end to not conflict with anything
. ~/.bash_aliases
