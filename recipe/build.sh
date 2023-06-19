#!/bin/bash
set -ex

export PATH="$PWD:$PATH"

export CC=$(basename $CC)
export CXX=$(basename $CXX)

if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
  export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
  export FORCE_CUDA=1

  # Set the CUDA arch list from
  # https://github.com/conda-forge/pytorch-cpu-feedstock/blob/2be0b38024b3b5601fcefce40596fc2a5fce4ab7/recipe/build_pytorch.sh#L94

  if [[ ${cuda_compiler_version} == 10.* ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5+PTX"
  elif [[ ${cuda_compiler_version} == 11.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0+PTX"
  elif [[ ${cuda_compiler_version} == 11.1 ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"
  elif [[ ${cuda_compiler_version} == 11.2 ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"
  else
    echo "Unsupported cuda version. edit build.sh"
    exit 1
  fi

else
  export FORCE_CUDA=0
fi

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
export LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

# export USE_MKL_BLAS=1  # only used for >0.1.0
export FORCE_NINJA=1
export EXTERNAL_PHMAP_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export EXTERNAL_CUTLASS_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export PYG_CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE=${PYTHON} -DCMAKE_INSTALL_PREFIX=${PREFIX}"
#  -DTorch_Dir=${SP_DIR}/torch

python -m pip install . -vvv
