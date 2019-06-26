#include <iostream>
#include <fstream>
#include <gpssvpos.h>
#include <kepler.h>
#include <ctime>

using namespace std;
int main()
{
    time_t start, end;
    double t = 396018;
    double delt = 0.1;
    double *koord = new double[3];
    double *koord_matlab = new double[3];
    double max_del = 0;
    int i_max = 0;
    std::ofstream out;
    out.open("Å:\\cpp.txt");
    std::ifstream in("Å:\\mat.txt");
    if (!in)
    {
        std::cout << "File not open!" << std::endl;
    } else {
        std::cout << "File open!" << std::endl;
    }
    time(&start);
    for (int i = 0; i < (12*3600/delt); i++)
    {
        gps_coord(t,koord);
        t += delt;
        std::string koord_str1 = std::to_string(koord[0]);
        std::string koord_str2 = std::to_string(koord[1]);
        std::string koord_str3 = std::to_string(koord[2]);
        out << koord_str1 << "  " << koord_str2 << "  " << koord_str3 << std::endl;
        in >> koord_matlab[0] >> koord_matlab[1] >> koord_matlab[2];
        for (int j = 0; j < 3; j++)
        {
            if (abs(koord[j]-koord_matlab[j]) > max_del)
            {
                max_del = abs(koord[j]-koord_matlab[j]);
                i_max = i;
            }
        }
    }
    time(&end);
    in.close();
    delete[] koord;
    koord = nullptr;
    delete[] koord_matlab;
    koord_matlab = nullptr;
    double seconds = difftime(end, start);
    std::string seconds1 = std::to_string(seconds*1000000/(12*3600/delt));
    cout << "Srednee vremia raschota, mcs: " << seconds1 << std::endl;
    std::string max_del1 = std::to_string(max_del);
    cout << "Maximalnaia raznost koordinat: " << max_del1 << std::endl;
    std::string imax = std::to_string(i_max);
    cout << "Nomer otcheta s max raznostiy: " << imax << std::endl;
    out.close();
    in.close();
}

#include <gpssvpos.h>
#include <kepler.h>

#include <iostream>
#include <cmath>
#include <ostream>

using namespace std;

void gps_coord(double t, double *koord)
{

    double mu = 3.986005E+14;
    double we = 7.292115E-05;
    double toe = .309618000000E+06;
    double a_sqr = sqrt(.26560593206E+06);
    double e = .427016000000E-02;
    double M0 = -.17927475E+03*M_PI/180;
    double omega = -.2013571E+02*M_PI/180;
    double i0 = .55581618E+02*M_PI/180;
    double omega0 = -.12417322E+03*M_PI/180;
    double del_n = .24458E-08*M_PI/180;
    double i_dot = -.31719E-08*M_PI/180;
    double omega_dot = -.46211E-06*M_PI/180;
    double cuc = -.20713E-05;
    double cus = .61411E-05;
    double crc = .26525E+03;
    double crs = -.41188E+02;
    double cic = .46566E-07;
    double cis = .37253E-07;
    double tk = t - toe;    
    double Mk = M0 + (sqrt(mu)/pow(a_sqr,3) + del_n)*tk;
    double Ek = kepler(Mk,e);
    double Vk = atan2(sqrt(1-pow(e,2))*sin(Ek),cos(Ek)-e);
    double Uk = omega + Vk + cuc*cos(2*(omega + Vk)) + cus*sin(2*(omega + Vk));
    double rk = a_sqr*a_sqr*(1-e*cos(Ek)) + crc*cos(2*(omega+Vk))+crs*sin(2*(omega+Vk));
    double ik = i0 + i_dot*tk + cic*cos(2*(omega + Vk)) + cis*sin(2*(omega + Vk));
    double lambk = omega0 + (omega_dot - we)*tk - we*toe;
    koord[0] = (cos(-lambk)*cos(-Uk)-sin(-lambk)*cos(-ik)*sin(-Uk))*rk;
    koord[1] = (-sin(-lambk)*cos(-Uk)-cos(-lambk)*cos(-ik)*sin(-Uk))*rk;
    koord[2] = (-sin(-ik)*sin(-Uk))*rk;
}


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

