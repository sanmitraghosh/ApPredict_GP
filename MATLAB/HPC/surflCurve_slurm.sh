#!/bin/bash --login

# Name of the job 
#SBATCH --partition=devel
#SBATCH --job-name=surflCurve

# Use 1 node with 32 cores = 32 MPI legs 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16

# Kill after one hour 
#SBATCH --time=00:09:58

# Send me email at the beginning and the end, and abortion of the run
# (I prefer the FAIL option - only send emails when the process gets aborted)
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sanmitra25@gmail.com

# Joining output and error files is done automatically by SLURM, as well as copying the environment variables,
# and the change of working directory

# Set up MPI using the appropriate include for the machine:
#. enable_arcus_b_mpi.sh

#Switch to Chaste directory
#cd ${DATA}/Arcus-GP

matlab -nodisplay -nosplash < surfCurve.m > run.log
