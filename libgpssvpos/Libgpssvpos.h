#include "stdafx.h"
#include "time.h"
#include "math.h"
#include "conio.h"
#include <iostream>  
using namespace std;


int main()
{
	double e = 0.313590513542E-03;
	double myu = 3.986005*10^14;
	double dOmega_e_dt = 7.2921151467*10^(-5);
	double Az = 26559371.973;
	double sqrt_A = sqrt(Az);
	double omega = -1.515150343319412;
	double dOmega_dt = -8.005301680122391e-09;
	double Omega_0 = 1.018783067375354;
	double M_0 = 2.980203104855429;
	int t_oe = 288000 + 18;
	int t = 366000 + 18;
	double i_0 = 0.959801585166383;
	double C_rs = -1.2594E+01;
	double C_rc = 2.0738E+02;
	double C_uc = -6.9290E-07;
	double C_us = 8.8383E-06;
	double C_is = 1.1176E-08;
	double C_ic = 5.4017E-08;
	double delta_n = 4.612730680095813e-09;
	double IDOT = -2.993065134245076e-10;
	double n_0 = sqrt(myu / pow(sqrt_A, 6));
	double n = n_0 + delta_n;

	int t_k = t - t_oe;
	double M_k = M_0 + n * t_k;

	double m = 0;
	double x = 0;
	while (1)
	{
		m = x;
		x = M_k + e * sin(x);

		if (abs(x - m) < 1e-8)
			break;
	}
	double E_k = x;

	double nyu_k = atan2((sqrt(1 - pow(e, 2)) * sin(E_k)) / (1 - e * cos(E_k)), (cos(E_k) - e) / (1 - e * cos(E_k)));
	double Phi_k = nyu_k + omega;

	double delta_u_k = C_us * sin(2 * Phi_k) + C_uc * cos(2 * Phi_k);
	double delta_r_k = C_rs * sin(2 * Phi_k) + C_rc * cos(2 * Phi_k);
	double delta_i_k = C_is * sin(2 * Phi_k) + C_ic * cos(2 * Phi_k);

	double u_k = Phi_k + delta_u_k;
	double r_k = (pow(sqrt_A, 2)) * (1 - e * cos(E_k)) + delta_r_k;
	double i_k = i_0 + delta_i_k + IDOT * t_k;

	double Omega_k = Omega_0 + (dOmega_dt - dOmega_e_dt)*t_k - dOmega_e_dt * t_oe;

	double x_k_orb = r_k * cos(u_k);
	double y_k_orb = r_k * sin(u_k);

	double x_k = x_k_orb * cos(Omega_k) - y_k_orb * cos(i_k)*sin(Omega_k);
	double y_k = x_k_orb * sin(Omega_k) + y_k_orb * cos(i_k)*cos(Omega_k);
	double z_k = y_k_orb * sin(i_k);

	cout << x_k;
	cout << y_k;
	cout << z_k;
	cout << clock();
	_getch();
	return 0;
}
