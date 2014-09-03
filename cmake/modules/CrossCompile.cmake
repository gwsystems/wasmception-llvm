if(NOT DEFINED LLVM_NATIVE_BUILD)
  set(LLVM_NATIVE_BUILD "${CMAKE_BINARY_DIR}/native")
  message(STATUS "Setting native build dir to ${LLVM_NATIVE_BUILD}")
endif(NOT DEFINED LLVM_NATIVE_BUILD)

add_custom_command(OUTPUT ${LLVM_NATIVE_BUILD}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${LLVM_NATIVE_BUILD}
  COMMENT "Creating ${LLVM_NATIVE_BUILD}...")

add_custom_command(OUTPUT ${LLVM_NATIVE_BUILD}/CMakeCache.txt
  COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" ${CMAKE_SOURCE_DIR}
  WORKING_DIRECTORY ${LLVM_NATIVE_BUILD}
  DEPENDS ${LLVM_NATIVE_BUILD}
  COMMENT "Configuring native LLVM...")

add_custom_target(ConfigureNativeLLVM DEPENDS ${LLVM_NATIVE_BUILD}/CMakeCache.txt)

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES ${LLVM_NATIVE_BUILD})

if(NOT IS_DIRECTORY ${LLVM_NATIVE_BUILD})
  if(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    set(HOST_SYSROOT_FLAGS -DCMAKE_OSX_SYSROOT=macosx)
  endif(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")

  message(STATUS "Configuring native build...")
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory
    ${LLVM_NATIVE_BUILD} )

  message(STATUS "Configuring native targets...")
  execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release
      -G "${CMAKE_GENERATOR}" -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD} ${HOST_SYSROOT_FLAGS} ${CMAKE_SOURCE_DIR}
    WORKING_DIRECTORY ${LLVM_NATIVE_BUILD} )
endif(NOT IS_DIRECTORY ${LLVM_NATIVE_BUILD})
