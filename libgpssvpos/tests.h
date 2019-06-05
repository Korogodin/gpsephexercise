#ifndef TESTS_H
#define TESTS_H
#include "gpsvspos.h"

class Tests
{
public:
    Tests();

    int run_tests();
private:
    int test_value(int momentOfTime, double ecefX_answer, double ecefY_answer, double ecefZ_answer);

private:
    Gpsvspos gpsvspos;
    CoordinatesOfSatellite coordinatesOfSatellite;

};

#endif // TESTS_H
