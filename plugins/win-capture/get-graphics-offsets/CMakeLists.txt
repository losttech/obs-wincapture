project(get-graphics-offsets)

add_executable(get-graphics-offsets)

target_sources(
  get-graphics-offsets
  PRIVATE get-graphics-offsets.c
          get-graphics-offsets.h
          dxgi-offsets.cpp
          d3d8-offsets.cpp
          d3d9-offsets.cpp
          ../nt-stuff.c
          ../nt-stuff.h
          ../graphics-hook-info.h
          ../hook-helpers.h)

target_include_directories(get-graphics-offsets
                           PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(get-graphics-offsets d3d9.lib dxgi.lib d3d11.lib)

add_definitions(-DUNICODE -D_UNICODE -D_CRT_SECURE_NO_WARNINGS)

if(MSVC)
  set(CMAKE_C_FLAGS_DEBUG "/DDEBUG=1 /D_DEBUG=1 ${CMAKE_C_FLAGS_DEBUG}")
  set(CMAKE_CXX_FLAGS_DEBUG "/DDEBUG=1 /D_DEBUG=1 ${CMAKE_C_FLAGS_DEBUG}")
  if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SAFESEH:NO")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /SAFESEH:NO")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /SAFESEH:NO")
  endif()

  target_compile_options(get-graphics-offsets
                         PRIVATE "$<IF:$<CONFIG:Debug>,/MTd,/MT>")
endif()

set_target_properties(get-graphics-offsets PROPERTIES FOLDER
                                                      "plugins/win-capture")
set_target_properties(
  get-graphics-offsets
  PROPERTIES OUTPUT_NAME
             "get-graphics-offsets$<IF:$<EQUAL:${CMAKE_SIZEOF_VOID_P},8>,64,32>"
)
