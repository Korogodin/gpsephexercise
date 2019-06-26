clc;
clear all;
close all;
 nu = 3.986004418e+14;
We = 7.2921151467e-5;
c = 299792458;
TOW=302418;
t=TOW
 i0=deg2rad(54.58652);
A = 26560990.866;
e=0.01504780;
W0=deg2rad(-66.09226);
Wdot=deg2rad(-4.8212e-07);
t0e=309600;
dn=deg2rad(2.7016e-7);
M0=deg2rad(24.62735);
W=deg2rad(78.75439);
idot=deg2rad(1.0457e-8);
af0=25580.6;
af1=0.0039;
af2=0;
Cuc=-1.9539e-6;
Cus=8.7433e-6;
Crc=2.0950e+2;
Crs=-3.4062e+1;
Cic=-2.4028e-7;
Cis=-3.7253e-8;
latitude=55.756727964;
longitude=37.703259108;
h=189.4054;
for j=1:432
n0 = sqrt(nu/(A^3));
tk=t-t0e;
n=n0+dn;
M = M0+n*tk;
E=0;
for l=1:100
E=M+e*sin(E);
end
 v = atan2(sqrt(1-e^2)*sin(E),cos(E)-e);
F=v+W;
du=Cus*sin(2*F)+Cuc*cos(2*F);
dr=Crs*sin(2*F)+Crc*cos(2*F);
di=Cis*sin(2*F)+Cic*cos(2*F);
u=F+du;
r=A*(1-e*cos(E))+dr;
i=i0+di+idot*tk;
Xplan=r*cos(u);
Yplan=r*sin(u);
Omega=W0+(Wdot-We)*(tk)-We*t0e;
x=Xplan*cos(Omega)-Yplan*cos(i)*sin(Omega);
y=Xplan*sin(Omega)+Yplan*cos(i)*cos(Omega);
z=Yplan*sin(i);
 
Resfix(j,:)=[x y z];
 
phi=We*tk;
 
xeci=x*cos(phi)-y*sin(phi);
yeci=x*sin(phi)+y*cos(phi);
zeci=z;
 
ResECI(j,:)=[xeci yeci zeci];
 
[East, North, Up] = ecef2enu(x, y, z, latitude, longitude,h, wgs84Ellipsoid);
RtoS = sqrt(East^2 + North^2 + Up^2);
 
    elevation(j) = rad2deg(-asin(Up/RtoS))+90;
    azimuth(j) = atan2(East, North); 
   t=t+100;       
end
[X, Y, Z]=sphere(10);
figure;plot3(Resfix(:,1),Resfix(:,2),Resfix(:,3))
hold on;
surf(X*6.371*10^6, Y*6.371*10^6, Z*6.371*10^6);
hold off;
figure; plot3(ResECI(:,1),ResECI(:,2),ResECI(:,3));
hold on;
surf(X*6.371*10^6, Y*6.371*10^6, Z*6.371*10^6);
hold off;
s=1;
for y=1:length(elevation)
if elevation(y)<=90
    CorElevation(s)=elevation(y);
    CorAzim(s)=azimuth(y)
    s=s+1;
end
end
figure;
polar (2*pi-CorAzim, CorElevation); 
grid on;                         
camroll(90); 
