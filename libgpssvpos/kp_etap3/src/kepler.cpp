#include <kepler.h>
#include <cmath>

double kepler(double Mk, double e){
  double Ek = Mk;
  double Ek1 = Ek;
  do{
      Ek1 = Ek;
      Ek = Mk + e*sin(Ek);
  }while(fabs(Ek1-Ek)/fabs(Ek) > 0.0001);
  return Ek;
}
