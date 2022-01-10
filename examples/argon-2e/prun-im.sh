#!/bin/bash
set -e
./pbuild.sh
prj=`basename "$PWD"`
module load plgrid/tools/cmake plgrid/libs/fftw/3.3.9 plgrid/libs/mkl/2021.3.0 plgrid/tools/intel/2021.3.0
for i in 256 1024 4096;  
do 
    mpiexec -np 8 ./qsf-argon-2e-im -r --nodes $i --dx 0.5 --flux-quiver-ratio 0.5; 
done