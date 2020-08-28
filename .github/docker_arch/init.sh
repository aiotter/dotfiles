#!/bin/sh -l

export CI='true'
export GITHUB_REPOSITORY=$1
export GITHUB_SHA=$2

sudo pacman -S --noconfirm --needed git
git clone "https://github.com/${GITHUB_REPOSITORY} dotfiles"
git checkout "$GITHUB_SHA"

dotfiles/deploy/deploy.sh
