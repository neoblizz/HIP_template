# begin /* Add unit tests */
set(UNITTEST_SOURCES
  hello_test.cxx
)

foreach(SOURCE IN LISTS UNITTEST_SOURCES)
  set_source_files_properties(${SOURCE} 
    PROPERTIES 
      LANGUAGE HIP
  )
  get_filename_component(TEST_NAME ${SOURCE} NAME_WLE)
  add_executable(${TEST_NAME} ${SOURCE})
  target_link_libraries(${TEST_NAME} 
    PRIVATE hello_hip
    PRIVATE gtest::main
  )

  set_target_properties(${TEST_NAME}
    PROPERTIES
      CXX_STANDARD 17
      HIP_STANDARD 17
      HIP_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES}
  )

  add_test(NAME test_${TEST_NAME} COMMAND ${TEST_NAME})
  message(STATUS "Unit Test Added: ${TEST_NAME}")
endforeach()
# end /* Add unit tests */