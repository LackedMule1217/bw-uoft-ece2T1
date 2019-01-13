cmake_minimum_required(VERSION 3.12)
project(src)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(galaxy-explorer)

add_executable(src
        galaxy-explorer/AsteroidList.cpp
        galaxy-explorer/AsteroidsObserver.cpp
        galaxy-explorer/GameAI.cpp
        galaxy-explorer/MyAIData.hpp
        Makefile)
