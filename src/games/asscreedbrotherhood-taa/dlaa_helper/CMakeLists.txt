cmake_minimum_required(VERSION 3.24)
project(brotherhood_dlaa LANGUAGES CXX)
if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "The Brotherhood DLAA helper requires Windows x64.")
endif()
get_filename_component(RENODX_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../../.." ABSOLUTE)
find_program(FXC fxc HINTS "${RENODX_ROOT}/bin" REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/prepare.h"
  COMMAND "${FXC}" /nologo /WX /O3 /T cs_5_0 /E main /Vn dlaa_prepare
          /Fh "${CMAKE_CURRENT_BINARY_DIR}/prepare.h" "${CMAKE_CURRENT_SOURCE_DIR}/prepare.hlsl"
  DEPENDS prepare.hlsl VERBATIM)
add_executable(renodx-asscreedbrotherhood-dlaa main.cpp "${CMAKE_CURRENT_BINARY_DIR}/prepare.h")
target_compile_features(renodx-asscreedbrotherhood-dlaa PRIVATE cxx_std_20)
target_compile_definitions(renodx-asscreedbrotherhood-dlaa PRIVATE NOMINMAX)
target_include_directories(renodx-asscreedbrotherhood-dlaa PRIVATE "${RENODX_ROOT}/external/DLSS/include" "${CMAKE_CURRENT_BINARY_DIR}")
target_link_libraries(renodx-asscreedbrotherhood-dlaa PRIVATE
  "${RENODX_ROOT}/external/DLSS/lib/Windows_x86_64/x64/nvsdk_ngx_s.lib" d3d11 dxgi advapi32)
set_target_properties(renodx-asscreedbrotherhood-dlaa PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreaded)
add_custom_command(TARGET renodx-asscreedbrotherhood-dlaa POST_BUILD
  COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${RENODX_ROOT}/external/DLSS/lib/Windows_x86_64/rel/nvngx_dlss.dll" "$<TARGET_FILE_DIR:renodx-asscreedbrotherhood-dlaa>/nvngx_dlss.dll"
  COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${RENODX_ROOT}/external/DLSS/LICENSE.txt" "$<TARGET_FILE_DIR:renodx-asscreedbrotherhood-dlaa>/NVIDIA-DLSS-LICENSE.txt")
