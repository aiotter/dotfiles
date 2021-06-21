#!/bin/bash

# This script should be called only once on initialization

export DOTPATH=${PREFIX:-"$HOME/dotfiles"}

# Get password for sudo
if ! sudo -nk true 2>/dev/null; then
  printf "Password for sudo: "
  read -rs PASSWORD </dev/tty
  printf "\n"
  while ! (echo "$PASSWORD" | sudo -S true >/dev/null 2>&1); do
    printf "Password incorrect. Retry: "
    read -rs PASSWORD </dev/tty
    printf "\n"
  done
fi

# Install git
if type pacman >/dev/null 2>&1; then
  echo "$PASSWORD" | sudo -S pacman -Syu --noconfirm
  echo "$PASSWORD" | sudo -S pacman -S --noconfirm --needed git
fi

# Clone dotfiles repo
if [ -d "$DOTPATH" ]; then
  cd "$DOTPATH" || exit 1
  git status >/dev/null 2>&1 || exit 1
  git pull
else
  git clone --recursive https://github.com/aiotter/dotfiles.git "$DOTPATH"
  cd "$DOTPATH" || exit 1
fi

export PASSWORD
deploy/deploy.sh
