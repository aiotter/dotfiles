# dotfiles
export DOTPATH=$HOME/dotfiles

# General settings
export LANG=ja_JP.UTF-8
export HOME_LOCAL=$HOME/.local
export PATH=$HOME_LOCAL/bin:$DOTPATH/bin:/usr/local/bin:$PATH

# Editor
if type nvim >/dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
export GIT_EDITOR=$EDITOR

# Go
export GOPATH=$HOME/dev/go
export PATH=$PATH:$GOPATH/bin

# JavaScript / TypeScript
export PATH="$HOME/.deno/bin:$PATH"

# Python
alias py=python3
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:$PATH"

# Rust
export CARGO_HOME="$HOME/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export PATH="$CARGO_HOME/bin:$PATH"

# My commands
FPATH=$DOTPATH/zsh/fbin:$FPATH
autoload -Uz $(ls -1 "$DOTPATH/zsh/fbin")
alias repo=exghq

# colouring commands
alias ls='ls --color'
alias grep='grep --color'

# aliases
alias lg='lazygit'
alias grep='better-grep'

# less: mouse support
if (( $(less -V | head -1 | cut -d ' ' -f 2) >= 542 )); then
  export LESS='--mouse --wheel-lines=3 --use-color --RAW-CONTROL-CHARS'
  export MANPAGER='less -is'
fi

# Load local profile
[ -e ~/.local_profile ] && source ~/.local_profile

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
setopt NO_SHARE_HISTORY
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
bindkey '[27;2;9~' reverse-menu-complete  # Shift-TAB

# vim mode
bindkey -v
KEYTIMEOUT=5


# ------------- Settings for zinit ------------- #
#  Put these settings at the bottom of the file  #
# ---------------------------------------------- #
if [ ! -e "${HOME}/.zinit/bin/zinit.zsh" ]; then
  mkdir ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# ----- Plugins -----
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zinit ice wait lucid
zinit light jeffreytse/zsh-vi-mode

zinit ice wait lucid from'gh-r' as'command'
zinit light muesli/duf

# zinit ice wait lucid from'gh-r' as'command' \
#   mv'exa-* -> exa' atload'alias ls="exa --icons --time-style=long-iso"'
# zinit light ogham/exa

zinit ice wait lucid from'gh-r' as'command' pick'bat-*/bat'
zinit light sharkdp/bat

zinit ice wait lucid
zinit light b4b4r07/enhancd
export ENHANCD_DOT_ARG='...'

zinit ice wait lucid
zinit snippet OMZ::plugins/extract/extract.plugin.zsh

zinit ice wait lucid make'install' src'misc/quitcd/quitcd.bash_zsh' \
  atload'alias nnn="n -e"'
zinit light jarun/nnn

zinit ice wait lucid as'command' make atclone"./autogen.sh && ./configure --prefix=$ZPFX" atpull'%atclone' pick"htop"
zinit light KoffeinFlummi/htop-vim

# alias GNU utility
zinit ice wait lucid
zinit snippet PZT::modules/gnu-utility/init.zsh

# zinit ice wait lucid from'gh-r' as'command' pick'peco*/peco'
# zinit light peco/peco

zinit wait lucid light-mode for \
  from'gh-r' as'command'          junegunn/fzf-bin \
  as'command' pick'bin/fzf-tmux'  junegunn/fzf

# zinit ice wait lucid from'gh-r' as'command' pick'hub-*/bin/hub'
# zinit light github/hub
# zinit ice wait lucid as'completion' mv'hub.zsh_completion -> _hub' blockf
# zinit snippet https://github.com/github/hub/blob/master/etc/hub.zsh_completion

# extensions in dotfiles
zinit ice wait lucid multisrc"*.zsh"
zinit light "$DOTPATH/zsh/plugins"


# ----- Completions -----
zinit ice wait lucid
zinit snippet PZT::modules/completion/init.zsh

zinit ice wait lucid as'null' \
  atload'zstyle ":completion:*:*:git:*" script "$(pwd)/git-completion.bash"'
zinit snippet https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
zinit ice wait lucid blockf as'completion' mv'git-completion.zsh -> _git'
zinit snippet https://github.com/git/git/blob/master/contrib/completion/git-completion.zsh

zinit ice wait lucid blockf as'completion'
zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice wait lucid atload"zicompinit; zicdreplay" blockf
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# switch to tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  tmux new-session -A -s main
fi
