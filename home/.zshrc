export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="simple"

plugins=(git rails ruby rvm rails4 github bundler aliases)

source $ZSH/oh-my-zsh.sh

# No auto correct, annoying as F@#R$
unsetopt correct_all

# Aliases
alias c='clear'

# Environment variables
export EDITOR='vim'
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/texbin:/usr/X11/bin:/usr/local/Cellar/python/2.7.1/bin:/Users/sirup/.bin:/usr/local/bin:/usr/local/lib/node

# Load RVM
source ~/.rvm/scripts/rvm
