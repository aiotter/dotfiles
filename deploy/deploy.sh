#!/bin/bash

PYTHON_VER=3.8

THIS_FILE_DIR_PATH=$(cd "$(dirname "$0")"; pwd)
export DOTPATH=${DOTPATH:-"$THIS_FILE_DIR_PATH"}
export HOME_LOCAL=$HOME/.local
export PATH=$HOME_LOCAL/bin:$PATH

# Get password for sudo if not yet input
if [ -z ${PASSWORD+x} ] && ! sudo -nk true 2>/dev/null; then
  printf "Password for sudo: "
  read -rs PASSWORD </dev/tty
  printf "\n"
  while ! (echo "$PASSWORD" | sudo -S true >/dev/null 2>&1); do
    printf "Password incorrect. Retry: "
    read -rs PASSWORD </dev/tty
    printf "\n"
  done
fi

# Install dependencies (Arch Linux)
if type pacman >/dev/null 2>&1; then
  echo "$PASSWORD" | sudo -S pacman -Syu --noconfirm
  echo "$PASSWORD" | sudo -S pacman -S --noconfirm --needed base-devel gnupg

  if ! type yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit 1
    makepkg -si --noconfirm
  fi
fi

# Install python-build if not installed
if ! which python-build >/dev/null 2>&1; then
  rm -rf /tmp/python-build
  mkdir /tmp/python-build
  cd /tmp/python-build || exit 1
  git clone --depth=1 git://github.com/pyenv/pyenv.git
  cd pyenv/plugins/python-build || exit 1
  PREFIX="$HOME_LOCAL" ./install.sh
fi

# Install Python3 to ~/local
PYTHON_VER=$(python-build --definitions | grep -E "^${PYTHON_VER//./\\.}[.0-9]*$" | tail -1)
if [ -e "$HOME_LOCAL/bin/python3" ]; then
  CURRENT_PYTHON_VER=$("$HOME_LOCAL/bin/python3" -c "import platform; print(platform.python_version())")
fi
if [ "$PYTHON_VER" != "${CURRENT_PYTHON_VER:-}" ]; then
  python-build "$PYTHON_VER" "$HOME_LOCAL"
fi

# Install ansible and its dependencies
if ! type ansible >/dev/null 2>&1; then
  echo 'Installing ansible...'
  "$HOME_LOCAL/bin/python3" -m pip -q install -U ansible psutil
fi

# Install ansible modules
ansible-galaxy install kewlfft.aur

# Excute ansible
cd "$THIS_FILE_DIR_PATH" || exit 1
export ANSIBLE_CONFIG='ansible/ansible.cfg'
if sudo -nk true 2>/dev/null; then
  # if sudo password is not needed (like GitHub Actions)
  ansible-playbook ansible/setup.yml
else
  # if sudo password is needed: use the password stored beforehand
  ansible-playbook ansible/setup.yml --extra-vars "ansible_become_pass='$PASSWORD'"
fi
