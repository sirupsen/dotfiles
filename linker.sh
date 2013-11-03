#!/bin/bash

function symlink {
  ln -nsf $1 $2
}

for file in home/.[^.]*; do
  path="$(pwd)/$file"
  base=$(basename $file)
  target="$HOME/$(basename $file)"

  if [[ -h $target && ($(readlink $target) == $path)]]; then
    echo "~/$base is symlinked to your dotfiles."
  elif [[ -f $target && $(md5 $path) == $(md5 $target) ]]; then
    echo "~/$base exists and was identical to your dotfile. Overriding with symlink."
    symlink $path $target
  elif [[ -a $target ]]; then
    read -p "~/$base exists and differs from your dotfile. Override? [yn]" -n 1 -r

    if [[ $REPLY =~ [yY]* ]]; then
      symlink $path $target
    fi
  else
    echo "~/$base does not exist. Symlinking to dotfile."
    symlink $path $target
  fi
done
