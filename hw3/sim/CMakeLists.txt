cmake_minimum_required(VERSION 3.23.1)

project(serialReciever VERSION 1.0.0  LANGUAGES CXX)
add_executable(${PROJECT_NAME} main.cpp serialReciever.cpp)
target_compile_options(${PROJECT_NAME} PRIVATE -c -g -std=c++17 -Wall -W -Werror -pedantic)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)