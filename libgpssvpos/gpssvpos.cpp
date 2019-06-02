#include "gpssvpos.h"

#include <math.h>


#define TIME_SHIFT 18 //там была какая то магическая константа может быть это какой то временной сдвиг. По соглашению дефайны в верхнем регистре

typedef struct Params 
{
	float A; //если есть возможность то переименовать параметр в более понятный и лучше с маленькой буквы так как переменные с маленькой буквы
	float M0; //если есть возможность то переименовать параметр в более понятный и лучше с маленькой буквы так как переменные с маленькой буквы
	float Toe; //если есть возможность то переименовать параметр в более понятный и лучше с маленькой буквы так как переменные с маленькой буквы
	float omegaZero;
	float omega;
	float omegaDot;
	float omegaDotE;
	float eccentricity; //эту наверное можно orbitalEccentricity
	float inclination; 
	float motionDiff;
	float M;
	float IDOT; //снова верхний регистр как то не очень для переменных
	float Cus; //эти все тоже желательно с маленькой 
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
	params.A = 26560971.874;
	params.M0 = 2.01704;
	params.Toe = 288000;
	params.omegaZero = 55.82613;
	params.omega = 98.53938;
	params.omegaDot = -0.00000046497;
	params.omegaDotE = 0.000072921151467;
	params.eccentricity = 0.00146475;
	params.inclination = 54.57146;
	params.motionDiff = 0.00000027403;
	params.M = 398600500000000;
	params.IDOT = -0.000000018028;
	params.Cus = 0.0000086408;
	params.Cuc = -0.00000086054;
	params.Crs = -1.5281;
	params.Crc = 207.94;
	params.Cis = -0.000000042841;
	params.Cic = -0.000000087544;
	
	
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




								  
float degToRad(float degree) { //если честно почему сразу не в радианах считать хуй зн
	return degree * (M_PI/180);
}

CoordinatesOfSatellite& findPositionOfSatellite(int momentOfTime) {
	
	//переменные которые обявляются ниже можно обьявить вначале чтобы было не так палевно.
	
	params.Toe		          = params.Toe + TIME_SHIFT;
	params.M0		          = degToRad(params.M0);
	params.omegaZero   = degToRad(params.omegaZero);
	params.omega		  = degToRad(params.omega);
	params.omegaDot    = degToRad(params.omegaDot);
	params.inclination = degToRad(params.inclination);
	params.motionDiff  = degToRad(params.motionDiff);
	params.IDOT		  = degToRad(params.IDOT);

	int Tk = momentOfTime - params.Toe;
	// Set accuracy of calculations
	float accuracy = math.pow(10, -8);

	if (Tk > 302400) {
		Tk = Tk - 604800;
	} else if (Tk < -302400) {
		Tk = Tk + 604800;
	}
	
	// Compute mean motion
	float n0 = math.pow(params.M/(math.pow(params.A, 3)), 0.5);
	// Correct mean motion
	float n = n0 + params.motionDiff;
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
	coordinatesOfSatellite.eciX = eciX;
	coordinatesOfSatellite.eciY = eciY;
	coordinatesOfSatellite.eciZ = eciZ;
	

	return &coordinatesOfSatellite;
}


