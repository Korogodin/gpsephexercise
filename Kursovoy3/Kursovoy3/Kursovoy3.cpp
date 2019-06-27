#include "pch.h"
#include <iostream>
#include "time.h"

#define pi 3,1415926535

// Структура с входными параметрами
struct params {
	float A,
	      M0,
		  Toe,
		  omegaZero,
		  omega,
		  omegaDot,
		  omegaDotE,
		  eccentricity,
		  inclination,
	      motionDiff,
	      M,
	      IDOT,
		  Cus,
		  Cuc,
		  Crs,
		  Crc,
		  Cis,
	      Cic;
};

// Функция, реализующая решение уравнения Кеплера
float keplersEquation(float anomaly, float eccentricity, float acc) {

	float previouslyEk = 0;
	float solution = 0;

	while (true) {
		solution = anomaly + eccentricity * sin(previouslyEk);

		if (abs(previouslyEk - solution) <= acc) {
			break;
		}

		previouslyEk = solution;
	}

	return solution;
}

// Перевод из градусов в радианы
float degToRad(float degree) {
	return degree * (pi / 180);
}

// Вычисление положения спутника на заданный момент времени
void positionOfSatellite(struct params gpsParams, float (&coordsX)[43200], float (&coordsY)[43200], float (&coordsZ)[43200]) {

	gpsParams.A            = 26559933.663;
	gpsParams.M0           = degToRad(111.08682);
	gpsParams.Toe          = 302418 + 18;
	gpsParams.omegaZero    = degToRad(51.38077);
	gpsParams.omega        = degToRad(43.73662);
	gpsParams.omegaDot     = degToRad(-4.8607e-07);
	gpsParams.omegaDotE	   = 7.2921151467e-5;
	gpsParams.eccentricity = 0.01121171;
	gpsParams.inclination  = degToRad(53.17113);
	gpsParams.motionDiff   = degToRad(3.2150e-7);
	gpsParams.M            = 3.986004418e+14;
	gpsParams.IDOT         = degToRad(-1.4325e-8);
	gpsParams.Cus          = 8.2161e-6;
	gpsParams.Cuc          = -9.8161e-7;
	gpsParams.Crs          = -1.7781e+1;
	gpsParams.Crc          = 2.0747e+2;
	gpsParams.Cis          = -1.1362e-7;
	gpsParams.Cic          = -2.7195e-7;

	for (int i = 0; i < 43199; i++) {

		int momentOfTime = 302418 + i;

		int Tk = momentOfTime - gpsParams.Toe;
		// Определяем точность параметров
		float accuracy = pow(10, -7);

		if (Tk > 302400) {
			Tk = Tk - 604800;
		}
		else if (Tk < -302400) {
			Tk = Tk + 604800;
		}

		float n0 = pow(gpsParams.M / (pow(gpsParams.A, 3)), 0.5);
		float n = n0 + gpsParams.motionDiff;
		float anomaly = gpsParams.M0 + n * Tk;

		// Решаем уравнение Кеплера
		float Ek = keplersEquation(anomaly, gpsParams.eccentricity, accuracy);
		float Vk = atan2((pow((1 - gpsParams.eccentricity * gpsParams.eccentricity), 0.5) * sin(Ek) / (1 - gpsParams.eccentricity * cos(Ek))), ((cos(Ek) - gpsParams.eccentricity) / (1 - gpsParams.eccentricity * cos(Ek))));

		float Fk = Vk + gpsParams.omega;

		float deltaUk = gpsParams.Cus * sin(2 * Fk) + gpsParams.Cuc * cos(2 * Fk);
		float deltaRk = gpsParams.Crs * sin(2 * Fk) + gpsParams.Crc * cos(2 * Fk);
		float deltaIk = gpsParams.Cis * sin(2 * Fk) + gpsParams.Cic * cos(2 * Fk);

		float Uk = Fk + deltaUk;
		float Rk = gpsParams.A * (1 - gpsParams.eccentricity * cos(Ek)) + deltaRk;
		float Ik = gpsParams.inclination + deltaIk + gpsParams.IDOT * Tk;
		float Wk = gpsParams.omegaZero + (gpsParams.omegaDot - gpsParams.omegaDotE) * Tk - gpsParams.omegaDotE * gpsParams.Toe;

		float x = Rk * cos(Uk);
		float y = Rk * sin(Uk);
		// Координаты в системе ECEF
		float ecefX = x * cos(Wk) - y * cos(Ik) * sin(Wk);
		float ecefY = x * sin(Wk) + y * cos(Uk) * cos(Wk);
		float ecefZ = y * sin(Ik);

		// Координаты в системе ECI
		float theta = gpsParams.omegaDot * Tk;

		float eciX = ecefX * cos(theta) - ecefY * sin(theta);
		float eciY = ecefX * sin(theta) + ecefY * cos(theta);
		float eciZ = ecefZ;

		coordsX[i] = eciX;
		coordsY[i] = eciY;
		coordsZ[i] = eciZ;
	}

}

int main()
{

	
    return 0;
}
