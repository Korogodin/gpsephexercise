#ifndef GPSSVPOS_H
#define GPSSVPOS_H


#ifdef __cplusplus
extern "C" {
#endif

void parameters_init(void);
void coord_init(void);

typedef struct CoordinatesOfSatellite //из за того что функция возвращает сслыку на структуру то и область видимости такого типа структур глобоальная
{
	float ecefX;
	float ecefY;
	float ecefZ;
	float eciX;
	float eciY;
	float eciZ;
	
} CoordinatesOfSatellite; //заменяем struct CoordinatesOfSatellite на CoordinatesOfSatellite (typedef)

CoordinatesOfSatellite& findPositionOfSatellite(int momentOfTime);

#ifdef __cplusplus
}
#endif


#endif /* #ifndef GPSSVPOS_H */

