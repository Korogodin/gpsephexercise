#include "gpsvspos.h"

#include <math.h>

Gpsvspos::Gpsvspos()
{
    params_init();
    coords_init();

}






typedef struct Params
{
        double A;
        double M0;
        double Toe;
        double omegaZero;
        double omega;
        double omegaDot;
        double omegaDotE;
        double eccentricity;
        double inclination;
        double delta_n;
        double mu;
        double IDOT;
        double Cus;
        double Cuc;
        double Crs;
        double Crc;
        double Cis;
        double Cic;

} Params;






static Params params;
static CoordinatesOfSatellite coordinatesOfSatellite;

// params for calculate satellite coordinates
void Gpsvspos::params_init(void)
{
		params.A = 26559371.973;
		params.M0 = 170.75306;
		params.Toe = 288000;
		params.omegaZero = 58.37197;
		params.omega = -86.81172;
		params.omegaDot = -4.5867E-07;
		params.omegaDotE = 7.2921151467E-5;
		params.eccentricity = 0.313590513542E-03;
		params.inclination = 54.99258;
		params.delta_n = 2.6429E-07;
		params.mu = 398600500000000;
		params.IDOT = -1.7149E-08;
		params.Cus = 8.8383E-06;
		params.Cuc = -6.9290E-07;
		params.Crs = -1.2594E+01;
		params.Crc = 2.0738E+02;
		params.Cis = 5.4017E-08;
		params.Cic = 1.1176E-08;


}

void Gpsvspos::coords_init(void)
{
        coordinatesOfSatellite.ecefX = 0.0;
        coordinatesOfSatellite.ecefY = 0.0;
        coordinatesOfSatellite.ecefZ = 0.0;

}





double degToRad(double degree) {
        return degree * (M_PI/180);
}

CoordinatesOfSatellite Gpsvspos::findPositionOfSatellite(int momentOfTime) {

        params.Toe	 = params.Toe + 18;
        params.M0	 = degToRad(params.M0);
        params.omegaZero  = degToRad(params.omegaZero);
        params.omega	 = degToRad(params.omega);
        params.omegaDot   = degToRad(params.omegaDot);
        params.inclination = degToRad(params.inclination);
        params.delta_n  = degToRad(params.delta_n);
        params.IDOT		  = degToRad(params.IDOT);

        int Tk = momentOfTime - (int)params.Toe;
        // Set accuracy of calculations
        double accuracy = pow(10, -8);

        if (Tk > 302400) { 
                Tk = Tk - 604800;
        } else if (Tk < -302400) {
                Tk = Tk + 604800;
        }

        // Compute mean motion
        double n0 = pow(params.mu/(pow(params.A, 3)), 0.5);
        // Correct mean motion
        double n = n0 + params.delta_n;
        // Mean anomaly
        double meanAnomaly = params.M0 + n * Tk;

        // Solve Keplers equation
        double Ek = kepler.solve_keppler_equations(meanAnomaly, params.eccentricity, accuracy);
        // Callulate a true anomaly
        double Vk = atan2((pow((1 - params.eccentricity * params.eccentricity), 0.5) * sin(Ek) / (1 - params.eccentricity * cos(Ek))), ((cos(Ek) - params.eccentricity) / (1 - params.eccentricity * cos(Ek))));

        // Argument of Latitude
        double Fk = Vk + params.omega;
        // Second harmonic perturbations
        double deltaUk = params.Cus * sin(2*Fk) + params.Cus * cos(2*Fk);
        double deltaRk = params.Crs * sin(2*Fk) + params.Crc * cos(2*Fk);
        double deltaIk = params.Cis * sin(2*Fk) + params.Cic * cos(2*Fk);
        // Correct argument of Latitude
        double Uk = Fk + deltaUk;
        // Correct radius
        double Rk = params.A * (1 - params.eccentricity * cos(Ek)) + deltaRk;
        // Correct inclination
        double Ik = params.inclination + deltaIk + params.IDOT * Tk;
        // Correct longitude of ascending node
        double Wk = params.omegaZero + (params.omegaDot - params.omegaDotE) * Tk - params.omegaDotE * params.Toe;

        // Positions in orbitalplane
        double x = Rk * cos(Uk);
        double y = Rk * sin(Uk);
        // Earth-fixed coordinates
        // Coordinates in ECEF system
        double ecefX = x * cos(Wk) - y * cos(Ik) * sin(Wk);
        double ecefY = x * sin(Wk) + y * cos(Uk) * cos(Wk);
        double ecefZ = y * sin(Ik);

  


        coordinatesOfSatellite.ecefX = ecefX;
        coordinatesOfSatellite.ecefY = ecefY;
        coordinatesOfSatellite.ecefZ = ecefZ;



        return coordinatesOfSatellite;
}
