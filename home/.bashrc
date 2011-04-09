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
# Case insensitive
shopt -s nocaseglob
# Ignore case while completing
set completion-ignore-case on

# Setting up editor 
export EDITOR=/usr/bin/vim
# Add user bins to path
export PATH=$PATH:~/.bin:/usr/local/bin:/usr/local/lib/node

# Load Git completion
. ~/.git_completion

# Load PS1 theme
. ~/.bash_theme

# Load aliases at end to not conflict with anything
. ~/.bash_aliases

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
