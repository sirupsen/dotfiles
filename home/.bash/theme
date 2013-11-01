#!/bin/bash

# Git prompt
if [ -r /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  # Show a * (unstaged) or + (staged) 
  export GIT_PS1_SHOWDIRTYSTATE=1
  source /usr/local/etc/bash_completion.d/git-prompt.sh

  # Enclosing (\[\]) around colors to avoid word-wrap weirdo stuff
  # (http://ubuntuforums.org/showthread.php?t=234232)
  # Use __git_ps1 for a faster prompt.
  PROMPT_COMMAND='__git_ps1 "\[$LIGHT_RED\]\W\[$YELLOW\]" " \[$NORMAL\]$ "'

# Fall back prompt
else
  PS1='\[$LIGHT_RED\]\h@\W\[$YELLOW\]$(__git_ps1 " (%s)") \[${NORMAL}\]$ '
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
