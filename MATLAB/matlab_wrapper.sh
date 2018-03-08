#!/bin/sh

# You will need to change the below line to match the LD_LIBRARY_PATH used on your system.
export LD_LIBRARY_PATH=/home/sanosh/eclipse/workspace/chaste-build/lib:/usr/lib/petscdir/3.6.2/x86_64-linux-gnu-real-debug/lib:/home/sanosh/eclipse/workspace/chaste-build/lib

exec ./ApdCalculatorApp  "$@"
#./eclipse/workspace/chaste-build/projects/ApPredict_GP/apps/ApdCalculatorApp

#export CC=/system/software/arcus-b/gcc/4.8.0/bin/gcc;
#export CXX=/system/software/arcus-b/gcc/4.8.0/bin/g++
#export LD_LIBRARY_PATH=$DATA/workspace/Chaste/lib:/system/software/arcus-b/lib/PETSc/petsc-3.5/mvapich2-2.0.1__intel-2015__debug/lib:$DATA/workspace/Chaste/lib