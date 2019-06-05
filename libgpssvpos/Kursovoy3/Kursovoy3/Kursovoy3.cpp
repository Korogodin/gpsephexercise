#include "pch.h"
#include <iostream>
#include <map>
#include <vector>
#include "time.h"
#include <string>
//using namespace System;
//using namespace System::Text;
//using namespace System::Collections::Generic;
using std::map;
using std::vector;
using std::string;

#define pi 3,1415926535


// Параметры, полученные со спутника
map<string, float> parameters = { {"A", 26560971.874},
								  {"M0", 2.01704},
								  {"Toe", 288000},
								  {"omegaZero", 55.82613},
								  {"omega", 98.53938},
								  {"omegaDot", -0.00000046497},
								  {"omegaDotE", 0.000072921151467},
								  {"eccentricity", 0.00146475},
								  {"inclination", 54.57146},
								  {"motionDiff", 0.00000027403},
								  {"M", 398600500000000},
								  {"IDOT", -0.000000018028},
								  {"Cus", 0.0000086408},
								  {"Cuc", -0.00000086054},
								  {"Crs", -1.5281},
								  {"Crc", 207.94},
								  {"Cis", -0.000000042841},
								  {"Cic", -0.000000087544} };

// Функция, реализующая решение уравнения Кеплера
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

// Перевод из градусов в радианы
float degToRad(float degree) {
	return degree * (pi / 180);
}

// Вычисление положения спутника на заданный момент времени
map<string, vector<float>> findPositionOfSatellite(map<string, float>& parameters, int momentOfTime) {

	map<string, vector<float>> coordinatesOfSatellite;
	vector<float> coordinatesInEcefSystem(3);
	vector<float> coordinatesInEciSystem(3);


	parameters["Toe"]         = parameters["Toe"] + 18;
	parameters["M0"]		  = degToRad(parameters["M0"]);
	parameters["omegaZero"]   = degToRad(parameters["omegaZero"]);
	parameters["omega"]       = degToRad(parameters["omega"]);
	parameters["omegaDot"]    = degToRad(parameters["omegaDot"]);
	parameters["inclination"] = degToRad(parameters["inclination"]);
	parameters["motionDiff"]  = degToRad(parameters["motionDiff"]);
	parameters["IDOT"]        = degToRad(parameters["IDOT"]);

	int Tk = momentOfTime - parameters["Toe"];
	// Set accuracy of calculations
	float accuracy = pow(10, -8);

	if (Tk > 302400) {
		Tk = Tk - 604800;
	}
	else if (Tk < -302400) {
		Tk = Tk + 604800;
	}

	// Compute mean motion
	float n0 = pow(parameters["M"] / (pow(parameters["A"], 3)), 0.5);
	// Correct mean motion
	float n = n0 + parameters["motionDiff"];
	// Mean anomaly
	float meanAnomaly = parameters["M0"] + n * Tk;

	// Solve Keplers equation
	float Ek = solveKeplersEquation(meanAnomaly, parameters["eccentricity"], accuracy);
	// Callulate a true anomaly
	float Vk = atan2((pow((1 - parameters["eccentricity"] * parameters["eccentricity"]), 0.5) * sin(Ek) / (1 - parameters["eccentricity"] * cos(Ek))), ((cos(Ek) - parameters["eccentricity"]) / (1 - parameters["eccentricity"] * cos(Ek))));

	// Argument of Latitude
	float Fk = Vk + parameters["omega"];
	// Second harmonic perturbations
	float deltaUk = parameters["Cus"] * sin(2 * Fk) + parameters["Cus"] * cos(2 * Fk);
	float deltaRk = parameters["Crs"] * sin(2 * Fk) + parameters["Crc"] * cos(2 * Fk);
	float deltaIk = parameters["Cis"] * sin(2 * Fk) + parameters["Cic"] * cos(2 * Fk);
	// Correct argument of Latitude
	float Uk = Fk + deltaUk;
	// Correct radius
	float Rk = parameters["A"] * (1 - parameters["eccentricity"] * cos(Ek)) + deltaRk;
	// Correct inclination
	float Ik = parameters["inclination"] + deltaIk + parameters["IDOT"] * Tk;
	// Correct longitude of ascending node
	float Wk = parameters["omegaZero"] + (parameters["omegaDot"] - parameters["omegaDotE"]) * Tk - parameters["omegaDotE"] * parameters["Toe"];

	// Positions in orbitalplane
	float x = Rk * cos(Uk);
	float y = Rk * sin(Uk);
	// Earth-fixed coordinates
	// Coordinates in ECEF system
	float ecefX = x * cos(Wk) - y * cos(Ik) * sin(Wk);
	float ecefY = x * sin(Wk) + y * cos(Uk) * cos(Wk);
	float ecefZ = y * sin(Ik);

	// Coordinates in ECI system
	float theta = parameters["omegaDot"] * Tk;

	float eciX = ecefX * cos(theta) - ecefY * sin(theta);
	float eciY = ecefX * sin(theta) + ecefY * cos(theta);
	float eciZ = ecefZ;

	coordinatesInEcefSystem[0] = ecefX;
	coordinatesInEcefSystem[1] = ecefY;
	coordinatesInEcefSystem[2] = ecefZ;

	coordinatesInEciSystem[0] = eciX;
	coordinatesInEciSystem[1] = eciY;
	coordinatesInEciSystem[2] = eciZ;

	coordinatesOfSatellite["coordinatesInEcef"] = coordinatesInEcefSystem;
	coordinatesOfSatellite["coordinatesInEci"] = coordinatesInEciSystem;

	return coordinatesOfSatellite;
}

int main()
{

	//Console::WriteLine(L"Unit-test in MS Visual Studio.");
    return 0;
}
