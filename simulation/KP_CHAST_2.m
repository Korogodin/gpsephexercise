clc; clear all; close all;
tic;
%% эфемеридные данные
t_oe = 288000; 
e = 0.00189325;
omega = (pi/180)*36.26292;
M_0 = (pi/180)*158.68863;
a = 26559353.945;
i_0 = (pi/180)*55.15975;
omega_0 = -3.32161*pi/180;
delta_n = (pi/180)*2.6989e-7;
i_dot = (pi/180)*7.0804e-9;
omega_dot = (pi/180)*(-4.6172e-7);
c_us = 7.1991e-6;
c_rc = 2.3891e2;
c_rs = -1.0062e1;
c_ic = -5.7742e-8;
c_is = -2.9802e-8;
c_uc = -5.9418e-7;
% a = [1;1;3];
%% Константы
mu = 3.986004418e14; %м^3/с^2 Геоцентрическая гравитационная постоянная
w_e = 7.2921151467e-5; %рад/с Средняя угловая скорость Земли
%% Расчёт
t = 3*24*60*60+12*60*60-3*3600; 
N = 43200; % сек
X_Y_Z = nan(N,3);
X_Y_Z_2 = nan(N,3);
Rz = 6371000;
GPS_time = nan(N,2);
L = nan(N,1);
E = nan(N,1);
R = nan(N,1);
az = nan(N,1);
elev = nan(N,1);
GPS_time(:,1) = 2040;
latitude = 55.756727964;
longitude = 37.703259108;
height = 160;
for i = 1:N
GPS_time(i,2) = t;
t_k = t-t_oe;
M_k = M_0+(sqrt(mu/a^3)+delta_n)*t_k;
k = 2;
E_k(k-1) = M_k;
E_k(k) = M_k+e*sin(E_k(k-1));
while abs(E_k(k)-E_k(k-1))>=10^-8
    k = k+1;
    E_k(k) = M_k+e*sin(E_k(k-1));
end
E_k = E_k(k);
v_k = atan2((sqrt(1-e^2)*sin(E_k)),cos(E_k)-e);
u_k = omega+v_k+c_uc*cos(2*(omega+v_k))+c_us*sin(2*(omega+v_k));
r_k = a*(1-e*cos(E_k))+c_rc*cos(2*(omega+v_k))+c_rs*sin(2*(omega+v_k));
i_k = i_0+i_dot*t_k+c_ic*cos(2*(omega+v_k))+c_is*sin(2*(omega+v_k));
lambda_k = omega_0+(omega_dot-w_e)*t_k-w_e*t_oe;
l_k = -lambda_k;
R_3_lambda_k = [cos(l_k) sin(l_k) 0; -sin(l_k) cos(l_k) 0; 0 0 1];
R_1_i_k = [1 0 0; 0 cos(-i_k) sin(-i_k); 0 -sin(-i_k) cos(-i_k)];
R_3_u_k = [cos(-u_k) sin(-u_k) 0; -sin(-u_k) cos(-u_k) 0;0 0 1];
 
X_Y_Z(i,:) = R_3_lambda_k*R_1_i_k*R_3_u_k*[r_k;0;0];
[X_Y_Z_2(i,:)] = ecef2eci(GPS_time(i,:), X_Y_Z(i,:));
 
[E(i), N(i), U(i)] = ecef2enu(X_Y_Z(i,1), X_Y_Z(i,2),X_Y_Z(i,3),...
    latitude, longitude,height, wgs84Ellipsoid);
 
R(i) = sqrt(E(i)^2 + N(i)^2 + U(i)^2);
elev(i) = (180/pi)*(-asin(U(i)/R(i)))+90;
az(i) = atan2(E(i), N(i));
t = t+1;
end
X = X_Y_Z(:,1);
Y = X_Y_Z(:,2);
Z = X_Y_Z(:,3);
X_2 = X_Y_Z_2(:,1);
Y_2 = X_Y_Z_2(:,2);
Z_2 = X_Y_Z_2(:,3);
[Xsf, Ysf, Zsf] = sphere(25);
alfa1 = pi/180.*(1:359)';
beta1 = 88.*ones(359,1);
plot3(X./1000, Y./1000,Z./1000);
hold on
grid on
title('Положение спутника в СК ECEF');
xlabel('OX, км');
ylabel('OY, км');
zlabel('OZ, км');
axis('square');
axis('equal');
surf(Xsf.*Rz./1000, Ysf*Rz./1000, Zsf*Rz./1000);
hold off
figure;
plot3(X_2./1000, Y_2./1000,Z_2./1000);
hold on
grid on
title('Положение спутника в СК ECI');
xlabel('OX, км');
ylabel('OY, км');
zlabel('OZ, км');
axis('square');
axis('equal');
surf(Xsf.*Rz./1000, Ysf*Rz./1000, Zsf*Rz./1000);
hold off
figure;
polar (2*pi-az, elev); 
grid on;                         
toc;
