message("Running: \"${VERA_PROGRAM}\" \"--root\" \"/home/smartmatic/workspace/vera\" \"--rule\" \"L001\" \"/home/smartmatic/workspace/vera/tests/L001.cpp\"")
execute_process(COMMAND "${VERA_PROGRAM}"
  "--root" "/home/smartmatic/workspace/vera" "--rule" "L001" "/home/smartmatic/workspace/vera/tests/L001.cpp"
  RESULT_VARIABLE ret
  OUTPUT_VARIABLE output
  ERROR_VARIABLE error
  )
message("return value: ${ret}")
message("---output---\n${output}---error----\n${error}------------")

set(fail OFF)
if(NOT ${ret} EQUAL 0)
  message("Invalid return code. Expected return code was 0.")
  set(fail ON)
endif()
if(NOT "${output}" STREQUAL "/home/smartmatic/workspace/vera/tests/L001.cpp:4: trailing whitespace
/home/smartmatic/workspace/vera/tests/L001.cpp:6: trailing whitespace
")
  message("Output mismatch. Expected content was:")
  message("/home/smartmatic/workspace/vera/tests/L001.cpp:4: trailing whitespace
/home/smartmatic/workspace/vera/tests/L001.cpp:6: trailing whitespace
---")
  set(fail ON)
endif()
if(NOT "${error}" STREQUAL "")
  message("Output mismatch. Expected content was:")
  message("---")
  set(fail ON)
endif()

if(fail)
  message(FATAL_ERROR "some errors occurred.")
endif()