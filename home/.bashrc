#!/bin/bash 

source ~/.bash/colors.bash
source ~/.bash/shell.bash
source ~/.bash/path.bash

source ~/.bash/theme.bash
source ~/.bash/aliases.bash

source ~/.bash/ruby.bash

if [[ -n $SHOPIFY_DEV_VAGRANT ]]; then
  export GOPATH=~/src/go
else
  export GOPATH=~/code/go
fi

export PYTHONPATH=/usr/local/lib/python2.7/site-packages
export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
