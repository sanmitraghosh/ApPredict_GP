#!/bin/sh

# You will need to change the below line to match the LD_LIBRARY_PATH used on your system.
export LD_LIBRARY_PATH=/home/pmzgm/git/chaste/lib:/usr/lib/petscdir/3.6.2/x86_64-linux-gnu-real-debug/lib:/home/pmzgm/git/chaste/lib

exec ./ApdCalculatorApp  "$@"
