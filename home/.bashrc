#!/bin/bash 

source ~/.bash/boxen # Load Boxen

source ~/.bash/colors # Load color aliases
source ~/.bash/functions # Load functions
source ~/.bash/shell # Shell behavior
source ~/.bash/path # Add the right things to the path

source ~/.bash/completion/git # Git completion

source ~/.bash/theme # Load PS1 theme
source ~/.bash/aliases # Load aliases at end to not conflict with anything

source ~/.bash/chruby # Load rbenv
source ~/.bash/ruby # Set absurdly high GC parameters for Ruby

export GOPATH=~/code/godis
