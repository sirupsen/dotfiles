rename_tmux_window_to_current_dir() {
  if [[ "$TERM" == "screen-256color" && -n "$TMUX" ]]; then
    if [[ -z "$SKIP_TMUX_RENAME" ]]; then
      if [[ "$PWD" != "$LPWD" ]]; then
        LPWD="$PWD"
        tmux rename-window "${PWD//*\//}"
      fi
    fi
  fi
}

ssh() {
    if [[ -z $TMUX ]]; then
        /usr/bin/ssh $@
        return
    fi

    local remote=${@: -1}
    local old_name=$(tmux display-message -p '#W')

    if [[ -n $remote ]]; then
        tmux rename-window "$remote"
    fi

    /usr/bin/ssh $@

    tmux rename-window "$old_name"
}

if [[ ":$PROMPT_COMMAND:" != *":rename_tmux_window_to_current_dir:"* ]]; then
  export PROMPT_COMMAND="rename_tmux_window_to_current_dir;$PROMPT_COMMAND"
fi
