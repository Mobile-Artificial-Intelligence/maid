cmake_minimum_required(VERSION 3.10)
project(butler VERSION 1.0.0 DESCRIPTION "butler")
add_library(butler SHARED butler.cpp)
target_include_directories(butler PRIVATE ../llama.cpp)
target_link_libraries(butler llama)
set_target_properties(butler PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
