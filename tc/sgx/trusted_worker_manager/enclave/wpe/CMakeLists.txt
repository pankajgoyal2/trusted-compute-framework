# Copyright 2020 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CMAKE_MINIMUM_REQUIRED(VERSION 3.2 FATAL_ERROR)
PROJECT(libavalon-wpe-enclave  CXX)

SET(TCF_TOP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../")
SET(TCF_CORE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../")

# CMakeVariable file is included after setting TCF_TOP_DIR and TCF_CORE_DIR
# are set because they are being referenced in CMakeVariables.txt
INCLUDE(../CMakeVariables.txt)

# Set necessary environment needed to build enclave binary
SET_ENCLAVE_BUILD_ENVIRONMENT()

# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

FILE(GLOB PROJECT_HEADERS *.h ../*.h)
FILE(GLOB PROJECT_SOURCES *.cpp *.c ../*.cpp)
FILE(GLOB PROJECT_EDL wpe_enclave.edl)
FILE(GLOB PROJECT_CONFIG *.xml)
SOURCE_GROUP("Source" FILES ${PROJECT_HEADERS} ${PROJECT_SOURCES} ${PROJECT_EDL})

SET(EDL_PATH ${CMAKE_CURRENT_SOURCE_DIR}/..)

SGX_EDGE_TRUSTED(${PROJECT_EDL} ${EDL_PATH} PROJECT_EDGE_SOURCES)

SOURCE_GROUP("Generated" FILES ${PROJECT_EDGE_SOURCES})

# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# Compile targets
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# CMake likes to prepend "lib" to project name when creating library...since we
# already have lib in the project name, liblibavalon-wpe-enclave is stupid.  Stop
# CMake from doing it.
SET(CMAKE_SHARED_LIBRARY_PREFIX "")

ADD_LIBRARY(${PROJECT_NAME} SHARED ${PROJECT_HEADERS} ${PROJECT_SOURCES} ${PROJECT_EDGE_SOURCES} ${PROJECT_EDL})
SGX_SIGN_ENCLAVE(${PROJECT_NAME} ${TCF_ENCLAVE_CODE_SIGN_PEM} ${PROJECT_CONFIG})

# Configure CPP linker flags
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/avalon_wpe_enclave.lds")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-L,${TCF_TOP_DIR}/examples/apps/build/echo/workload")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-L,${TCF_TOP_DIR}/examples/apps/build/heart_disease_eval/workload")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-L,${TCF_TOP_DIR}/examples/apps/build/inside_out_demo/workload")
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-L,${TCF_TOP_DIR}/examples/apps/build/simple_wallet/workload")

# Common workload libraries have to be linked before linking worker specific
# static libraries
LINK_ENCLAVE_COMMON_WORKLOAD_LIBRARIES()

# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# ADDITIONAL LIBRARIES
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Add echo workload
TARGET_LINK_LIBRARIES(${PROJECT_NAME} -Wl,--whole-archive -lecho_wo -Wl,--no-whole-archive)
# Add heart disease eval workload
TARGET_LINK_LIBRARIES(${PROJECT_NAME} -Wl,--whole-archive -lheart_disease_eval -Wl,--no-whole-archive)
# Add example inside out workload
TARGET_LINK_LIBRARIES(${PROJECT_NAME} -Wl,--whole-archive -linside_out_eval -Wl,--no-whole-archive)
# Add simple wallet workload
TARGET_LINK_LIBRARIES(${PROJECT_NAME} -Wl,--whole-archive -lsimple_wallet -Wl,--no-whole-archive)

# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

LINK_ENCLAVE_COMMON_LIBRARIES()

#Include common directories and common target directories required by enclave
INCLUDE_ENCLAVE_COMMON_DIRECTORIES()
INCLUDE_ENCLAVE_COMMON_TARGET_DIRECTORIES()
TARGET_INCLUDE_DIRECTORIES(${PROJECT_NAME} PRIVATE ${TCF_TOP_DIR}/examples/apps)
