#!/bin/bash 

source ~/.bash/path.bash

for file in ~/.bash/*.bash; do
  source $file
done
