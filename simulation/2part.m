clear all;clc;close all;
%Ephemerides:
t_oe=309600+18;%seconds of week at 14:00 UTC+leap seconds
a=26560218.295;
e=0.00372649;
M0=deg2rad(98.59776);
omega=deg2rad(78.62098);
i0=degtorad(55.45549);
OMEGA0=deg2rad(63.59022);
deltan=deg2rad(2.6281e-07);
idot=deg2rad(-1.6964e-08);
OMEGAdot=deg2rad(-4.5442e-07);
%Corrections:
Cus=9.2611e-06 ;
Crc=2.0400e+02;
Cic=-2.4214e-08;
Crs=-1.1250;
Cuc=-1.1921e-07;
Cis=-1.3039e-07;
%Constants:
omegae = 7.2921151467e-5;
mu = 3.986004418e+14;
latitude=55.45;
longitude=37.42;
height=175;
%Computation:
for k=1:43200
t = 291600+ 18 + k; %GPS Seconds of Week at 9:00 UTC (12:00 MSK)
tk=t-t_oe;
    if tk>302400
       tk=t(k)-t_oe;
    end
    if tk<-302400
       tk=tk+604800;
    end   
Mk=M0+(sqrt(mu)/sqrt(a^3)+deltan)*tk;
%Solution of the Kepler equation Mk=Ek-e*sin(Ek):
E(1)=0;i=1;
    while 1
        E(i+1) = Mk + e*sin(E(i)); 
        if abs(E(i+1) - E(i))<10^(-8)
            break
        end
        i = i + 1;
    end
Ek=E(i+1);
%true anomaly:
vk=atan2((sqrt(1-e^2)*sin(Ek)),(cos(Ek)-e));
%Computation of the argument of latitude, radial distance and inclination:
uk=omega+vk+Cuc*cos(2*(omega+vk))+Cus*sin(2*(omega+vk));
rk=a*(1-e*cos(Ek))+Crc*cos(2*(omega+vk))+Crs*sin(2*(omega+vk));
ik=i0+idot*tk+Cic*cos(2*(omega+vk))+Cis*sin(2*(omega+vk));
%longitude of the ascending node:
lambdak=OMEGA0+(OMEGAdot-omegae)*tk-omegae*t_oe;
    xk = rk*cos(uk);
    yk = rk*sin(uk);
%the Earth-fixed coordinates:
    xk_ecef(k) = xk*cos(lambdak) - yk*cos(ik)*sin(lambdak);
    yk_ecef(k) = xk*sin(lambdak) + yk*cos(ik)*cos(lambdak);
    zk_ecef(k) = yk*sin(ik);  
%the Earth-Centered inertial coordinates:
    theta = omegae*tk;
    xk_eci(k) = xk_ecef(k)*cos(theta) - yk_ecef(k)*sin(theta); 
    yk_eci(k) = xk_ecef(k)*sin(theta) + yk_ecef(k)*cos(theta);
    zk_eci(k) = zk_ecef(k);
%Transformation between ECEF and ENU coordinates: 
    [East, North, Up] = ecef2enu(xk_ecef(k), yk_ecef(k), zk_ecef(k), latitude, longitude, height, wgs84Ellipsoid);
    distance = sqrt(East^2 + North^2 + Up^2);
    elevation(k) = rad2deg(asin(Up/distance));
    azimuth(k) = atan2(East, North);
        if  elevation(k)<0
            elevation(k) = NaN;
            azimuth(k) = NaN;
        end
end
%%
figure; plot(elevation);
%% SkyView
figure; 
SV=polar (azimuth, 90-elevation);
view([90 -90]);
grid on; title('SkyView');
%% ECEF/ECI 3Dplots
figure;[X,Y,Z]=sphere(20); 
surfl(X*6.371,Y*6.371,Z*6.371);
hold on; axis equal;
plot3(xk_ecef/10^6,yk_ecef/10^6,zk_ecef/10^6);
title('Ïîëîæåíèÿ ñïóòíèêà â ñèñòåìå ECEF'); 
xlabel('x, òûñ.êì'); ylabel('y, òûñ.êì'); zlabel('z, òûñ.êì'); 

figure; [X,Y,Z]=sphere(20);  surfl(X*6.371,Y*6.371,Z*6.371);
hold on; axis equal;
plot3(xk_eci/10^6,yk_eci/10^6,zk_eci/10^6); 
title('Ïîëîæåíèÿ ñïóòíèêà â ñèñòåìå ECI'); 
xlabel('x, òûñ.êì'); ylabel('y, òûñ.êì'); zlabel('z, òûñ.êì');
