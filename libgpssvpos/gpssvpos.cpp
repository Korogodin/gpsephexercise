#include <gpssvpos.h>
#include <kepler.h>

#include <iostream>
#include <cmath>
#include <ostream>

using namespace std;

void gps_coord(double t, double *koord)
{
    //10 19 2 13 13 59 44.0 .117549210787E-03 -.750333128963E-11 .000000000000E+00
    // .771000000000E+03 -.144062500000E+02 .472269705981E-08 -.138501624765E+01
    // -.802800059319E-06 .432204524986E-02 .711344182491E-05 .515366030693E+04
    // .309584000000E+06 .447034835815E-07 -.614370397393E-01 .167638063431E-07
    // .962764890954E+00 .241281250000E+03 -.275322944457E+01 -.811176645906E-08
    // .306084178206E-09 .100000000000E+01 .204000000000E+04 .000000000000E+00
    // .240000000000E+01 .000000000000E+00 .186264514923E-08 .300000000000E+01
    // .303169000000E+06 .000000000000E+00

    double mu = 3.986005E+14;
    double we = 7.292115E-05;
    double toe = .309584000000E+06;
    double a_sqr = .515366030693E+04;
    double e = .432204524986E-02;
    double M0 = -.138501624765E+01;
    double omega = -.275322944457E+01;
    double i0 = .962764890954E+00;
    double omega0 = -.614370397393E-01;
    double del_n = .472269705981E-08;
    double i_dot = .306084178206E-09;
    double omega_dot = -.811176645906E-08;
    double cuc = -.802800059319E-06;
    double cus = .711344182491E-05;
    double crc = .241281250000E+03;
    double crs = -.144062500000E+02;
    double cic = .447034835815E-07;
    double cis = .167638063431E-07;
    double tk = t - toe;
    double Mk = M0 + (sqrt(mu)/pow(a_sqr,3) + del_n)*tk;
    double Ek = kepler(Mk,e);
    double Vk = atan2(sqrt(1-pow(e,2))*sin(Ek),cos(Ek)-e);
    double Uk = omega + Vk + cuc*cos(2*(omega + Vk)) + cus*sin(2*(omega + Vk));
    double rk = pow(a_sqr,2)*(1-e*cos(Ek)) + crc*cos(2*(omega+Vk))+crs*sin(2*(omega+Vk));
    double ik = i0 + i_dot*tk + cic*cos(2*(omega + Vk)) + cis*sin(2*(omega + Vk));
    double lambk = omega0 + (omega_dot - we)*tk - we*toe;
    koord[0] = (cos(-lambk)*cos(-Uk)-sin(-lambk)*cos(-ik)*sin(-Uk))*rk;
    koord[1] = (-sin(-lambk)*cos(-Uk)-cos(-lambk)*cos(-ik)*sin(-Uk))*rk;
    koord[2] = (sin(-ik)*sin(-Uk))*rk;
}
