rename_tmux_window_to_current_dir() {
  if [[ "$TERM" == "screen-256color" && -n "$TMUX" ]]; then
    if [[ "$PWD" != "$LPWD" ]]; then
      LPWD="$PWD"
      tmux rename-window ${PWD//*\//}
    fi
  fi
}

export PROMPT_COMMAND=rename_tmux_window_to_current_dir
