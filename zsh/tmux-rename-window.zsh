#!/bin/zsh

# Git で index.lock を作成しないよう環境変数を設定
GIT_OPTIONAL_LOCKS=0

rename-window() {
  [[ -z "$TMUX" ]] && return

  git_dir=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  if [[ -n "$git_dir" ]]; then
    tmux rename-window "[${git_dir}]"
  else
    tmux rename-window "#{pane_current_command}"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd rename-window
[[ -z "$TMUX" ]] || rename-window

