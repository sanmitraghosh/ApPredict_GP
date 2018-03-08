# ApPredict_GPmat
# Gaussian process emulators for discontinuous response surfaces with applications for cardiac electrophysiology models
This repository contains the Gaussian Process related code (built using the GPML library (http://www.gaussianprocess.org/gpml/code/matlab/doc/index.html). The simulator is written in C++ and is querried using MATLAB command line.

Requirements: You need to have Chaste (https://github.com/Chaste) installed. Pull its user projects -- 1) ApPredict (https://github.com/Chaste/ApPredict) and 2) ApPredict_GP (https://github.com/sanmitraghosh/ApPredict_GP).
Compile the ApdCalculatorApp.cpp app found in <ApPredict_GP/apps/src/>. Copy the binary to the ApPredict_GPmat directory. This app uses the Chaste library to simlate APD90 values for a given conductance block.
Update the $LD_LIBRARY_PATH in matlab_wrapper.sh

Run Fig3.m & Fig4.m scripts to evaluate surface and classifier active lerning respectively. 
ApPredict_GP.m script does the actual emulation using surface and boundary (classifier) predictors trained through active learning.

