#!/bin/bash

# <= 2.0
# export RUBY_HEAP_MIN_SLOTS=1000000
# export RUBY_HEAP_SLOTS_INCREMENT=500000
# export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
# export RUBY_GC_MALLOC_LIMIT=99000000
# export RUBY_HEAP_FREE_MIN=100000
# export RUBYOPT=""

if [[ -r /usr/local/share/chruby/chruby.sh && -z $SHOPIFY_DEV_VAGRANT ]]; then
  source /usr/local/share/chruby/chruby.sh
  RUBIES=(~/.rubies/*)

  chruby 2.1.3

  # Allow auto-switching in directories with a .ruby-version # file
  source /usr/local/share/chruby/auto.sh
fi
