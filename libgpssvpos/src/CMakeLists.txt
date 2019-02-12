if (NOT DEFINED BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ON)
endif (NOT DEFINED BUILD_SHARED_LIBS)

file(GLOB libgpssvpos_HEADERS "${PROJECT_SOURCE_DIR}/include/libgpssvpos/*.h")

include_directories("${PROJECT_SOURCE_DIR}/include")

set(libgpssvpos_SRCS
    gpssvpos.cpp
    kepler.cpp
)

add_library(gpssvpos-static STATIC ${libgpssvpos_SRCS})
install(TARGETS gpssvpos-static DESTINATION lib${LIB_SUFFIX})

if(BUILD_SHARED_LIBS)
  add_library(gpssvpos SHARED ${libgpssvpos_SRCS})
  install(TARGETS gpssvpos DESTINATION lib${LIB_SUFFIX})
else(BUILD_SHARED_LIBS)
  message(STATUS "Not building shared libraries")
endif(BUILD_SHARED_LIBS)

install(FILES ${libgpssvpos_HEADERS} DESTINATION include)
