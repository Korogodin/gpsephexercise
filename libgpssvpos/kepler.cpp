#include "kepler.h"

#include <math.h>




Kepler::Kepler()
{

}




float Kepler::solve_keppler_equations(float meanAnomaly, float orbitalEccentricity, float accuracy) {

        float prevE_k = 0;
        float keplersSolution = 0;

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
