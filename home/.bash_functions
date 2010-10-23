#!/bin/bash

# Platform information
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='darwin'
fi

mkcd () {
  mkdir -p $1
  cd $1
}
