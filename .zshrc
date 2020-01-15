# dotfiles
export DOTPATH=$HOME/dotfiles

# General settings
export LANG=ja_JP.UTF-8
export EDITOR=vim
export PATH=$PATH:/usr/local/bin:$HOME/local/bin:$DOTPATH/bin

# Python
alias py=python3
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:$PATH"
FPATH="${DOTPATH}/bin:${FPATH}" autoload -Uz venvinit

# colouring commands
alias ls='ls --color'
alias grep='grep --color'

# miscellaneous
source /Applications/ccp4-7.0/bin/ccp4.setup-sh

# macOS でマルチプロセスの実行を許可
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# zsh settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt hist_reduce_blanks
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store  # do not store "history" command
setopt hist_expand
# setopt nolistbeep
setopt no_beep

# key bind
bindkey '^[OH'  beginning-of-line  # HOME
bindkey '^[[1~' beginning-of-line  # HOME
bindkey '^[OF'  end-of-line        # END
bindkey '^[[4~' end-of-line        # END
bindkey '^[[3~' delete-char        # DEL


# ---------- vim mode ----------
bindkey -v
KEYTIMEOUT=5

#### カーソル形状をinsertとnormalで変更したかったけど無理だった ####
# これが解決できない: https://unix.stackexchange.com/questions/433273/changing-cursor-style-based-on-mode-in-both-zsh-and-vim

# Change cursor shape for different vi modes.
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[1 q'
# 
#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[5 q'
#   fi
# }
# zle -N zle-keymap-select
# 
# zle-line-init() {
#     zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
#     echo -ne "\e[5 q"
# }
# zle -N zle-line-init

# zle-line-finish() { echo -ne "\e[1 q" }
# zle -N zle-line-finish
# 
# # Use beam shape cursor for each new prompt.
# _fix_cursor() {
#   echo -ne '\e[5 q'
# }
# precmd_functions+=(_fix_cursor)


# ---------- prompt ----------
autoload -Uz colors; colors
setopt prompt_subst

# Vi mode (enabling $VIMODE on $PROMPT)
VIMODE=' INS '
function zle-keymap-select {
  VIMODE="${${KEYMAP/vicmd/NORM }/(main|viins)/ INS }"
  zle reset-prompt
}
zle -N zle-keymap-select


# Get git info
# %b ブランチ情報
# %a アクション名(mergeなど)
autoload -Uz vcs_info

#formats 設定項目で %c, %u を使用
zstyle ':vcs_info:git:*' check-for-changes true

# ステージ済みのファイルがあるときの %c
zstyle ':vcs_info:git:*' stagedstr '[38;5;163m! '

# ステージされていないファイルがあるときの %u
zstyle ':vcs_info:git:*' unstagedstr '[38;5;32m+ '

# 通常時のフォーマット
zstyle ':vcs_info:*' formats '[38;5;240m> [%r] on %u%c%b[0m'

  echo -e '[0m'
#rebase 途中, merge コンフリクトなどのときのフォーマット
zstyle ':vcs_info:*' actionformats '> [%r] on %b <!%a>'


# Get venv info
venv_info() {
  VENV_INFO=""
  if [ -n "$VIRTUAL_ENV" ]; then
    VENV_INFO="venv:$(echo "$VIRTUAL_ENV" | sed -E 's@^.+/([^/]*/\.venv)@\1@' || basename "$VIRTUAL_ENV")"
  fi
}

# format
precmd() { vcs_info; venv_info }
LANG=en_US.UTF-8 vcs_info
venv_info
PROMPT='
%{$fg[cyan]%}%~%{$reset_color%} $vcs_info_msg_0_
%{$fg[cyan]%}$VIMODE%# %{$reset_color%}'
PROMPT2='> '
RPROMPT='%{$fg[green]%}$VENV_INFO%{$reset_color%} [%*]'


# ------------ Settings for zplugin ------------ #
#  Put these settings at the bottom of the file  #
# ---------------------------------------------- #
if [ ! -e "${HOME}/.zplugin/bin/zplugin.zsh" ]; then
  mkdir ~/.zplugin
  git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
fi
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin


# --- Completions ---
zplugin ice blockf
zplugin light zsh-users/zsh-completions

zplugin ice atload"_zsh_autosuggest_start"
zplugin light zsh-users/zsh-autosuggestions

zplugin light zdharma/fast-syntax-highlighting


# --- Others ---
zplugin ice wait lucid
zplugin light b4b4r07/enhancd
export ENHANCD_DOT_ARG='...'

# extract command (from oh-my-zsh)
zplugin ice wait lucid depth'1' pick'plugins/extract/extract.plugin.zsh'
zplugin light ohmyzsh/ohmyzsh

# alias GNU utility (from prezto)
zplugin ice wait lucid depth'1' pick'modules/gnu-utility/init.zsh'
zplugin light sorin-ionescu/prezto

# zplugin ice wait lucid from'gh-r' as'command' pick'peco*/peco'
# zplugin light peco/peco

zplugin wait lucid light-mode for \
  from'gh-r' as'command'          junegunn/fzf-bin \
  as'command' pick'bin/fzf-tmux'  junegunn/fzf

zplugin ice wait lucid as'command' pick'battery'
zplugin light goles/battery

zplugin ice wait lucid from'gh-r' as'command' pick'bin/hub' \
  atload'eval "$(hub alias -s)"'
zplugin light github/hub

# time previous command
ZSH_COMMAND_TIME_MIN_SECONDS=10
custom_zsh_command_time() {
  echo -en '[38;5;240m'
  printf '[%dh:%02dm:%02ds]' \
    $(($ZSH_COMMAND_TIME/3600)) $(($ZSH_COMMAND_TIME%3600/60)) $(($ZSH_COMMAND_TIME%60))
  echo -e '[0m'
}
zplugin ice wait lucid \
  atload'zsh_command_time() { custom_zsh_command_time }'
zplugin light popstas/zsh-command-time


# extensions in dotfiles
zplugin ice wait lucid multisrc"*.zsh"
zplugin light "${HOME}/dotfiles/zsh/"


# starts completion
autoload -Uz compinit
compinit
zplugin cdreplay -q

