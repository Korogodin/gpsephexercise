
clear all;
clc;

% Исходныеданные
% Square root of semi-major axis
A = 26560497.915;
% Ephemerides reference epoch in seconds within the week
Toe =309600;
% Mean anomaly at reference epoch
M0 =-0.041 ;
% Longitude of ascending node at the beginning of the week
omega_zero = -1.545;
% Argument of perigee
omega =  1.862;
% Rate of node's right ascension
omega_dot = degtorad(-5.1417e-07) ;
% WGS 84 value of earth's rotation rate
omega_dot_e = 7.2921151467e-5;
% Eccentricity
e = 0.001655380;
% Inclination at reference epoch
I0 = 0.908;
% Mean motion difference 
delta_n = degtorad(3.2711e-07);
M = 3.986005*10^14;
% Rate of inclination angle
IDOT = degtorad(7.7762e-9);

Cus = 7.8622e-6;
Cuc = -2.9616e-6;
Crs = -5.3906e1;
Crc = 2.0244e2;
Cis = -1.7881e-7;
Cic = -2.4401e-7;










 
% Решение
for k=1:2*43200
 
    T = 302400 + k;
Tk = T - Toe;
% Time from ephemeris reference epoch
if (Tk > 302400) 
        Tk = Tk - 604800;
elseif (Tk < -302400) 
        Tk = Tk + 604800;
end
 
% Compute mean motion
    n0 = sqrt(M/A^3);
% Correct mean motion
    n = n0 + delta_n;
 
% Mean anomaly
    Mk = M0 + n*Tk;
 
    Ek_prev = 0;
 
while(true)
        Ek = Mk + e*sin(Ek_prev);
 
if (abs(Ek_prev - Ek) <= 0.0000001)
break;
end
 
        Ek_prev = Ek;
end
 
% True Anomaly
    Vk = atan2(((sqrt(1-e^2)*sin(Ek))/(1 - e*cos(Ek))), ((cos(Ek) - e)/(1 - e*cos(Ek))));
 
% Argument of Latitude
    Fk = Vk + omega;
%Second Harmonic Perturbations
    delta_Uk = Cus*sin(2*Fk) + Cuc*cos(2*Fk);
    delta_Rk = Crs*sin(2*Fk) + Crc*cos(2*Fk);
    delta_Ik = Cis*sin(2*Fk) + Cic*cos(2*Fk);
% Correct Argument of Latitude
    Uk = Fk + delta_Uk;
% Correct Radius
    Rk = A*(1 - e*cos(Ek)) + delta_Rk;
% Correct Inclination
    Ik = I0 + delta_Ik + IDOT*Tk;
% Correct longitude of ascending node
    Wk = omega_zero + (omega_dot - omega_dot_e)*Tk - omega_dot_e*Toe;
 
% Positions in orbitalplane
    xk = Rk*cos(Uk);
    yk = Rk*sin(Uk);
% Earth-fixed coordinates
% Координатывсистеме ECEF
    xk_fixed(k) = xk*cos(Wk) - yk*cos(Ik)*sin(Wk);
    yk_fixed(k) = xk*sin(Wk) + yk*cos(Ik)*cos(Wk);
    zk_fixed(k) = yk*sin(Ik);
 
    rangeEcef(k) = sqrt((xk_fixed(k))^2 + (yk_fixed(k))^2 + (zk_fixed(k))^2); 
 
% Переведем координаты в систему ECI
theta = omega_dot_e*Tk;
 
xk_eci(k) = xk_fixed(k)*cos(theta) - yk_fixed(k)*sin(theta); 
    yk_eci(k) = xk_fixed(k)*sin(theta) + yk_fixed(k)*cos(theta);
    zk_eci(k) = zk_fixed(k);
 
    rangeEci(k) = sqrt((xk_eci(k))^2 + (yk_eci(k))^2 + (zk_eci(k))^2); 
 
% Построимдиаграмму SkyView
    moscowLatitude = 55.75;
    moscowLongitude = 37.62;
    moscowHeight = 150;
 
    [East, North, Up] = ecef2enu(xk_fixed(k), yk_fixed(k), zk_fixed(k), moscowLatitude, moscowLongitude, moscowHeight, wgs84Ellipsoid);
    rangeFromRecieverToSatellite = sqrt(East^2 + North^2 + Up^2);
 
    elevation(k) = -asin(Up/rangeFromRecieverToSatellite)*180/pi + 90;
    azimuth(k) = atan2(East, North);
end
 
% Построение SkyView
figure;
polar (azimuth, elevation);
title('SkyView'); 
grid on;
camroll(90);
 
 
% Графически отобразим траекторию спутника №9 в системе ECI и ECEF
thetavec = linspace(0, pi, 50);
phivec = linspace(0, 2*pi, 50);
[th, ph] = meshgrid(thetavec,phivec);
R = 6.371*10^6; 
 
x = R.*sin(th).*cos(ph);
y = R.*sin(th).*sin(ph);
z = R.*cos(th);
 
latitude = 55*pi/180;
longitude = 37*pi/180;
coordMoscowX = R*cos(latitude)*cos(longitude);
coordMoscowY = R*cos(latitude)*sin(longitude);
coordMoscowZ = R*sin(latitude);
 
% Всистеме ECEF
figure;   
surf(x, y, z);
axis equal;
hold on;
plot3(xk_fixed(1,:), yk_fixed(1,:), zk_fixed(1,:));
axis vis3d;
grid on;
title('ТраекторияспутникавсистемеECEF'); 
xlabel('x, м'); 
ylabel('y, м'); 
zlabel('z, м'); 
 
% ВсистемеECI
figure;
surf(x, y, z);
axis equal;
hold on;
plot3(xk_eci(1,:), yk_eci(1,:), zk_eci(1,:), coordMoscowX, coordMoscowY, coordMoscowZ, 'k.','MarkerSize', 30);
axis vis3d;
grid on;
title('ТраекторияспутникавсистемеECI'); 
xlabel('x, м'); 
ylabel('y, м'); 
zlabel('z, м'); 
