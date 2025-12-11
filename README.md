# hft-llvm
Utilizes LLVM-based compilation pipeline that compiles C++ order book engines into a single-core, cache-tuned, fence-free binary.


# How to run
- mkdir build
- cd build
- cmake ..
- make
- cd ~/hft-llvm
- ./run.sh -c benchmarks/hft/orderbook.cpp
