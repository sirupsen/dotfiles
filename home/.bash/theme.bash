#!/bin/bash

# Git prompt
if [ -r /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  source /usr/local/etc/bash_completion.d/git-prompt.sh
  PS1='\[$ORANGE\]\h\[$RED\]:\w\[$YELLOW\]$(__git_ps1 " (%s)") \[${NORMAL}\]$ '
else
  PS1='\[$ORANGE\]\h\[$RED\]:\w\[$YELLOW\]\[${NORMAL}\]$ '
fi

# Set window names in TMUX coresponding to the current
# directory.
if { [ -n "$TMUX" ]; } then
  set_window_name() {
    if [ "$PWD" != "$LPWD" ]; then
      LPWD="$PWD"
      tmux rename-window ${PWD//*\//}
    fi
  }
  export PROMPT_COMMAND=set_window_name;
fi
