# HIP Template [![ubuntu-focal](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-focal.yml/badge.svg)](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-focal.yml) [![ubuntu-jammy](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-jammy.yml/badge.svg)](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-jammy.yml)

A template inspired by [@Ahdhn](https://github.com/Ahdhn)'s [CUDATemplate](https://github.com/Ahdhn/CUDATemplate) to start a new HIP project using CMake on Linux. Note when HIP/ROCm is publicly made available on Windows and Windows Subsystem for Linux (WSL), I will update this template to reflect the support for that as well. This template provides a simple, easy-to-modify CMake file, with GitHub Actions pre-configured to build check-ins and test if the compilation succeeds.

## Installing Requirements
- `cmake` required minimum version 2.24.x:
```bash
python3 -m pip install 'cmake==3.24.0'
```
- ROCm/HIP recommended version 5.4.x or above. Installation instructions vary, please refer to the [How to Install ROCm](https://docs.amd.com/bundle/ROCm-Installation-Guide-v5.4.2/page/How_to_Install_ROCm.html). The following is an example of how to install ROCm 5.4.x, HIP and some useful libraries on an Ubuntu 22.04 system using `apt-get`:
```bash
sudo apt-get update
curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm-keyring.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/rocm-keyring.gpg] https://repo.radeon.com/rocm/apt/5.4 jammy main' | sudo tee /etc/apt/sources.list.d/rocm.list
echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | sudo tee /etc/apt/preferences.d/rocm-pin-600
```

```
sudo apt-get update
sudo apt-get install -y rocm-dev hip-dev rocm-libs
```

## Configure Environment
- Export `$PATH` for ROCm and HIP libraries by adding the following to the end of your `~\.bashrc` or `~\.bash_profile` file in your home directory, and then perform `source ~\.bashrc`. This is also illustrated in the installation of ROCm/HIP guide.
```bash
# Export ROCM/HIP Paths
export ROCM_PATH=/opt/rocm
export HIP_PATH=/opt/rocm/hip
export PATH=$HOME/.local/bin:${ROCM_PATH}/bin:${HIP_PATH}/bin:$PATH
export LD_LIBRARY_PATH=${ROCM_PATH}:${ROCM_PATH}/lib:${HIP_PATH}/lib:$LD_LIBRARY_PATH
```

## Getting Started

Assuming you have the requirements installed and configured, simply fetch the project and build using CMake to get started!

```bash
git clone https://github.com/neoblizz/HIP_template.git
cd HIP_template
mkdir build && cd build
cmake ..
make -j$(nproc)
```

This will generate the example executable in `bin` directory under `build`, which can be executed like so:
```
./bin/hello
```

## Directory Structure
This template follows a standard C++ library's directory structure. Important directories are `library/src` for source files, `library/include` for library includes, `examples` for a simple "hello world" example that uses the library, and `unittests` for GoogleTests based testing framework.
```
.
├── CMakeLists.txt
├── README.md
├── cmake
├── examples
├── externals
├── library
│   ├── include
│   └── src
├── scripts
│   └── format.sh
└── unittests
```

## License & Maintainer
- This work is **Unlicensed**. A license with no conditions whatsoever which dedicates works to the public domain. Unlicensed works, modifications, and larger works may be distributed under different terms and without source code.
- Maintained by [Muhammad Osama](https://github.com/neoblizz) \<muhammad.osama@amd.com\>
