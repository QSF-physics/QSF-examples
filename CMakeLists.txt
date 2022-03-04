cmake_minimum_required(VERSION 3.8)
project(QSF-examples)
# Prepare the library
add_subdirectory(QSF)
add_subdirectory(extern/cxxopts)
# Compile example projects
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(colors)
define_colors()


macro(Builder mod)
    get_filename_component(prj ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    string(REPLACE " " "_" prj ${prj})
    cmake_minimum_required(VERSION 3.8)
    project("${prj}${mod}" LANGUAGES CXX)
    separate_arguments(flags UNIX_COMMAND "${ARGN}")
    set(CMAKE_VERBOSE_MAKEFILE ON)
    set(CMAKE_RULE_MESSAGES OFF)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    set(CMAKE_BUILD_TYPE Release)
    # im + re version
    add_executable(${prj}${mod} "${prj}.cpp")
    target_compile_options(${prj}${mod} PUBLIC -g -O3 -ffast-math $<$<CXX_COMPILER_ID:GNU>:-march=native>) 
    target_link_libraries(${prj}${mod} PUBLIC cxxopts::cxxopts)
    target_link_libraries(${prj}${mod} PUBLIC QSF)
    set_target_properties(${prj}${mod} PROPERTIES OUTPUT_NAME "qsf-${prj}${mod}")
    target_compile_definitions(${prj}${mod} PRIVATE PROJNAME=${prj} DEBUG=223 ${flags})
    
    message(STATUS "${Yellow}Binaries for project [${Green}${prj}${mod}${Yellow}] with flags ${ARGN} will be placed in ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}${mod}${ColourReset}")
endmacro()

add_subdirectory(examples/template-ini)
add_subdirectory(examples/nitrogen-3e)
add_subdirectory(examples/neon-3e)
add_subdirectory(examples/argon-2e)
add_subdirectory(examples/helium-2e)
add_subdirectory(examples/thiede)
