#include "pch.h"
#include "CppUnitTest.h"
#include "time.h"
#include <iostream>
#include <fstream>
#include "C:\Users\andre\Desktop\MVS tests\Kursovoy3\Kursovoy3\Kursovoy3.cpp"
using namespace Microsoft::VisualStudio::CppUnitTestFramework;
using std::ifstream;

namespace TestGPS
{
	TEST_CLASS(TestGPS)
	{
	public:
		
		TEST_METHOD(TestMethod1)
		{
			// Associative array for output data from C++ programm
			map<string, vector<float>> coordinatesOfSatellite;
			// Associative array for data from Matlab programm
			vector<float> xCoordsFromMatlab;
			vector<float> yCoordsFromMatlab;
			vector<float> zCoordsFromMatlab;

			//  Reading array of coordinates calculating in Matlab
			ifstream file1("C:\\Users\\andre\\Desktop\\MVS tests\\x_coords.txt");
			ifstream file2("C:\\Users\\andre\\Desktop\\MVS tests\\y_coords.txt");
			ifstream file3("C:\\Users\\andre\\Desktop\\MVS tests\\z_coords.txt");

			if (file1 && file2 && file3) {

				vector<string> vecStr1, vecStr2, vecStr3;
				string str1, str2, str3;

				while (true) {
					str1.clear();
					str2.clear();
					str3.clear();

					getline(file1, str1);
					getline(file2, str2);
					getline(file3, str3);

					if (!str1.empty() && !str2.empty() && !str3.empty()) {
						vecStr1.push_back(str1);
						vecStr2.push_back(str2);
						vecStr3.push_back(str3);
					} else {
						break;
					}
				}

				for (int i = 0; i < vecStr1.size(); ++i) {
					for (int j = 0; j < vecStr1[i].size(); ++j) {
						xCoordsFromMatlab.push_back(vecStr1[i][j]);
					}
				}

				for (int i = 0; i < vecStr2.size(); ++i) {
					for (int j = 0; j < vecStr2[i].size(); ++j) {
						yCoordsFromMatlab.push_back(vecStr2[i][j]);
					}
				}

				for (int i = 0; i < vecStr3.size(); ++i) {
					for (int j = 0; j < vecStr3[i].size(); ++j) {
						zCoordsFromMatlab.push_back(vecStr3[i][j]);
					}
				}

				file1.close();
				file2.close();
				file3.close();
			}

			// Time of starting the programm
			unsigned int startTime = clock();
			float sum1 = 0;
			float sum2 = 0;

			for (int i = 0; i < 42199; i++) {

				float momentOfTime = 30418 + i;

				coordinatesOfSatellite = findPositionOfSatellite(parameters, momentOfTime);

				//Assert::AreEqual(coordinatesOfSatellite["coordinatesInEci"][0], xCoordsFromMatlab[i]);
				//Assert::AreEqual(coordinatesOfSatellite["coordinatesInEci"][1], yCoordsFromMatlab[i]);
				//Assert::AreEqual(coordinatesOfSatellite["coordinatesInEci"][2], zCoordsFromMatlab[i]);
				
				sum1 = sum1 + (coordinatesOfSatellite["coordinatesInEci"][0] + coordinatesOfSatellite["coordinatesInEci"][1] + coordinatesOfSatellite["coordinatesInEci"][2]);
				sum2 = sum2 + (xCoordsFromMatlab[i] + yCoordsFromMatlab[i] + zCoordsFromMatlab[i]);
				
			}

			bool tmp = false;

			if (abs(sum1 - sum2) < 100000) {
				tmp = true;
			}

			Assert::AreEqual(tmp, true);

			std::cout << (startTime / CLOCKS_PER_SEC);
		}
	};
}
