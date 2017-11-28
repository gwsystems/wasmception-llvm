function(llvm_create_cross_target_internal target_name toolchain buildtype)

  if(NOT DEFINED LLVM_${target_name}_BUILD)
    set(LLVM_${target_name}_BUILD "${CMAKE_BINARY_DIR}/${target_name}")
    set(LLVM_${target_name}_BUILD ${LLVM_${target_name}_BUILD} PARENT_SCOPE)
    message(STATUS "Setting native build dir to " ${LLVM_${target_name}_BUILD})
  endif(NOT DEFINED LLVM_${target_name}_BUILD)

  if (EXISTS ${LLVM_MAIN_SRC_DIR}/cmake/platforms/${toolchain}.cmake)
    set(CROSS_TOOLCHAIN_FLAGS_${target_name} 
        -DCMAKE_TOOLCHAIN_FILE=\"${LLVM_MAIN_SRC_DIR}/cmake/platforms/${toolchain}.cmake\"
        CACHE STRING "Toolchain file for ${target_name}")
  endif()

  if (buildtype)
    set(build_type_flags "-DCMAKE_BUILD_TYPE=${buildtype}")
  endif()
  if (LLVM_USE_LINKER AND NOT CMAKE_CROSSCOMPILING)
    set(linker_flag "-DLLVM_USE_LINKER=${LLVM_USE_LINKER}")
  endif()
  if (LLVM_EXTERNAL_CLANG_SOURCE_DIR)
    # Propagate LLVM_EXTERNAL_CLANG_SOURCE_DIR so that clang-tblgen can be built
    set(external_clang_dir "-DLLVM_EXTERNAL_CLANG_SOURCE_DIR=${LLVM_EXTERNAL_CLANG_SOURCE_DIR}")
  endif()

  add_custom_command(OUTPUT ${LLVM_${target_name}_BUILD}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LLVM_${target_name}_BUILD}
    COMMENT "Creating ${LLVM_${target_name}_BUILD}...")

  add_custom_target(CREATE_LLVM_${target_name}
                    DEPENDS ${LLVM_${target_name}_BUILD})

  add_custom_command(OUTPUT ${LLVM_${target_name}_BUILD}/CMakeCache.txt
    COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}"
        ${CROSS_TOOLCHAIN_FLAGS_${target_name}} ${CMAKE_SOURCE_DIR}
        -DLLVM_TARGET_IS_CROSSCOMPILE_HOST=TRUE
        -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}
        ${build_type_flags} ${linker_flag} ${external_clang_dir}
    WORKING_DIRECTORY ${LLVM_${target_name}_BUILD}
    DEPENDS CREATE_LLVM_${target_name}
    COMMENT "Configuring ${target_name} LLVM...")

  add_custom_target(CONFIGURE_LLVM_${target_name}
                    DEPENDS ${LLVM_${target_name}_BUILD}/CMakeCache.txt)

endfunction()

function(llvm_create_cross_target target_name sysroot)
  llvm_create_cross_target_internal(${target_name} ${sysroot} ${CMAKE_BUILD_TYPE})
endfunction()

llvm_create_cross_target_internal(NATIVE "" Release)
