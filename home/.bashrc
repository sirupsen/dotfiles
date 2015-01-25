#!/bin/bash 

for file in ~/.bash/*.bash; do
  source $file
done

eval "$(fasd --init auto)"
