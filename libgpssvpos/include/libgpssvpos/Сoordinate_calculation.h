#ifndef COORDINATE_CALCULATION_H
#define COORDINATE_CALCULATION_H
typedef struct {
	double mu;
	double we;
	double toe;
	double A;
	double e;
	double M0;
	double omega;
	double i0;
	double omega0;
	double del_n;
	double i_dot;
	double omega_dot;
	double c_uc;
	double c_us;
	double c_rc;
	double c_rs;
	double c_ic;
	double c_is;
} Efemeridi;
void gps_coord(double t, double* coord, Efemeridi Ef);

#endif /* #ifndef GPSSVPOS_H */#pragma once
