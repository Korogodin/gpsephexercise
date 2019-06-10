#ifndef KEPLER_H
#define KEPLER_H


class Kepler
{
public:
    Kepler();

    double solve_keppler_equations(double meanAnomaly, double eccentricity, double accuracy);


};

#endif // KEPLER_H
