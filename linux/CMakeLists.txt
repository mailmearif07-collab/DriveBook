# Project-level configuration.
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

set(BINARY_NAME "drivebook")
set(APPLICATION_ID "com.drivebook.app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

get_filename_component(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter" REALPATH)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
endif()

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})

set(WRAPPER_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps")

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "APPLICATION_ID=\"${APPLICATION_ID}\"")
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK PkgConfig::GLIB PkgConfig::GIO)
add_dependencies(${BINARY_NAME} flutter_assemble)

include(FindPkgConfig)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${BUILD_BUNDLE_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${BUILD_BUNDLE_DIR}/data"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${BUILD_BUNDLE_DIR}/lib"
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${BUILD_BUNDLE_DIR}/lib"
    COMPONENT Runtime)
endforeach(bundled_library)

set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/data/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${BUILD_BUNDLE_DIR}/data" COMPONENT Runtime)

install(CODE "
  foreach(bundled_library \${PLUGIN_BUNDLED_LIBRARIES})
    file(INSTALL DESTINATION \"${BUILD_BUNDLE_DIR}/lib\" TYPE SHARED_LIBRARY FOLLOW_SYMLINK_CHAIN FILES \"\${bundled_library}\")
  endforeach(bundled_library)
  " COMPONENT Runtime)
