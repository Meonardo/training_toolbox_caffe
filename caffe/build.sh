#!/usr/bin/env bash

set -e

# apply OpenVINO environment
source ~/opt/intel/setupvars.sh 

# Get current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Building Caffe in $SCRIPT_DIR"

mkdir -p "$SCRIPT_DIR/build"

# Configure Caffe with CMake
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="/home/meonardo/opt/intel;/home/meonardo/opt/protobuf" \
       -DCMAKE_INSTALL_PREFIX=/home/meonardo/opt/caffe \
       -Dpython_version=3 -Wno-dev -DCMAKE_CXX_FLAGS="-std=c++14" \
       -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
       -DCUDA_ARCH_BIN="86" \
       -DCUDA_ARCH_PTX="86" \
       -DCUDA_ARCH_NAME="Manual" \
       -DOpenCV_DIR=/home/meonardo/opt/intel/lib/cmake

# Build and install Caffe
cmake --build build --target install -j$(nproc)

echo "All done"