# hft-llvm
Utilizes LLVM-based compilation pipeline that compiles C++ order book engines into a single-core, cache-tuned, fence-free binary.


# How to run
- ./build.sh
- ./run_atomic.sh benchmarks/hft/orderbook.cpp
- ./run_branch.sh benchmarks/hft/orderbook.cpp
- ./run_split.sh benchmarks/hft/orderbook.cpp

# Notes
- run_all still in production (for some reason some passes don't run)
- sometimes split leads to non-deterministic results (hypothesis: random seed)


