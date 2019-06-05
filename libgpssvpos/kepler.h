#ifndef KEPLER_H
#define KEPLER_H


class Kepler
{
public:
    Kepler();

    float solve_keppler_equations(float meanAnomaly, float eccentricity, float accuracy);


};

#endif // KEPLER_H
