#!/usr/bin/bash

gem install homesick
homesick clone 'sirupsen/dotfiles'
homesick link dotfiles
homesick pull dotfiles

git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# echo "(1) sudo chsh -s /usr/local/bin/bash $(whoami)"
# echo "(2) Install plug"
# echo " curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# echo "(3) Run :PlugInstall in Vim"
