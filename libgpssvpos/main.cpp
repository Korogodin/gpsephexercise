#include <iostream>
#include <fstream>
#include <gpssvpos.h>
#include <kepler.h>
#include <ctime>

using namespace std;

int main()
{
    time_t start, end;
    double t = 3.5*24*3600-3*3600;
    double delt = 0.1;
    double *koord = new double[3];
    std::ofstream out;
    out.open("D:\\rez_cpp.txt");
    time(&start);
    for (int i; i < (12*3600/delt); i++)
    {
        gps_coord(t,koord);
        t += delt;
        std::string koord_str1 = std::to_string(koord[0]);
        std::string koord_str2 = std::to_string(koord[1]);
        std::string koord_str3 = std::to_string(koord[2]);
        out << koord_str1 << "  " << koord_str2 << "  " << koord_str3 << std::endl;
    }
    time(&end);
    double seconds = difftime(end, start);
    std::string seconds1 = std::to_string(seconds*1000000/(12*3600/delt));
    cout << seconds1 << std::endl;
    out.close();
}
