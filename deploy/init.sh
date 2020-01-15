#!/bin/bash

DOTPATH=${PREFIX:-"$HOME/dotfiles"}
THIS_FILE_PATH=$DOTPATH/deploy/init.sh
PYTHON_VER=3.7

export DOTPATH

# Clone dotfiles repo
if [ -d "$DOTPATH" ]; then
  git status >/dev/null 2>&1 || exit 1
  git pull
else
  git clone https://github.com/aiotter/dotfiles.git "$DOTPATH"
fi

# Install python-build if not installed
if ! which python-build >/dev/null 2>&1; then
  rm -rf /tmp/python-build
  mkdir /tmp/python-build
  cd /tmp/python-build
  git clone --depth=1 git://github.com/pyenv/pyenv.git
  cd pyenv/plugins/python-build
  PREFIX="$HOME/local" ./install.sh
fi

# Install Python3 to ~/local if not installed
if ! which python3 >/dev/null 2>&1; then
  PYTHON_VER=$(python-build --definitions | grep -E "^$(echo $PYTHON_VER | sed 's/\./\\./g')[.0-9]*$" | tail -1)
  python-build $PYTHON_VER "$HOME/local"
fi

# Install ansible
echo 'Installing ansible...'
python3 -m pip -q install -U ansible

# Excute ansible
cd "$(dirname "$THIS_FILE_PATH")"
if sudo -n true 2>/dev/null; then
  # sudo password is not needed (like GitHub Actions)
  ansible-playbook ansible/setup.yml
else
  # sudo password is needed: ask password beforehand
  ansible-playbook ansible/setup.yml -K
fi

