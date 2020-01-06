#!/bin/bash

DOTPATH=${PREFIX:-"$HOME/dotfiles"}
THIS_FILE_PATH=$DOTPATH/deploy/init.sh
PYTHON_VER=3.7

export DOTPATH

# Clone dotfiles repo
git clone https://github.com/aiotter/dotfiles.git "$DOTPATH"

# Install python-build
rm -rf /tmp/python-build
mkdir /tmp/python-build
cd /tmp/python-build
git clone --depth=1 git://github.com/pyenv/pyenv.git
cd pyenv/plugins/python-build
PREFIX="$HOME/local" ./install.sh

# Install Python3 to ~/local
PYTHON_VER=$(python-build --definitions | grep -E "^$(echo $PYTHON_VER | sed 's/\./\\./g')[.0-9]*$" | tail -1)
python-build $PYTHON_VER "$HOME/local"

# Install ansible
python3 -m pip install ansible

# Excute ansible
cd "$(dirname "$THIS_FILE_PATH")"
ansible-playbook ansible/setup.yml

