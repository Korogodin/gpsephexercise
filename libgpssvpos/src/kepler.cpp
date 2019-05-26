#include <libgpssvpos/kepler.h>

float solveKeplersEquation(float meanAnomaly, float eccentricity, float accuracy) {

	float prevEk = 0;
	float keplersSolution = 0;

	while (true) {
		keplersSolution = meanAnomaly + eccentricity * sin(prevEk);

		if (abs(prevEk - keplersSolution) <= accuracy) {
			break;
		}

		prevEk = keplersSolution;
	}

	return keplersSolution;
}
