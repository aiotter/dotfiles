FROM alpine:latest

ENV PYTHON_VER 3.8
ENV HOME_LOCAL /root/.local

RUN apk update; \
    apk add --no-cache git curl bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev

RUN mkdir -p /tmp/python-build; \
    cd /tmp/python-build || exit 1; \
    git clone --depth=1 https://github.com/pyenv/pyenv.git; \
    cd pyenv/plugins/python-build/bin || exit 1; \
    PYTHON_VER=$(./python-build --definitions | grep -E "^${PYTHON_VER//./\\.}[.0-9]*$" | tail -1); \
    if [ -e "$PREFIX/bin/python3" ]; then \
      CURRENT_PYTHON_VER=$("$PREFIX/bin/python3" -c "import platform; print(platform.python_version())"); \
    fi; \
    if [ "$PYTHON_VER" != "${CURRENT_PYTHON_VER:-}" ]; then \
      ./python-build "$PYTHON_VER" "$HOME_LOCAL"; \
    fi; \
    rm -rf /tmp/python-build

RUN apk add --update --no-cache neovim

SHELL ["/bin/bash", "-l", "-c"]
RUN mkdir -p /root/.config/nvim; \
    { echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after'; \
      echo 'let &packpath=&runtimepath'; \
      curl -sL https://raw.githubusercontent.com/aiotter/dotfiles/master/.vimrc; } >/root/.config/nvim/init.vim
RUN nvim -e +q!

WORKDIR /src

# ENTRYPOINT ["nvim"]
ENTRYPOINT ["bash"]
# CMD ["/src"]
