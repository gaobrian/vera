
find_package(TCL) # REQUIRED)
# don't use find_package's REQUIRED parameter to avoid requiring tk
if(NOT TCL_FOUND)
  message(FATAL_ERROR "TCL was not found.")
endif()
include_directories(SYSTEM ${TCL_INCLUDE_PATH})
link_directories(${TCL_LIBRARY_DIRS})

option(VERA_PYTHON "Build Python rules support" OFF)
if(VERA_PYTHON)
  # use a version number to force cmake to find a python 2 version
  find_package(PythonLibs 2.0 REQUIRED)
  include_directories(${PYTHON_INCLUDE_DIRS})
  set(boost_python python)
  add_definitions(-DVERA_PYTHON)
endif()

if(WIN32)
  # use boost static libs to avoid LNK2019 errors
  # feel free to contribute a better fix!
  set(Boost_USE_STATIC_LIBS ON)
else()
  # expose the Boost_USE_STATIC_LIBS option to ease the manual creation of
  # packages with cpack
  option(Boost_USE_STATIC_LIBS "Use Boost static libraries" OFF)
endif()
find_package(Boost COMPONENTS
  filesystem
  program_options
  system
  wave
  ${boost_python}
  REQUIRED)
include_directories(SYSTEM ${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIRS})
# hide Boost_DIR option that doesn't seem to be set by FindBoost
mark_as_advanced(Boost_DIR)

if(MSVC)
  # hide the warning generated by the usage of getenv()
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS)
endif(MSVC)

configure_file(config.h.in config.h @ONLY)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

file(GLOB_RECURSE srcs *.cpp)
add_executable(vera ${srcs})
set_target_properties(vera PROPERTIES OUTPUT_NAME vera++)
target_link_libraries(vera
  ${TCL_LIBRARY}
  ${Boost_LIBRARIES})
if(VERA_PYTHON)
  target_link_libraries(vera ${PYTHON_LIBRARIES})
endif()

if(WIN32)
  # install the tcl lib, if we can find it
  get_filename_component(tcldir "${TCL_LIBRARY}" PATH)
  get_filename_component(tclname "${TCL_LIBRARY}" NAME_WE)
  set(tcldll "${tcldir}/../bin/${tclname}.dll")
  if(EXISTS "${tcldll}")
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS "${tcldll}")
  endif()
endif()

# runtime libs will be copied by hand in the package - there is no need
# for these warnings
set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS ON)
include(InstallRequiredSystemLibraries)
install(TARGETS vera DESTINATION bin)

# install the runtime libraries
if(MSVC10)
  if(NOT MSVC10_REDIST_DIR)
    # the libs where not found by InstallRequiredSystemLibraries, so we get
    # them from System32
    set(msvc_redist_libs
      "C:/Windows/System32/msvcp100.dll"
      "C:/Windows/System32/msvcr100.dll")
    foreach(lib ${msvc_redist_libs})
      if(EXISTS ${lib})
        install(PROGRAMS ${lib} DESTINATION bin)
      endif()
    endforeach()
  endif()
endif()

include(../cmake/use_vera++.cmake)
add_vera_targets(*.h *.cpp
  RECURSE
  ROOT "${CMAKE_SOURCE_DIR}")
