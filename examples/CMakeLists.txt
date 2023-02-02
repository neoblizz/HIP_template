# begin /* Add application */
set(SOURCES
  hello.cxx
)

foreach(SOURCE IN LISTS SOURCES)
  set_source_files_properties(${SOURCE} 
    PROPERTIES 
      LANGUAGE HIP
  )
  get_filename_component(TEST_NAME ${SOURCE} NAME_WLE)
  add_executable(${TEST_NAME} ${SOURCE})
  target_link_libraries(${TEST_NAME}
    PRIVATE hello_hip
  )

  set_target_properties(${TEST_NAME}
    PROPERTIES
      CXX_STANDARD 17
      HIP_STANDARD 17
      HIP_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES}
  )
  
  message(STATUS "Example Added: ${TEST_NAME}")
endforeach()
# end /* Add application */