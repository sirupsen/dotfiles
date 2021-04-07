#!/bin/bash
executable=$1
outputfile=${executable////-}  # strip out /es if executable is full path
tee "/tmp/$outputfile.in" | "$@" 2>"/tmp/$outputfile.err" | tee "/tmp/$outputfile.out"
