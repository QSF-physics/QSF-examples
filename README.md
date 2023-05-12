# Examples for QSF library

## Introduction
This repository hosts example projects for the QSF, a header-only C++ physics library. 

QSF is a project aimed at providing *efficient* and *general* numerical tools in
the field of Strong Field Laser Physics.

It's modular design based extensively on C++ templates and modern C++17/20 features, 
allows for creating clear and understandable projects keeping the **physics** first.

The examples include three-electron reduced-dimensionality models (`examples/nitrogen-3e`) and some simpler projects.

## Requirements

* compiler with C++17 support 
  > clang, gcc 9.1 or higher recommended
* cmake 3.8
* mpi library
  > e.g. openmpi, mpich
* fftw3 library
  > note: intel-provided fftw libraries might cause problems at the moment

### MacOS instructions

```bash
	xcode-select --install
  brew install cmake
  brew install gcc
  brew install openmpi
  brew install fftw
``` 

To adhere to the used formatting install also `clang-format`:

```bash
	brew install clang-format
```

## Usage

Download the repository recursively and navigate to the directory using:

```bash
git clone https://github.com/QSF-physics/QSF-examples.git --recurse-submodules 
cd QSF-examples
```

configure the project using one of the provided scripts (depending on the compiler), e.g:

```bash
./configure-gcc13
```
run any of the example projects (e.g. template-ini) using the `run.sh` script:

```bash
./run template-ini
```

You can inspect the scripts together with the `CMakeLists.txt` file in case of problems or if you'd like to learn more.

In case of problems look into `FAQ.md`

## Starting a new project

You can use any of the existing projects gathered in the `examples` folder as the starting point for your own projects.

It is advised to keep the name of the directory and the main `.cpp` filename identical.

There are three ways to provide configurations to a project:
- command line options (handled by `cxxopts` library, see nitrogen-3e)
- ini file (called `project.ini`) located next to the source file
- hardcoded in the `.cpp` file

You can mix all three ways simultanously within a project, but objects usually require
one or the other, in example the CAP (Complex Absorbing Potential) can be initialized either by passing the arguments to the object or by passing a `Section` of read ini file:

```cpp
	CAP(Base base, ind nCAP);
	CAP(Section& settings): Base(settings);
```
Examples of each can be found in the `examples directory`.


## Roadmap:

1. Restructure the project so that the order of imports doesn't matter
2. Improve type deduction in template function/classes
3. Load configs using .env variables rather than ini files
4. Swap the custom logging solution for spdlog
