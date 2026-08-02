cmake_minimum_required(VERSION 3.14)
project(drivebook LANGUAGES CXX)

set(BINARY_NAME "drivebook")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_definitions(-DFLUTTER_VERSION=\"1.0.0\")
add_definitions(-DFLUTTER_VERSION_MAJOR=1)
add_definitions(-DFLUTTER_VERSION_MINOR=0)
add_definitions(-DFLUTTER_VERSION_PATCH=0)
add_definitions(-DFLUTTER_VERSION_BUILD=0)

function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

add_subdirectory("runner")

include(flutter/generated_plugins.cmake)

set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "." COMPONENT Runtime)
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "data" COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "." COMPONENT Runtime)
