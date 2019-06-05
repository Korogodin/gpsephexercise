#include "tests.h"
#include <stdio.h>

Tests::Tests()
{

}

int Tests::test_value(int momentOfTime, float ecefX_answer, float ecefY_answer, float ecefZ_answer, float e)
{
    int passX = 0;
    int passY = 0;
    int passZ = 0;

    coordinatesOfSatellite = gpsvspos.findPositionOfSatellite(momentOfTime);

    printf("%d  %f  %f  %f \n", momentOfTime, coordinatesOfSatellite.ecefX, coordinatesOfSatellite.ecefY, coordinatesOfSatellite.ecefZ);


    if(((coordinatesOfSatellite.ecefX - e) >= ecefX_answer) && ((coordinatesOfSatellite.ecefX + e) <= ecefX_answer) )
    {
        passX = 1;
    }

    if(((coordinatesOfSatellite.ecefY - e) >= ecefY_answer) && ((coordinatesOfSatellite.ecefY + e) <= ecefY_answer) )
    {
        passY = 1;
    }

    if(((coordinatesOfSatellite.ecefZ - e) >= ecefZ_answer) && ((coordinatesOfSatellite.ecefZ + e) <= ecefZ_answer) )
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



    if(test_value( 1, 24059617.3596258, -955166.74696605, 5950357.16297493, 0.00001))
    {
        number_of_successful_passes++;
    }

    if(test_value( 1, -20560487,9719777, 5462322,28097377, 15910196,5299053, 0.00001))
    {
        number_of_successful_passes++;
    }

    if(number_of_successful_passes == 3)
    {
        return 1;
    }











}
