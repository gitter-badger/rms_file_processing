cmake_minimum_required(VERSION 3.12)
project(Engine)

set(CMAKE_CXX_STANDARD 14)
set(SOURCE_FILES main.cpp hash.cpp)

add_executable(Engine ${SOURCE_FILES})