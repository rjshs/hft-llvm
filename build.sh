#!/usr/bin/env bash
set -e  # stop if any command fails

# create build dir if missing and enter it
mkdir -p build
cd build

# configure + build
cmake ..
make -j$(nproc)   # parallel build; swap for just `make` if you prefer

# return to project root
cd ..
