#include<iostream>
#include<conio.h>
#include<math.h>

void main()
{
	float nu = 3.986004418e+14;
	float We = 7.2921151467e-5;
	int c = 299792458;
	float pi = 3.1415926535;
	float TOW = 302418;
	float t = TOW;
	float i0 = 54.77658 * (pi / 180);
	float A = 26559709.250;
	float e = 0.01221966;
	float W0 = 117.52735 * (pi / 180);
	float Wdot = -4.4731e-07 * (pi / 180);
	float t0e = 288000 + 18;
	float dn = 2.5406e-7 * (pi / 180);
	float M0 = -178.86914 * (pi / 180);
	float W = -142.01036 * (pi / 180);
	float idot = 1.0232e-10 * (pi / 180);
	float af0 = 33469.9;
	float af1 = -0.0072;
	float af2 = 0;

	float Cuc = 2.997e-6;
	float Cus = 9.33e-6;
	float Crc = 1.9762e+2;
	float Crs = 5.9281e+1;
	float Cic = -1.4901e-8;
	float Cis = 0.13411e-6;


	double n0, tk, n, M, E, v, F, du, dr, di, u, r, i, Xplan, Yplan, Omega, x, y, z, E2;

	for (int j = 0; j < 100; j++) {
		n0 = sqrt(nu / (pow(A, 3)));
		tk = t - t0e;
		n = n0 + dn;
		M = M0 + n * tk;

		E2 = 00;

		do {
			E = E2;
			E2 = M + e * sin(E);
		} while (abs(E2 - E) > 0.000001);



		v = atan2(sqrt(1 - pow(e, 2)) * sin(E), cos(E) - e);
		F = v + W;
		du = Cus * sin(2 * F) + Cuc * cos(2 * F);
		dr = Crs * sin(2 * F) + Crc * cos(2 * F);
		di = Cis * sin(2 * F) + Cic * cos(2 * F);
		u = F + du;
		r = A * (1 - e * cos(E)) + dr;
		i = i0 + di + idot * tk;
		Xplan = r * cos(u);
		Yplan = r * sin(u);
		Omega = W0 + (Wdot - We) * (tk)-We * t0e;
		x = Xplan * cos(Omega) - Yplan * cos(i) * sin(Omega);
		y = Xplan * sin(Omega) + Yplan * cos(i) * cos(Omega);
		z = Yplan * sin(i);
		t = t + 0.1;
		std::cout.precision(5);
		std::cout << x << "  " << y << "   " << z << std::endl;
	}
	_getch();
}
