cmake_minimum_required(VERSION 3.24 FATAL_ERROR)

# Select "Release" as the default build type.
# This can be altered by setting -DCMAKE_BUILD_TYPE
# in the command-line interface to Release or Debug.
# No reason to set CMAKE_CONFIGURATION_TYPES if it's 
# not a multiconfig generator. Also no reason mess 
# with CMAKE_BUILD_TYPE if it's a multiconfig generator.
# https://stackoverflow.com/a/31548693/5729690
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE) 
else()
    if(NOT CMAKE_BUILD_TYPE)
        message(STATUS "Defaulting to Release build type")
        set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
    endif()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY HELPSTRING "Choose the type of build")
    # set the valid options for cmake-gui drop-down list
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug;Release")
endif()

# Adding CMAKE_PREFIX_PATH, needed for static builds
list(APPEND CMAKE_PREFIX_PATH /opt/rocm/llvm /opt/rocm )
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ROCM_PATH}/lib/cmake/hip /opt/rocm/lib/cmake/hip /opt/rocm/hip/cmake)

project(hello_hip
  LANGUAGES CXX C HIP
)

# begin /* Dependencies directory */
set(PROJECT_DEPS_DIR externals)
# end /* Dependencies directory */

# begin /* Include cmake modules */
include(${PROJECT_SOURCE_DIR}/cmake/FetchHIP.cmake)
# end /* Include cmake modules */

## Set the directory where the binaries will be stored
set(EXECUTABLE_OUTPUT_PATH
  ${PROJECT_BINARY_DIR}/bin
  CACHE PATH
  "Directory where all executables will be stored")

## Set the directory where the libraries will be stored
set(LIBRARY_OUTPUT_PATH
  ${PROJECT_BINARY_DIR}/lib
  CACHE PATH
  "Directory where all the libraries will be stored")

## Export compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)

############ ADD LIBRARY: HELLO_HIP ############
add_library(hello_hip)


####################################################
############### SET SM ARCHITECTURE ################
####################################################

## Note: This applies to NVBench as well.
## Can be used for applications by extracting the
## HIP_ARCHITECTURES property from hello_hip project.
## see: get_target_properties()
## see: https://github.com/RadeonOpenCompute/rocminfo/blob/master/rocm_agent_enumerator#L12
set(CMAKE_HIP_ARCHITECTURES gfx908)

####################################################
############### SET TARGET PROPERTIES ##############
####################################################
set_target_properties(hello_hip 
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    HIP_STANDARD 17
    HIP_STANDARD_REQUIRED ON
    HIP_EXTENSIONS OFF
    HIP_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES}
)

####################################################
############ TARGET COMPILER DEFINITIONS ###########
####################################################
target_compile_definitions(hello_hip
  PRIVATE
    __HIP_PLATFORM_AMD__
)

message(STATUS "hello_hip HIP Architecture: ${CMAKE_HIP_ARCHITECTURES}")

####################################################
############ TARGET COMPILE FEATURES ###############
####################################################
target_compile_features(hello_hip PRIVATE cxx_std_17)
set(HELLO_HIP_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(HELLO_HIP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

include(src/CMakeLists.txt)


####################################################
############ TARGET INCLUDE DIRECTORIES ############
####################################################
target_include_directories(hello_hip
  PUBLIC ${HELLO_HIP_INCLUDE_DIR}
  PRIVATE /opt/rocm/include
  PRIVATE /opt/rocm/hip/include/
)

####################################################
############ TARGET LINK LIBRARIES #################
####################################################
target_link_directories(hello_hip 
    PRIVATE /opt/rocm/lib
)

# target_link_libraries(hello_hip
#   INTERFACE rocrand
#   INTERFACE rocsparse
# )

####################################################
################# TARGET SOURCES ###################
####################################################
target_sources(hello_hip
    PRIVATE ${HELLO_HIP_SOURCE}
)

####################################################
############## SET CXX & HIP FLAGS ################
####################################################
set(CXX_FLAGS 
  $<$<CXX_COMPILER_ID:MSVC>:
    /W4
  >
  $<$<CXX_COMPILER_ID:GNU>:
    -Wall 
    # -Wextra
    -Wno-unused-result
    -Wno-unused-local-typedefs
    -Wno-strict-aliasing
    -Wno-unused-function
    -Wno-format-security
    # -Werror
    # -vvv
  >
  $<$<CXX_COMPILER_ID:CLANG>:
    -Wno-unused-result
    -Wno-deprecated-builtins
    -Wno-ignored-attributes
    "-Wno-\#pragma-messages"
  >
)

set(HIP_FLAGS
  --offload-arch=${CMAKE_HIP_ARCHITECTURES}
  # -fgpu-sanitize          # Enable sanitizer for AMDGPU target
  # -mamdgpu-ieee           # Sets the IEEE bit in the expected default floating point  mode register. 
                            # Floating point opcodes that support exception flag gathering quiet and 
                            # propagate signaling NaN inputs per IEEE 754-2008. This option changes the ABI. (AMDGPU only)
  # -mcode-object-v3        # Legacy option to specify code object ABI V3 (AMDGPU only)
                            # Specify code object ABI version. 
                            # Allowed values are 2, 3, 4, and 5. Defaults to 4. (AMDGPU only)
  # -mcumode                # Specify CU wavefront execution mode (AMDGPU only)
  # -mno-code-object-v3     # Legacy option to specify code object ABI V2 (AMDGPU only)
  # -mno-cumode             # Specify WGP wavefront execution mode (AMDGPU only)
  # -mno-sram-ecc           # Legacy option to specify SRAM ECC mode (AMDGPU only)
  # -mno-tgsplit            # Disable threadgroup split execution mode (AMDGPU only)
  # -mno-wavefrontsize64    # Specify wavefront size 32 mode (AMDGPU only)
  # -msram-ecc              # Legacy option to specify SRAM ECC mode (AMDGPU only)
  # -mtgsplit               # Enable threadgroup split execution mode (AMDGPU only)
  # -munsafe-fp-atomics     # Enable unsafe floating point atomic instructions (AMDGPU only)
  # -mwavefrontsize64       # Specify wavefront size 64 mode (AMDGPU only)
  # -mxnack                 # Legacy option to specify XNACK mode (AMDGPU only)
  
  # Suppress warnings.
  -Wno-unused-result
  -Wno-deprecated-builtins
  -Wno-ignored-attributes
  "-Wno-\#pragma-messages"
)

####################################################
############ TARGET COMPILE OPTIONS ################
####################################################
target_compile_options(hello_hip INTERFACE 
  $<$<COMPILE_LANGUAGE:CXX>:${CXX_FLAGS}>
  $<$<COMPILE_LANGUAGE:HIP>:${HIP_FLAGS}>
)

####################################################
############ BUILD EXAMPLE APPLICATIONS ############
####################################################
option(HELLO_HIP_BUILD_EXAMPLES
  "If on, builds the example applications."
  ON)

# Subdirectories for examples, testing and documentation
if(HELLO_HIP_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif(HELLO_HIP_BUILD_EXAMPLES)

####################################################
################ BUILD UNIT TESTS  #################
####################################################
option(HELLO_HIP_BUILD_TESTS
  "If on, builds the unit tests."
  OFF)

# Subdirectories for examples, testing and documentation
if(HELLO_HIP_BUILD_TESTS)
  include(${PROJECT_SOURCE_DIR}/cmake/FetchGoogleTest.cmake)
#   add_subdirectory(unittests)
endif(HELLO_HIP_BUILD_TESTS)