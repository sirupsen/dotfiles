#!/bin/bash

if [[ -r /usr/local/share/chruby/chruby.sh && -z $SHOPIFY_DEV_VAGRANT ]]; then
  source /usr/local/share/chruby/chruby.sh
  RUBIES=(~/.rubies/*)

  # switch to latest stable
  chruby $(chruby | grep -v trunk | tail -n1 | awk '{print $1}')

  source /usr/local/share/chruby/auto.sh
fi
