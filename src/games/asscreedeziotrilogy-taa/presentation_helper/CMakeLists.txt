cmake_minimum_required(VERSION 3.24)
project(eziotrilogy_dx12_present LANGUAGES CXX)
if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "The Ezio Trilogy DX12 presenter requires Windows x64.")
endif()
# Pin this helper's SDK without changing the repository's vendored Streamline.
# FETCHCONTENT_SOURCE_DIR_STREAMLINE_SDK may point at an already unpacked SDK.
include(FetchContent)
FetchContent_Declare(streamline_sdk
  URL https://github.com/NVIDIA-RTX/Streamline/releases/download/v2.14.1/streamline-sdk-v2.14.1.zip
  URL_HASH SHA256=92c4d954631a1710da86ca3fa8d5034f2b9503838c95fc4ae977ae149319781b
  SOURCE_SUBDIR include
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
FetchContent_MakeAvailable(streamline_sdk)
file(READ "${streamline_sdk_SOURCE_DIR}/include/sl_version.h" streamline_version)
if(NOT streamline_version MATCHES "SL_VERSION_MAJOR 2[\r\n]" OR
   NOT streamline_version MATCHES "SL_VERSION_MINOR 14[\r\n]" OR
   NOT streamline_version MATCHES "SL_VERSION_PATCH 1[\r\n]")
  message(FATAL_ERROR "The DX12 presenter requires the pinned Streamline 2.14.1 SDK.")
endif()
find_program(FXC fxc HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../../../../bin" REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/dlaa_prepare.h"
  COMMAND "${FXC}" /nologo /WX /O3 /T cs_5_0 /E main /Vn dlaa_prepare
          /Fh "${CMAKE_CURRENT_BINARY_DIR}/dlaa_prepare.h" "${CMAKE_CURRENT_SOURCE_DIR}/dlaa_prepare.hlsl"
  DEPENDS dlaa_prepare.hlsl VERBATIM)
add_executable(renodx-asscreedeziotrilogy-dx12 main.cpp "${CMAKE_CURRENT_BINARY_DIR}/dlaa_prepare.h")
target_include_directories(renodx-asscreedeziotrilogy-dx12 PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
target_include_directories(renodx-asscreedeziotrilogy-dx12 PRIVATE "${streamline_sdk_SOURCE_DIR}/include" "${streamline_sdk_SOURCE_DIR}/external/nvapi")
target_compile_features(renodx-asscreedeziotrilogy-dx12 PRIVATE cxx_std_20)
target_compile_definitions(renodx-asscreedeziotrilogy-dx12 PRIVATE NOMINMAX)
target_link_libraries(renodx-asscreedeziotrilogy-dx12 PRIVATE d3d11 d3d12 dxgi user32 delayimp)
target_link_options(renodx-asscreedeziotrilogy-dx12 PRIVATE /DELAYLOAD:d3d11.dll /DELAYLOAD:d3d12.dll /DELAYLOAD:dxgi.dll)
set_target_properties(renodx-asscreedeziotrilogy-dx12 PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreaded)
add_executable(brotherhood-fg-camera-test EXCLUDE_FROM_ALL tests/camera.cpp)
target_compile_features(brotherhood-fg-camera-test PRIVATE cxx_std_20)
target_compile_options(brotherhood-fg-camera-test PRIVATE /UNDEBUG)
target_include_directories(brotherhood-fg-camera-test PRIVATE "${streamline_sdk_SOURCE_DIR}/include")
add_executable(brotherhood-reflex-pacing-test EXCLUDE_FROM_ALL tests/pacing.cpp)
target_compile_features(brotherhood-reflex-pacing-test PRIVATE cxx_std_20)
target_compile_options(brotherhood-reflex-pacing-test PRIVATE /UNDEBUG)
target_include_directories(brotherhood-reflex-pacing-test PRIVATE "${streamline_sdk_SOURCE_DIR}/external/nvapi")
# Build the x86 addon first to generate its embedded shaders; run this optional
# GPU fixture from the repository root with the signed runtime installed.
add_executable(brotherhood-unified-gpu-test EXCLUDE_FROM_ALL tests/unified.cpp)
target_compile_features(brotherhood-unified-gpu-test PRIVATE cxx_std_20)
target_compile_options(brotherhood-unified-gpu-test PRIVATE /UNDEBUG)
target_include_directories(brotherhood-unified-gpu-test PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../build32/asscreedeziotrilogy-taa.include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../external/reshade")
target_link_libraries(brotherhood-unified-gpu-test PRIVATE d3d11 d3d9 dxgi user32)
add_executable(brotherhood-dlaa-handoff-test EXCLUDE_FROM_ALL tests/dlaa_handoff.cpp)
target_compile_features(brotherhood-dlaa-handoff-test PRIVATE cxx_std_20)
target_compile_options(brotherhood-dlaa-handoff-test PRIVATE /UNDEBUG)
target_include_directories(brotherhood-dlaa-handoff-test PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../build32/asscreedeziotrilogy-taa.include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../external/reshade")
target_link_libraries(brotherhood-dlaa-handoff-test PRIVATE d3d11 d3d9 dxgi user32)
add_executable(brotherhood-overlay-input-test EXCLUDE_FROM_ALL tests/overlay_input.cpp)
target_compile_features(brotherhood-overlay-input-test PRIVATE cxx_std_20)
target_compile_options(brotherhood-overlay-input-test PRIVATE /UNDEBUG)
target_link_libraries(brotherhood-overlay-input-test PRIVATE user32)
