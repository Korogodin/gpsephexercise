#include "kepler.h"

#include <math.h>




Kepler::Kepler()
{

}




double Kepler::solve_keppler_equations(double meanAnomaly, double orbitalEccentricity, double accuracy) {

        double prevE_k = 0;
        double keplersSolution = 0;

        while (true)
        {
            keplersSolution = meanAnomaly + orbitalEccentricity * sin(prevE_k);

            if(abs(prevE_k - keplersSolution) <= accuracy) {
                break;
            }

            prevE_k = keplersSolution;
        }

        return keplersSolution;
}
