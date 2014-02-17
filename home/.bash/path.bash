#!/bin/bash

# Homebrew, high priority
if [ -d /usr/local/bin ]; then
  export PATH=/usr/local/bin:$PATH
  export PATH=$PATH:/usr/local/sbin
fi

# NPM, low priority
if [ -d /usr/local/share/npm/bin ]; then
  export PATH=$PATH:/usr/local/share/npm/bin
fi

if [[ -n $SHOPIFY_DEV_VAGRANT ]]; then
  export GOPATH=~/src/go
else
  export GOPATH=~/code/go
fi

export PYTHONPATH=/usr/local/lib/python2.7/site-packages                        
export VAGRANT_DEFAULT_PROVIDER="vmware_fusion" 
