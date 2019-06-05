#ifndef TESTS_H
#define TESTS_H
#include "gpsvspos.h"

class Tests
{
public:
    Tests();

    int run_tests();
private:
    int test_value(int momentOfTime, float ecefX_answer, float ecefY_answer, float ecefZ_answer, float e);

private:
    Gpsvspos gpsvspos;
    CoordinatesOfSatellite coordinatesOfSatellite;

};

#endif // TESTS_H
