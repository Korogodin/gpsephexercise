#ifndef GPSSVPOS_H
#define GPSSVPOS_H


#ifdef __cplusplus
extern "C" {
#endif

void parameters_init(void);
void coord_init(void);

typedef struct CoordinatesOfSatellite 
{
	float ecefX;
	float ecefY;
	float ecefZ;
	float eciX;
	float eciY;
	float eciZ;
	
} CoordinatesOfSatellite; 

CoordinatesOfSatellite& findPositionOfSatellite(int momentOfTime);

#ifdef __cplusplus
}
#endif


#endif /* #ifndef GPSSVPOS_H */

