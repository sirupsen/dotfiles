#!/bin/bash

# Homebrew
if [ -d /usr/local/bin ]; then
  export PATH=/usr/local/bin:$PATH
  export PATH=$PATH:/usr/local/sbin
fi

# NPM
if [ -d /usr/local/share/npm/bin ]; then
  export PATH=$PATH:/usr/local/share/npm/bin
fi

# Personal bin files
if [[ -d $HOME/.bin ]]; then
  export PATH=$PATH:$HOME/.bin
fi

export GOPATH=~/src/go

if [[ -d $GOPATH ]]; then
  PATH="$PATH:$GOPATH/bin"
fi

# Use gnu utils instead of os x
if [[ -d /usr/local/opt/coreutils/libexec/gnubin ]]; then
  MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" 
fi

export PYTHONPATH=/usr/local/lib/python2.7/site-packages                        
export VAGRANT_DEFAULT_PROVIDER="vmware_fusion" 
