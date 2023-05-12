#!/bin/bash
# This line tells the system this script should be executed using the bash shell.

set -e
# This command causes the script to exit if any invoked command fails.

./pbuild.sh
# Executes the pbuild.sh script, which is presumably a project build script.

prj=`basename "$PWD"`
# Assigns the base name of the current working directory (i.e., the project name) to the variable "prj".

module load plgrid/tools/cmake plgrid/libs/fftw/3.3.9 plgrid/libs/mkl/2021.3.0 plgrid/tools/intel/2021.3.0
# Loads specific versions of CMake, FFTW, MKL, and Intel compiler using the module software management system.

# Print each command to the standard error output (usually the terminal) before it's executed.
set -x

mpiexec -np 8 ./qsf-${prj}-im $@ -r
# Runs the imaginary part executable of the project in parallel using MPI with 8 processes. 
# The "$@" allows passing any additional arguments to the command.

mpiexec -np 8 ./qsf-${prj}-re $@ -r
# Runs the real part executable of the project in parallel using MPI with 8 processes. 
# The "$@" allows passing any additional arguments to the command.
