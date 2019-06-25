close all
clear
clc
% Исходные данные
A = 26560130.495;
Toe = 288000;
M0 = degtorad(-125.4963);
omega_zero = degtorad(-66.86763);
omega =  degtorad(-101.68691);
omega_dot = degtorad(-4.4895e-7);
omega_dot_e = 7.2921151467e-5;
e = 0.01886557;
I0 = degtorad(54.62098);
delta_n = degtorad(2.6707e-7);
M = 3.986005*10^14;
IDOT = degtorad(1.9625e-8);
Cus = 8.1845e-6;
Cuc = -1.1921e-7;
Crs = -2.4938e1;
Crc = 2.1247e2;
Cis = 5.2154e-8;
Cic = 2.4401e-7;
% Решение
for k=1:432000
    T = 302400 + k;
    Tk = T - Toe;
    if (Tk > 302400) 
        Tk = Tk - 604800;
    elseif (Tk < -302400) 
        Tk = Tk + 604800;
    end
    n0 = sqrt(M/A^3);
    n = n0 + delta_n;
    Mk = M0 + n*Tk;
    Ek_prev = 0;
    while(true)
        Ek = Mk + e*sin(Ek_prev);
        if (abs(Ek_prev - Ek) <= 0.0000001)
            break
        end
        Ek_prev = Ek;
    end
    Vk = atan2(((sqrt(1-e^2)*sin(Ek))/(1 - e*cos(Ek))), ((cos(Ek) - e)/(1 - e*cos(Ek))));
    Fk = Vk + omega;
    delta_Uk = Cus*sin(2*Fk) + Cuc*cos(2*Fk);
    delta_Rk = Crs*sin(2*Fk) + Crc*cos(2*Fk);
    delta_Ik = Cis*sin(2*Fk) + Cic*cos(2*Fk);
    Uk = Fk + delta_Uk;
    Rk = A*(1 - e*cos(Ek)) + delta_Rk;
    Ik = I0 + delta_Ik + IDOT*Tk;
    Wk = omega_zero + (omega_dot - omega_dot_e)*Tk - omega_dot_e*Toe;
    xk = Rk*cos(Uk);
    yk = Rk*sin(Uk);
    xk_fix(k) = xk*cos(Wk) - yk*cos(Ik)*sin(Wk);
    yk_fix(k) = xk*sin(Wk) + yk*cos(Ik)*cos(Wk);
    zk_fix(k) = yk*sin(Ik);
    rangeEcef(k) = sqrt((xk_fix(k))^2 + (yk_fix(k))^2 + (zk_fix(k))^2); 
    theta = omega_dot_e*Tk;
    xk_eci(k) = xk_fix(k)*cos(theta) - yk_fix(k)*sin(theta); 
    yk_eci(k) = xk_fix(k)*sin(theta) + yk_fix(k)*cos(theta);
    zk_eci(k) = zk_fix(k);
    rangeEci(k) = sqrt((xk_eci(k))^2 + (yk_eci(k))^2 + (zk_eci(k))^2); 
    MOS_Lat = 55.75;
    MOS_Long = 37.62;
    MOS_Height = 150;
    [East, North, Up] = ecef2enu(xk_fix(k), yk_fix(k), zk_fix(k), MOS_Lat, MOS_Long, MOS_Height, wgs84Ellipsoid);
    R = sqrt(East^2 + North^2 + Up^2);
    elevation(k) = -asin(Up/R)*180/pi + 90;
    azimuth(k) = atan2(East, North);
end
% Построение SkyView
% Для ограничения расчёта
%for i = [1:length(elevation)]
   %if elevation(i)<=100
       %elevation1(i) = elevation(i);
   %else
       %elevation1(i) = 100;
   %end
%end

figure;
polar (azimuth, elevation);
title('SkyView'); 
grid on;
camroll(90);
% Для построения траекторий
theta = linspace(0, pi, 50);
phi = linspace(0, 2*pi, 50);
[th, ph] = meshgrid(theta,phi);
R = 6.371*10^6; 
x = R.*sin(th).*cos(ph);
y = R.*sin(th).*sin(ph);
z = R.*cos(th);
latitude = 55*pi/180;
longitude = 37*pi/180;
MOS_X = R*cos(latitude)*cos(longitude);
MOS_Y = R*cos(latitude)*sin(longitude);
MOS_Z = R*sin(latitude);
% В системе ECEF
figure;   
surf(x, y, z);
axis equal;
hold on;
plot3(xk_fix(1,:), yk_fix(1,:), zk_fix(1,:));
axis vis3d;
grid on;
title('Траектория спутника в системе ECEF'); 
xlabel('x, м'); 
ylabel('y, м'); 
zlabel('z, м'); 
% В системе ECI
figure;
surf(x, y, z);
axis equal;
hold on;
plot3(xk_eci(1,:), yk_eci(1,:), zk_eci(1,:), MOS_X, MOS_Y, MOS_Z, 'k.','MarkerSize', 30);
axis vis3d;
grid on;
title('Траектория спутника в системе ECI'); 
xlabel('x, м'); 
ylabel('y, м'); 
zlabel('z, м'); 
