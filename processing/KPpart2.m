clc;
clear all;
close all;
 nu = 3.986004418e+14;
We = 7.2921151467e-5;
c = 299792458;

TOW=302418;
t=TOW
 i0=deg2rad(54.77658);
A = 26559709.250;
e=0.01221966;
W0=deg2rad(117.52735);
Wdot=deg2rad(-4.4731e-07);
t0e=288000+18;
dn=deg2rad(2.5406e-7);
M0=deg2rad(-178.86914);
W=deg2rad(-142.01036);
idot=deg2rad(1.0232e-10);
af0=33469.9;
af1=-0.0072;
af2=0;

Cuc=2.997e-6;
Cus=9.33e-6;
Crc=1.9762e+2;
Crs=5.9281e+1;
Cic=-1.4901e-8;
Cis=0.13411e-6;



latitude=55.756727964;
longitude=37.703259108;
h=189.4054;
for j=1:4320


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
 
figure; plot3(Resfix(:,1),Resfix(:,2),Resfix(:,3));
figure; plot3(ResECI(:,1),ResECI(:,2),ResECI(:,3));

figure;
polar (2*pi-azimuth, elevation); %trimble дает график с осью по часовой стрелке, матлаб против
grid on;                         %
camroll(90);

V = sqrt((Resfix(1,1)-Resfix(2,1))^2+(Resfix(1,2)-Resfix(2,2))^2+(Resfix(1,3)-Resfix(2,3))^2)
R=sqrt((Resfix(1,1))^2+(Resfix(1,2)^2+(Resfix(1,3))^2))-6371000
R=sqrt((Resfix(2,1))^2+(Resfix(2,2)^2+(Resfix(2,3))^2))-6371000

Vx=(Resfix(1,1)-Resfix(2,1));
Vy=(Resfix(1,2)-Resfix(2,2));
Vz=(Resfix(1,3)-Resfix(2,3));

 

