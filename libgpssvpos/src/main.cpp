#include <iostream>
#include <fstream>
#include <string>
#include "Сoordinate_calculation.h"
#include "Kepler_equation.h"
#include <ctime>

using namespace std;

void main()
{
	Efemeridi Efemer;
	const double PI = 3.141592653589793;
	Efemer.mu = 3.986004418E14;
	Efemer.we = 7.2921151467E-5;
	Efemer.toe = 288000;
	Efemer.A = 26559353.945;
	Efemer.e = 0.00189325;
	Efemer.M0 = 158.68863 * PI / 180;
	Efemer.omega = 36.26292 * PI / 180;
	Efemer.i0 = 55.15975 * PI / 180;
	Efemer.omega0 = -3.32161 * PI / 180;
	Efemer.del_n = PI / 180 * 2.6989E-7;
	Efemer.i_dot = PI / 180 * 7.0804E-9;
	Efemer.omega_dot = PI / 180 * (-4.6172E-7);
	Efemer.c_uc = -5.9418E-7;
	Efemer.c_us = 7.1991E-6;
	Efemer.c_rc = 2.3891E2;
	Efemer.c_rs = -1.0062E1;
	Efemer.c_ic = -5.7742E-8;
	Efemer.c_is = -2.9802E-8;

	time_t start, end;
	double t = 3.5*24*3600-3*3600;
	double delta_t = 0.1;
	double* coord = new double[3];
	double* coord_matlab = new double[3];
	double max_del = 0;
	//int i_max = 0;
	ofstream out;
	out.open("D:\\C\\KP_CHAST_3\\Cpp.txt");
	ifstream in("D:\\C\\KP_CHAST_3\\matlab.txt");
	time(&start);
	for (int i = 0; i < (12*3600/delta_t); i++)
	{
		gps_coord(t, coord, Efemer);
		t += delta_t;
		string coord_str1 = to_string(coord[0]);
		string coord_str2 = to_string(coord[1]);
		string coord_str3 = to_string(coord[2]);
		out << coord_str1 << "  " << coord_str2 << "  " << coord_str3 << endl;
		in >> coord_matlab[0] >> coord_matlab[1] >> coord_matlab[2];
		for (int j = 0; j < 3; j++)
		{
			if (abs(coord[j] - coord_matlab[j]) > max_del)
			{
				max_del = abs(coord[j] - coord_matlab[j]);
				//i_max = i;
			}
		}
	}
	time(&end);
	in.close();
	delete[] coord;
	delete[] coord_matlab;
	coord = nullptr;
	coord_matlab = nullptr;
	double seconds = difftime(end, start);
	string seconds1 = to_string(seconds * 1000000 / (12 * 3600 / delta_t));
	setlocale(LC_ALL, "rus");
	cout << "\n\t\tСреднее время расчёта, мкс: " << seconds1 << endl;
	string max_del1 = to_string(max_del);
	cout << "\t\tМаксимальная разность координат: " << max_del1 << endl;
	//string imax = to_string(i_max);
	//cout << "\t\tНомер отсчёта с максимальной разность: " << imax << endl;
	out.close();
	in.close();
}