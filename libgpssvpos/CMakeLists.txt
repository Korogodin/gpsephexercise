cmake_minimum_required(VERSION 2.8)

project(sputnick2)

add_executable(sputnick2 "")


set(SOURCES
    main.cpp
    kepler.h
    kepler.cpp
    gpsvspos.h
    gpsvspos.cpp
    tests.h
    tests.cpp
)

target_sources(sputnick2
    PRIVATE ${SOURCES}
)

