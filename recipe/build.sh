#!/bin/bash
set -ex

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

# export USE_MKL_BLAS=1  # only used for >0.1.0
export Torch_DIR=$(python -c 'import torch; print(torch.utils.cmake_prefix_path)')

export FORCE_NINJA=1
export EXTERNAL_PHMAP_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export EXTERNAL_CUTLASS_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export PYG_CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DPython3_EXECUTABLE=${PYTHON}"

if [ "$target_platform" = "osx-arm64" ]; then
  export PYG_CMAKE_ARGS="${PYG_CMAKE_ARGS} -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

python -m pip install . -vvv
