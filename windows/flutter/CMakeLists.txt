cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")
get_filename_component(FLUTTER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../.." REALPATH)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")
set(FLUTTER_LIBRARY_HEADERS "${EPHEMERAL_DIR}/cpp_client_wrapper/include")
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)

add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE "${FLUTTER_LIBRARY_HEADERS}")
target_link_libraries(flutter INTERFACE "${EPHEMERAL_DIR}/flutter_windows.dll.lib")
add_dependencies(flutter flutter_assemble)

add_library(flutter_wrapper_app STATIC
  "${EPHEMERAL_DIR}/cpp_client_wrapper/core_implementations.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/standalone_engine.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/plugin_registrar.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/flutter_engine.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/flutter_view_controller.cc"
)
apply_standard_settings(flutter_wrapper_app)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_include_directories(flutter_wrapper_app PUBLIC "${FLUTTER_LIBRARY_HEADERS}")
add_dependencies(flutter_wrapper_app flutter_assemble)

add_custom_command(
  OUTPUT ${FLUTTER_LIBRARY} ${FLUTTER_LIBRARY_HEADERS}
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.bat"
      windows-x64 $<CONFIG>
  VERBATIM
)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}" ${FLUTTER_LIBRARY_HEADERS}
)
