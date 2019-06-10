#include "tests.h"
#include <stdio.h>

Tests::Tests()
{

}

int Tests::test_value(int momentOfTime, double ecefX_answer, double ecefY_answer, double ecefZ_answer)
{
    int passX = 0;
    int passY = 0;
    int passZ = 0;

    //coordinatesOfSatellite.ecefX =0.0;
    //coordinatesOfSatellite.ecefY =0.0;
    //coordinatesOfSatellite.ecefZ =0.0;

    coordinatesOfSatellite = gpsvspos.findPositionOfSatellite(momentOfTime);

    if(coordinatesOfSatellite.ecefX == ecefX_answer )
    {
        passX = 1;
    }

    if(coordinatesOfSatellite.ecefY  == ecefY_answer)
    {
        passY = 1;
    }

    if(coordinatesOfSatellite.ecefZ == ecefZ_answer )
    {
        passZ = 1;
    }

    if(passX && passY && passZ)
    {
        return 1;
    }
    return 0;

}
int Tests::run_tests()
{

    int number_of_successful_passes = 0;



    if(test_value( 0 , -9532587.598677568,  -17844373.11265553,  -6281972.666158067 ))
    {
        number_of_successful_passes++;
    }

    if(test_value( 46799 , 17391018.464594834,  6543217.942131282, 252724.628491719))
    {
        number_of_successful_passes++;
    }


    if(number_of_successful_passes == 2)
    {
        return 1;
    }











}
