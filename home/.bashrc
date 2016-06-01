#!/bin/bash 
source /opt/dev/dev.sh

for file in ~/.bash/*.bash; do
  source $file
done

unset DISPLAY

eval "$(fasd --init auto)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
