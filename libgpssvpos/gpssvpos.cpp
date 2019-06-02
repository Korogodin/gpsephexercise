#include "gpssvpos.h"

#include <math.h>


#define TIME_SHIFT 18 

typedef struct Params 
{
	float A;
	float M0;
	float Toe;
	float omegaZero;
	float omega;
	float omegaDot;
	float omegaDotE;
	float eccentricity;
	float inclination; 
	float delta_n;
	float mu;
	float IDOT; 
	float Cus;
	float Cuc;
	float Crs;
	float Crc;
	float Cis;
	float Cic;
	
} Params;

typedef struct CoordinatesOfSatellite
{
	float ecefX;
	float ecefY;
	float ecefZ;
	float eciX;
	float eciY;
	float eciZ;
	
} CoordinatesOfSatellite;






static Params params;
static CoordinatesOfSatellite coordinatesOfSatellite;

// params fo calculate satellite coordinates
void params_init(void)
{
	params.A = 26559371.973;
	params.M0 = 170.75306;
	params.Toe = 288000;
	params.omegaZero = 58.37197;
	params.omega = -86.81172;
	params.omegaDot = -4.5867E-07;
	params.omegaDotE = 7.2921151467E-5;
	params.eccentricity = 0.313590513542E-03;
	params.inclination = 54.99258;
	params.delta_n = 2.6429E-07;
	params.mu = 398600500000000;
	params.IDOT = -1.7149E-08;
	params.Cus = 8.8383E-06;
	params.Cuc = -6.9290E-07;
	params.Crs = -1.2594E+01;
	params.Crc = 2.0738E+02;
	params.Cis = 5.4017E-08;
	params.Cic = 1.1176E-08;
	
	
}

void coord_init(void)
{
	coordinatesOfSatellite.ecefX = 0.0;
	coordinatesOfSatellite.ecefY = 0.0;
	coordinatesOfSatellite.ecefZ = 0.0;
	coordinatesOfSatellite.eciX = 0.0;
	coordinatesOfSatellite.eciY = 0.0;
	coordinatesOfSatellite.eciZ = 0.0;
}




								  
float degToRad(float degree) 
{ 
	return degree * (M_PI/180);
}

CoordinatesOfSatellite& findPositionOfSatellite(int momentOfTime) {
	
	
	params.Toe		   = params.Toe + TIME_SHIFT;
	params.M0		   = degToRad(params.M0);
	params.omegaZero   = degToRad(params.omegaZero);
	params.omega	   = degToRad(params.omega);
	params.omegaDot    = degToRad(params.omegaDot);
	params.inclination = degToRad(params.inclination);
	params.delta_n = degToRad(params.delta_n);
	params.IDOT		   = degToRad(params.IDOT);

	int Tk = momentOfTime - params.Toe;
	// Set accuracy of calculations
	float accuracy = math.pow(10, -8);

	if (Tk > 302400) {
		Tk = Tk - 604800;
	} else if (Tk < -302400) {
		Tk = Tk + 604800;
	}
	
	// Compute mean motion
	float n0 = math.pow(params.mu/(math.pow(params.A, 3)), 0.5);
	// Correct mean motion
	float n = n0 + params.delta_n;
	// Mean anomaly
	float meanAnomaly = params.M0 + n * Tk;

	// Solve Keplers equation
	float Ek = solveKeplersEquation(meanAnomaly, params.eccentricity, accuracy);
	// Callulate a true anomaly
	float Vk = math.atan2((math.pow((1 - params.eccentricity * params.eccentricity), 0.5) * math.sin(Ek) / (1 - params.eccentricity * math.cos(Ek))), ((math.cos(Ek) - params.eccentricity) / (1 - params.eccentricity * math.cos(Ek))));

	// Argument of Latitude
	float Fk = Vk + params.omega;
	// Second harmonic perturbations
	float deltaUk = params.Cus * math.sin(2*Fk) + params.Cus * math.cos(2*Fk);
	float deltaRk = params.Crs * math.sin(2*Fk) + params.Crc * math.cos(2*Fk);
	float deltaIk = params.Cis * math.sin(2*Fk) + params.Cic * math.cos(2*Fk);
	// Correct argument of Latitude
	float Uk = Fk + deltaUk;
	// Correct radius
	float Rk = params.A * (1 - params.eccentricity * math.cos(Ek)) + deltaRk;
	// Correct inclination
	float Ik = params.inclination + deltaIk + params.IDOT * Tk;
	// Correct longitude of ascending node
	float Wk = params.omegaZero + (params.omegaDot - params.omegaDotE) * Tk - params.omegaDotE * params.Toe;

	// Positions in orbitalplane
	float x = Rk * math.cos(Uk);
	float y = Rk * math.sin(Uk);
	// Earth-fixed coordinates
	// Coordinates in ECEF system
	float ecefX = x * math.cos(Wk) - y * math.cos(Ik) * math.sin(Wk);
	float ecefY = x * math.sin(Wk) + y * math.cos(Uk) * math.cos(Wk);
	float ecefZ = y * math.sin(Ik);

	// Coordinates in ECI system
	float theta = params.omegaDot * Tk;

	float eciX = ecefX * math.cos(theta) - ecefY * math.sin(theta);
	float eciY = ecefX * math.sin(theta) + ecefY * math.cos(theta);
	float eciZ = ecefZ;

	
	coordinatesOfSatellite.ecefX = ecefX;
	coordinatesOfSatellite.ecefY = ecefY;
	coordinatesOfSatellite.ecefZ = ecefZ;

	coordinatesOfSatellite.eciX  = eciX;
	coordinatesOfSatellite.eciY  = eciY;
	coordinatesOfSatellite.eciZ  = eciZ;
	

	return &coordinatesOfSatellite;
}


