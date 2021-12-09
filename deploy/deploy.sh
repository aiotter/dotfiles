#!/bin/bash

# This script can be called multiple times after initialization

# SETTINGS
PYTHON_VER=3.8

# VARIABLES
THIS_FILE_DIR_PATH=$(cd "$(dirname "$0")"; pwd)
export DOTPATH=${DOTPATH:-"$THIS_FILE_DIR_PATH"}
export HOME_LOCAL=$HOME/.local
export PATH=$HOME_LOCAL/bin:$DOTPATH/bin:$PATH

# FUNCTIONS
function is-apple-id-logged-in() {
  /usr/libexec/PlistBuddy -c "print :Accounts:0:LoggedIn" ~/Library/Preferences/MobileMeAccounts.plist >/dev/null 2>&1
}


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

# Create auto-removable SUDO_ASKPASS if PASSWORD is defined
# Use with care: SUDO_ASKPASS should not be exported
if [ -n ${PASSWORD+x} ]; then
  trap '[[ -n ${SUDO_ASKPASS-} ]] && rm -f "$SUDO_ASKPASS"' EXIT
  SUDO_ASKPASS=$(mktemp "/tmp/sudo-askpass.XXXXXX")
  cat <<- EOF >$SUDO_ASKPASS
	#!/bin/bash
	echo "$PASSWORD"
	EOF
  chmod 500 "$SUDO_ASKPASS"
fi
unset -v PASSWORD

# Check if you are ready to run this script
if [ "$(uname)" = 'Darwin' ] && { ! is-apple-id-logged-in || [ "$CI" = 'true' ]; }; then
  echo 'You need to be logged into Apple account!'
fi

# Arch Linux specific things
if type pacman >/dev/null 2>&1; then
  # Install dependencies
  SUDO_ASKPASS="${SUDO_ASKPASS}" sudo -A pacman -Syu --noconfirm
  SUDO_ASKPASS="${SUDO_ASKPASS}" sudo -A pacman -S --noconfirm --needed base-devel gnupg unzip

  if ! type yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit 1
    makepkg -si --noconfirm
  fi

  # needed by cargo
  eval `ssh-agent -s`
  ssh-add
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
  PYTHON_CONFIGURE_OPTS='--enable-optimizations' python-build "$PYTHON_VER" "$HOME_LOCAL"
fi

# Install ansible and its dependencies
if ! type ansible >/dev/null 2>&1; then
  echo 'Installing ansible...'
  "$HOME_LOCAL/bin/python3" -m pip -q install -U "ansible==5.0.*" psutil
fi

# Install ansible modules, which fails when the permission of ~/.netrc != 600
[ "$(perl -e 'printf "%03o\n", (stat($ENV{"HOME"}."/.netrc"))[2] & 0777' 2>/dev/null)" != 600 ] && chmod 600 ~/.netrc
ansible-galaxy collection install community.general kewlfft.aur

# Excute ansible
cd "$THIS_FILE_DIR_PATH" || exit 1
export ANSIBLE_CONFIG='ansible/ansible.cfg'
if [ "$CI" = 'true' ]; then
  # on GitHub Actions
  ansible-playbook ansible/setup.yml --skip-tags no-ci
elif [ -e "${SUDO_ASKPASS}" ]; then
  ls -l "$SUDO_ASKPASS"
  SUDO_ASKPASS="${SUDO_ASKPASS}" ansible-playbook ansible/setup.yml --extra-vars "ansible_become_pass='$("$SUDO_ASKPASS")'"
else
  ansible-playbook ansible/setup.yml
fi

mackup restore
