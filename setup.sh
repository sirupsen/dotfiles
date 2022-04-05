#!/usr/bin/bash

gem install homesick
homesick clone 'sirupsen/dotfiles'
homesick link dotfiles
homesick pull dotfiles

git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# function symlink {
#   ln -nsf $1 $2
# }

# for file in home/.[^.]*; do
#   path="$(pwd)/$file"
#   base=$(basename $file)
#   target="$HOME/$(basename $file)"

#   if [[ -h $target && ($(readlink $target) == $path)]]; then
#     echo -e "\x1B[90m~/$base is symlinked to your dotfiles.\x1B[39m"
#   elif [[ -f $target && $(sha256sum $path | awk '{print $2}') == $(sha256sum $target | awk '{print $2}') ]]; then
#     echo -e "\x1B[32m~/$base exists and was identical to your dotfile.  Overriding with symlink.\x1B[39m"
#     symlink $path $target
#   elif [[ -a $target ]]; then
#     read -p "\x1B[33m~/$base exists and differs from your dotfile. Override?  [yn]\x1B[39m" -n 1

#     if [[ $REPLY =~ [yY]* ]]; then
#       symlink $path $target
#     fi
#   else
#     echo -e "\x1B[32m~/$base does not exist. Symlinking to dotfile.\x1B[39m"
#     symlink $path $target
#   fi
# done

# mkdir -p ~/.config/nvim
# ln -s ~/.vimrc ~/.config/nvim/init.vim
# rm -rf ~/.config/alacritty # remove the config not linked by this

# echo "(1) sudo chsh -s /usr/local/bin/bash $(whoami)"
# echo "(2) Install plug"
# echo " curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# echo "(3) Run :PlugInstall in Vim"
