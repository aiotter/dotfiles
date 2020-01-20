# dotfiles
export DOTPATH=$HOME/dotfiles

# General settings
export LANG=ja_JP.UTF-8
export EDITOR=vim
export PATH=$PATH:/usr/local/bin:$HOME/local/bin:$DOTPATH/bin

# Go
export GOPATH=$HOME/dev/go
export PATH=$PATH:$GOPATH/bin

# Python
alias py=python3
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:$PATH"

# My commands
FPATH=$DOTPATH/zsh/fbin:$FPATH
autoload -Uz venvinit
autoload -Uz exgit  # git subcommands with cd
alias git=exgit

# colouring commands
alias ls='ls --color'
alias grep='grep --color'

# miscellaneous
if [ -e '/Applications/ccp4-7.0/bin/ccp4.setup-sh' ]; then
  source /Applications/ccp4-7.0/bin/ccp4.setup-sh
fi

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
bindkey -rM vicmd ':' # vim-mode で混乱の元になるので解除
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


# ------------- Settings for zinit ------------- #
#  Put these settings at the bottom of the file  #
# ---------------------------------------------- #
if [ ! -e "${HOME}/.zinit/bin/zinit.zsh" ]; then
  mkdir ~/.zinit
  git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# ----- Plugins -----
zinit ice wait lucid
zinit light b4b4r07/enhancd
export ENHANCD_DOT_ARG='...'

zinit ice wait lucid
zinit snippet OMZ::plugins/extract/extract.plugin.zsh

# alias GNU utility
zinit ice wait lucid
zinit snippet PZT::modules/gnu-utility/init.zsh

# zinit ice wait lucid from'gh-r' as'command' pick'peco*/peco'
# zinit light peco/peco

zinit wait lucid light-mode for \
  from'gh-r' as'command'          junegunn/fzf-bin \
  as'command' pick'bin/fzf-tmux'  junegunn/fzf

zinit ice wait lucid as'command' pick'battery'
zinit light goles/battery

zinit ice wait lucid from'gh-r' as'command' pick'bin/hub'
zinit light github/hub

zinit ice wait lucid as'completion' blockf has'hub'
zinit snippet https://github.com/github/hub/blob/master/etc/hub.zsh_completion

# time previous command
ZSH_COMMAND_TIME_MIN_SECONDS=10
custom_zsh_command_time() {
  echo -en '[38;5;240m'
  printf '[%dh:%02dm:%02ds]' \
    $(($ZSH_COMMAND_TIME/3600)) $(($ZSH_COMMAND_TIME%3600/60)) $(($ZSH_COMMAND_TIME%60))
  echo -e '[0m'
}
zinit ice wait lucid \
  atload'zsh_command_time() { custom_zsh_command_time }'
zinit light popstas/zsh-command-time


# extensions in dotfiles
zinit ice wait lucid multisrc"*.zsh"
zinit light "$DOTPATH/zsh/plugins"


# ----- Completions -----
zinit ice wait lucid
zinit snippet PZT::modules/completion/init.zsh

zinit ice wait lucid as'completion' blockf svn \
  mv'git-completion.zsh -> _git' atpull'zinit creinstall -q .' \
  atload'zstyle ":completion:*:*:git:*" script "$(pwd)/git-completion.bash"'
zinit snippet https://github.com/git/git/trunk/contrib/completion

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting

zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

