#!/bin/bash

if [[ -d /usr/local/etc/bash_completion.d ]]; then
  for file in /usr/local/etc/bash_completion.d/*; do
    source $file
  done
fi

eval "$(fasd --init auto)"

#if [[ -d /etc/bash_completion.d ]]; then
#  for file in /etc/bash_completion.d/*; do
#    source $file
#  done
#fi
