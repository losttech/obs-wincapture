project(graphics-hook)

find_package(Detours REQUIRED)
find_package(Vulkan REQUIRED)

add_library(graphics-hook MODULE)

target_sources(
  graphics-hook
  PRIVATE graphics-hook.c
          graphics-hook.h
          gl-capture.c
          gl-decs.h
          d3d8-capture.cpp
          d3d9-capture.cpp
          d3d9-patches.hpp
          dxgi-capture.cpp
          d3d10-capture.cpp
          d3d11-capture.cpp
          d3d12-capture.cpp
          ../../../deps/ipc-util/ipc-util/pipe.h
          ../../../deps/ipc-util/ipc-util/pipe-windows.c
          ../../../libobs/util/windows/obfuscate.c
          ../../../libobs/util/windows/obfuscate.h
          ../graphics-hook-ver.h
          ../graphics-hook-info.h
          ../hook-helpers.h
          graphics-hook.rc)

target_include_directories(graphics-hook PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(graphics-hook PRIVATE Detours::Detours
                                            dxguid)
target_link_options(graphics-hook PRIVATE "LINKER:/IGNORE:4099")

if(MSVC)
  target_compile_options(graphics-hook PRIVATE "$<IF:$<CONFIG:Debug>,/MTd,/MT>")
endif()

set_target_properties(
  graphics-hook
  PROPERTIES FOLDER "plugins/win-capture"
             OUTPUT_NAME
             "graphics-hook$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,64,32>")

target_compile_definitions(graphics-hook PRIVATE COMPILE_D3D12_HOOK)

function(add_target_resource target resource destination)
  install(
    FILES ${resource}
    DESTINATION ${OBS_DATA_DESTINATION}/${destination}
    COMPONENT ${target}_Runtime)

  install(
    FILES ${resource}
    DESTINATION ${OBS_DATA_DESTINATION}/${destination}
    COMPONENT obs_${target}
    EXCLUDE_FROM_ALL)
endfunction()

if(TARGET Vulkan::Vulkan)
  target_sources(graphics-hook PRIVATE vulkan-capture.c vulkan-capture.h)

  target_link_libraries(graphics-hook PRIVATE Vulkan::Vulkan)

  target_compile_definitions(graphics-hook PRIVATE COMPILE_VULKAN_HOOK)

  add_target_resource(
    graphics-hook "${CMAKE_CURRENT_SOURCE_DIR}/obs-vulkan64.json"
    "obs-plugins/win-capture/")
  add_target_resource(
    graphics-hook "${CMAKE_CURRENT_SOURCE_DIR}/obs-vulkan32.json"
    "obs-plugins/win-capture/")
endif()

set(OBS_PLUGIN_DESTINATION "${OBS_DATA_DESTINATION}/obs-plugins/win-capture/")
