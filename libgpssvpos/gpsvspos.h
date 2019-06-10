#ifndef GPSVSPOS_H
#define GPSVSPOS_H

#include "kepler.h"

typedef struct CoordinatesOfSatellite
{
        double ecefX;
        double ecefY;
        double ecefZ;


} CoordinatesOfSatellite;



class Gpsvspos
{
public:
    Gpsvspos();
    CoordinatesOfSatellite findPositionOfSatellite(int momentOfTime);

private:
    void params_init(void);
    void coords_init(void);
    Kepler kepler;


};

#endif // GPSVSPOS_H
