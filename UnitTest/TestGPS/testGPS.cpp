#include "pch.h"
#include "CppUnitTest.h"
#include "time.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "C:\\Users\\Lyuda\\Desktop\\MVS tests\Kursovoy3\Kursovoy3\Kursovoy3.cpp"
#include <stdlib.h>
#include <crtdbg.h>

#define _CRTDBG_MAP_ALLOC

using namespace Microsoft::VisualStudio::CppUnitTestFramework;
using std::ifstream;
using std::string;
using std::vector;

namespace TestGPS
{
	TEST_CLASS(TestGPS)
	{
	public:
		
		TEST_METHOD(TestMethod1)
		{
			// Массивы для записи результата
			float xCoordsOfSat[43200];
			float yCoordsOfSat[43200];
			float zCoordsOfSat[43200];
			// Структура с параметрами спутника
			params gpsParams;

			// Векторы для координат из матлаба
			vector<float> coordsXMatlab;
			vector<float> coordsYMatlab;
			vector<float> coordsZMatlab;

			//  Считываем координаты из файлов
			ifstream file1("C:\\Users\\Lyuda\\Desktop\\MVS tests\\x_coords.txt");
			ifstream file2("C:\\Users\\Lyuda\\Desktop\\MVS tests\\y_coords.txt");
			ifstream file3("C:\\Users\\Lyuda\\Desktop\\MVS tests\\z_coords.txt");

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
						coordsXMatlab.push_back(vecStr1[i][j]);
					}
				}

				for (int i = 0; i < vecStr2.size(); ++i) {
					for (int j = 0; j < vecStr2[i].size(); ++j) {
						coordsYMatlab.push_back(vecStr2[i][j]);
					}
				}

				for (int i = 0; i < vecStr3.size(); ++i) {
					for (int j = 0; j < vecStr3[i].size(); ++j) {
						coordsZMatlab.push_back(vecStr3[i][j]);
					}
				}

				file1.close();
				file2.close();
				file3.close();
			}

			// Вычисляем время начала программы
			unsigned int startTime = clock();
			
			positionOfSatellite(gpsParams, xCoordsOfSat, yCoordsOfSat, zCoordsOfSat);

			for (int i = 0; i < 43199; i++) {
				Assert::AreEqual(xCoordsOfSat[i], coordsXMatlab[i]);
				Assert::AreEqual(yCoordsOfSat[i], coordsYMatlab[i]);
				Assert::AreEqual(zCoordsOfSat[i], coordsZMatlab[i]);
			}

			// Анализ утечки памяти
			_CrtDumpMemoryLeaks();

			std::cout << (startTime / CLOCKS_PER_SEC);
		}
	};
}
