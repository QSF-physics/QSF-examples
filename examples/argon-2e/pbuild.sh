#!/bin/bash
set -e
[ $(uname) = "Darwin" ] || module load plgrid/tools/cmake plgrid/libs/fftw/3.3.9 plgrid/libs/mkl/2021.3.0 plgrid/tools/intel/2021.3.0
prj=`basename "$PWD"`
cd ../..;
rm -rf build; 
[ $(uname) = "Darwin" ] || CC=gcc CXX=g++ cmake . -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -B build; 
[ $(uname) = "Darwin" ] && CC=gcc-11 CXX=g++-11 cmake . -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -B build; 
cmake --build build --target ${prj}-im-es; 
cmake --build build --target ${prj}-re-es; 
cmake --build build --target ${prj}-im-eb; 
cmake --build build --target ${prj}-re-eb; 
cd -;