cmake_minimum_required(VERSION 3.12)
project(domainNameServer)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_executable(domainNameServer
        nbproject/private/c_standard_headers_indexer.c
        nbproject/private/cpp_standard_headers_indexer.cpp
        DBentry.cpp
        DBentry.h
        Main.cpp
        TreeDB.cpp
        TreeDB.h
        TreeNode.cpp
        TreeNode.h)
