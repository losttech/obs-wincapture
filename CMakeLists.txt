cmake_minimum_required(VERSION 3.16...3.21)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/Modules")
include(VersionConfig)

# Prohibit in-source builds
if("${CMAKE_BINARY_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
  message(
    FATAL_ERROR
      "OBS: You cannot build in a source directory (or any directory with "
      "CMakeLists.txt file). Please make a build subdirectory. Feel free to "
      "remove CMakeCache.txt and CMakeFiles.")
endif()

project(obs-studio VERSION ${OBS_VERSION_CANONICAL})
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Use target folders for MSVC/Xcode/etc.
include(DeprecationHelpers)
include(ObsHelpers)
# Set default compiler flags
include(CompilerConfig)

# Allow selection of common build types via UI
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE
      "RelWithDebInfo"
      CACHE STRING
            "OBS build type [Release, RelWithDebInfo, Debug, MinSizeRel]" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Release RelWithDebInfo
                                               Debug MinSizeRel)
endif()

# Global project options
option(BUILD_FOR_DISTRIBUTION "Build for distribution (enables optimisations)"
       OFF)
option(ENABLE_UI "Enable building with UI (requires Qt)" OFF)
option(ENABLE_SCRIPTING "Enable scripting support" OFF)
option(USE_LIBCXX "Use libc++ instead of libstdc++" ${APPLE})

setup_obs_project()
mark_as_advanced(BUILD_TESTS USE_LIBCXX)

# OBS sources and plugins
# add_subdirectory(deps)
# add_subdirectory(libobs-opengl)
# if(OS_WINDOWS)
#   add_subdirectory(libobs-d3d11)
#   add_subdirectory(libobs-winrt)
# endif()
# add_subdirectory(libobs)
add_subdirectory(plugins)

# OBS main app
