#!/bin/zsh

# Add `source auto_toggle_venv.zsh` to .zshrc

find-venv() {
  dir=$*
  while :
  do
    if [[ -e "${dir}/.venv" ]]
    then
      echo "$dir/.venv"
      break
    elif [[ "${dir}" = '/' ]] || [[ "${dir}" = '~' ]]
    then
      exit 0
    fi
    dir=$(dirname $dir)
  done
}

toggle-venv() {
  dir=$(find-venv $(pwd))
  if [[ -n $dir ]] && [[ "${VIRTUAL_ENV}" != ${dir} ]]
  then
    # activate venv
    source ${dir}/bin/activate
  fi

  if [[ -z $dir ]] && [[ -n "${VIRTUAL_ENV}" ]]
  then
    deactivate
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd toggle-venv
toggle-venv

# export VIRTUAL_ENV_DISABLE_PROMPT=1
