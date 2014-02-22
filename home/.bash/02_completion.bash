#!/bin/bash

for file in /usr/local/etc/bash_completion.d/*; do
  source $file
done
