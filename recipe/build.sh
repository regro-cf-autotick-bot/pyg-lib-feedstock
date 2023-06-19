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

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
export LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

# export USE_MKL_BLAS=1  # only used for >0.1.0
export FORCE_NINJA=1
export EXTERNAL_PHMAP_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export EXTERNAL_CUTLASS_INCLUDE_DIR="${BUILD_PREFIX}/include/"

export PYG_CMAKE_ARGS="${CMAKE_ARGS}"

# get torch libraries for osx-arm64
# from https://github.com/conda-forge/openmm-torch-feedstock/blob/f7b09cd93f69d7213acd88dca1b0b1770b0ac2bc/recipe/build.sh#L7
LIBTORCH_DIR=${BUILD_PREFIX}
if [[ "$OSTYPE" == "darwin"* && $OSX_ARCH == "arm64" ]]; then

  LIBTORCH_DIR=${RECIPE_DIR}/libtorch
  conda list -p ${BUILD_PREFIX} >packages.txt
  cat packages.txt
  PYTORCH_PACKAGE_VERSION=$(grep pytorch packages.txt | awk -F ' ' '{print $2}')
  CONDA_SUBDIR=osx-arm64 conda create -y -p ${LIBTORCH_DIR} --no-deps pytorch=${PYTORCH_PACKAGE_VERSION} python=${PY_VER}

  export PYG_CMAKE_ARGS="${PYG_CMAKE_ARGS} -DTorch_DIR=${LIBTORCH_DIR}/lib/python${PY_VER}/site-packages/torch/share/cmake/Torch"
else
  # For everything else than osx-arm64
  TORCH_PREFIX=$(${PYTHON} -c "import torch;print(torch.utils.cmake_prefix_path)")
  export PYG_CMAKE_ARGS="${PYG_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${TORCH_PREFIX}"
fi

${PYTHON} -m pip install . -vvv

if [[ "$OSTYPE" == "darwin"* && $OSX_ARCH == "arm64" ]]; then
    # clean up, otherwise, environment is stored in package
    rm -fr ${LIBTORCH_DIR}
fi
