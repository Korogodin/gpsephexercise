#include <libgpssvpos/gpssvpos.cpp>
#include <libgpssvpos/kepler.cpp>
#include <iostream>
#include <map>
#include <vector>
using namespace std;

int main(int argc, char* argv[]) {

	map<string, vector<float>> coordinatesOfSatellite;

	// Time of starting the programm
	unsigned int startTime = clock();

	// Main cyrcle
	for (int i = 0; i < 43199; i++) {

		momentOfTime = 30418 + i;

		coordinatesOfSatellite = findPositionOfSatellite(parameters, momentOfTime);

		if (i == 0) {
			break;
		}
	}

	// Time of ending the programm
	unsigned int endTime = clock();


	// View the coordinates
	cout << "Coordinate X: " << coordinatesOfSatellite["ECI"][0] << endl;
	cout << "Coordinate Y: " << coordinatesOfSatellite["ECI"][1] << endl;
	cout << "Coordinate Z: " << coordinatesOfSatellite["ECI"][2] << endl;
	cout << "Time of calculating: " << (endTime - startTime) << endl;

	return 0;
}