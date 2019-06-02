#include "kepler.h"  
#include <math.h>

#define CLK         142000000U
#define TICK_US     (CLK / 1000000)  //timeout in us
#define TIMEOUT     (uint32_t)(TICK_US * 100000)   //100ms timeout

float solve_keppler_equations(float &meanAnomaly, float &orbitalEccentricity, float &accuracy) { //переменные не меняются можно передать по сслыке
	
	uint32_t timeout = TIMEOUT; //платформонезависимый таймаут. Или делать через таймер что более точно и корректно
	float prevE_k = 0;
	float keplersSolution = 0;

	while ((abs(prevEk - keplersSolution) <= accuracy) || timeout--) 
	{
		keplersSolution = meanAnomaly + orbitalEccentricity * sin(prevE_k);
		prevE_k = keplersSolution;
	}

	return keplersSolution;
}
