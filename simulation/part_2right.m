clc;
clear all;
close all;
% константы
 mu = 3.986004418e+14; 
 we = 7.2921151467e-5;
 c = 299792458;

% эфемериды
A = 26559933.663;
e=0.01121171;
i0=deg2rad(53.17113);
W0=deg2rad(51.38077);
w=deg2rad(43.73662);
M0=deg2rad(111.08682);
deltan=deg2rad(3.2150e-7);
Wdot=deg2rad(-4.8607e-07);
idot=deg2rad(-1.4325e-8);

% time of weer было выбрано без учета URC, т.е. не на (12-3)a.m, а на 12p.m.
time_of_week=291600+18;
t=time_of_week;

 
Cuc=-9.8161e-7;
Cus=8.2161e-6;
Crc=2.0747e+2;
Crs=-1.7781e+1;
Cic=-2.7195e-7;
Cis=-1.1362e-7;
t0e=309600+18; 
 
% координаты приемника 
latitude=55.756727964;
longitude=37.703259108;
h=189.4054;


for k=1:4320
    
n0 = sqrt(mu/(A^3));
tk=t-t0e;
 n=n0+deltan;
 M = M0+n*tk;
E=0;
for l=1:100
E=M+e*sin(E);
end

v = atan2(sqrt(1-e^2)*sin(E),cos(E)-e);
F=v+w;
deltau=Cus*sin(2*F)+Cuc*cos(2*F);
deltar=Crs*sin(2*F)+Crc*cos(2*F);
deltai=Cis*sin(2*F)+Cic*cos(2*F);
u=F+deltau;
r=A*(1-e*cos(E))+deltar;
i=i0+deltai+idot*tk;
X=r*cos(u);
Y=r*sin(u);


ww = W0 - we*t0e+(Wdot-we)*tk;

% расчет координат в неинерциальной системе
x(k) = X*cos(ww)-Y*cos(i)*sin(ww);
y(k) = X*sin(ww)+Y*cos(i)*cos(ww);
z(k) = Y*sin(i);
WW = W0-we*t0e;
% расчет координат в инерциальной системе
xeci(k) = X*cos(WW)-Y*cos(i)*sin(WW);
yeci(k) = X*sin(WW)+Y*cos(i)*cos(WW);
zeci(k) = Y*sin(i);

%пересчет из ECEF в ENU
[x0 y0 z0] = ecef2enu(x(k),y(k),z(k),latitude,longitude,h, wgs84Ellipsoid);

%заменила atan на atan2 для того,чтобы упростить условия,т.к. возможно там была ошибка
teta(k) = rad2deg(atan2(z0,sqrt(x0^2+y0^2)));

phi(k) = atan2(x0,y0);

   if teta(k)<10 % elevation cutoff брался равным 10, для построения SkyView Trimble GNSS Planning Online
       teta(k) = NaN;
       phi(k) = NaN;
       
   end
t=t+10;
end



% построение графиков

%не инерциальная СК
[X,Y,Z] = sphere(50);
surf(X*6400000,Y*6400000,Z*6400000)
 hold on
 plot3(x,y,z,'b')
%инерциальная СК 
plot3(xeci,yeci,zeci,'r')
axis equal;
 daspect([1 1 1])
hold on

% SkyView
figure(3)
polar(phi,90 - teta,'-r')% 90-teta - разворот оси
view([90 -90]);
%camroll(90)



