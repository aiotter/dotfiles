docker build . -t neovim-docker:latest
docker run -it --rm -v $(pwd):/src neovim-docker:latest -u smallvimrc
