cmake_minimum_required(VERSION 3.12)
project(lab3_release_2)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_executable(lab3_release_2
        globals.h
        main.cpp
        shape.cpp
        shape.h)
