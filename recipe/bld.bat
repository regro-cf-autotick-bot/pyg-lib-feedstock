@echo on

if "%cuda_compiler_version%" == "12.9" (
    set TORCH_CUDA_ARCH_LIST=5.0;6.0;7.0;7.5;8.0;8.6;8.9;9.0;10.0;12.0+PTX
    set FORCE_CUDA=1
) else if "%cuda_compiler_version%" == "13.0" (
    set TORCH_CUDA_ARCH_LIST=7.5;8.0;8.6;8.9;9.0;10.0;12.0+PTX
    set FORCE_CUDA=1
) else (
    set FORCE_CUDA=0
)

set DISTUTILS_USE_SDK=1

set CMAKE_INCLUDE_PATH=%LIBRARY_PREFIX%\include
set LIB=%LIBRARY_PREFIX%\lib;%LIB%

set Torch_DIR=%SP_DIR%\torch"
@REM set USE_MKL_BLAS=1

set FORCE_NINJA=1
:: unusually, parallel-hashmap is a noarch package, so the headers are elsewhere
set "EXTERNAL_PHMAP_INCLUDE_DIR=%PREFIX%/include"
set "EXTERNAL_CUTLASS_INCLUDE_DIR=%LIBRARY_INC%"

pip install . -vvv
