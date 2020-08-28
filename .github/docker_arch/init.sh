#!/bin/sh -l

sudo pacman -S --noconfirm --needed git
git clone "https://github.com/${GITHUB_REPOSITORY}" dotfiles
git checkout "$GITHUB_SHA"

sudo --preserve-env --user=dot HOME=/home/dot dotfiles/deploy/deploy.sh
