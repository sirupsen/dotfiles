#!/bin/bash
# Links everything in home/ to ~/, does sanity checks.
# By Simon Eskildsen (github.com/Sirupsen)

function symlink {
  ln -nsf $1 $2
}

for file in home/.[^.]*; do
  path="$(pwd)/$file"
  base=$(basename $file)
  target="$HOME/$(basename $file)"

  if [[ -h $target && ($(readlink $target) == $path)]]; then
    echo -e "\e[90m~/$base is symlinked to your dotfiles.\e[39m"
  elif [[ -f $target && $(md5 $path) == $(md5 $target) ]]; then
    echo -e "\e[32m~/$base exists and was identical to your dotfile. Overriding with symlink.\e[39m"
    symlink $path $target
  elif [[ -a $target ]]; then
    read -p "\e[33m~/$base exists and differs from your dotfile. Override?  [yn]\e[39m" -n 1

    if [[ $REPLY =~ [yY]* ]]; then
      symlink $path $target
    fi
  else
    echo -e "\e[32m~/$base does not exist. Symlinking to dotfile.\e[39m"
    symlink $path $target
  fi
done
