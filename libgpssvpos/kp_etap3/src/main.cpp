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
    double *koord_matlab = new double[3];
    double max_del = 0;
    int i_max = 0;
    std::ofstream out;
    out.open("D:\\rez_cpp.txt");
    std::ifstream in("D:\\res_mat.txt");
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
