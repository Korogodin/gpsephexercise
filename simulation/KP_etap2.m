% 2.10 N: GPS NAV DATA RINEX VERSION / TYPE
%RTKCONV 2.4.2 20190313 142818 UTC PGM / RUN BY / DATE 
%log: C:\Users\MIXAIL\Desktop\gpsephexercise-master\logs\BI COMMENT 
%format: NVS BINR COMMENT 
%
%10 19 2 13 13 59 44.0 .117549210787E-03 -.750333128963E-11 .000000000000E+00
% .771000000000E+03 -.144062500000E+02 .472269705981E-08 -.138501624765E+01
% -.802800059319E-06 .432204524986E-02 .711344182491E-05 .515366030693E+04
% .309584000000E+06 .447034835815E-07 -.614370397393E-01 .167638063431E-07
% .962764890954E+00 .241281250000E+03 -.275322944457E+01 -.811176645906E-08
% .306084178206E-09 .100000000000E+01 .204000000000E+04 .000000000000E+00
% .240000000000E+01 .000000000000E+00 .186264514923E-08 .300000000000E+01
% .303169000000E+06 .000000000000E+00

clear all;
close all;

tic;
%Используемые константы
del_t = 10;
mu = 3.986005E+14;
we = 7.292115E-05;
Rz = 6371000;
%Эфимириды
toe = .309584000000E+06;
a_sqr = .515366030693E+04;
e = .432204524986E-02;
M0 = -.138501624765E+01;
omega = -.275322944457E+01;
i0 = .962764890954E+00;
omega0 = -.614370397393E-01;
del_n = .472269705981E-08;
i_dot = .306084178206E-09;
omega_dot = -.811176645906E-08;
cuc = -.802800059319E-06;
cus = .711344182491E-05;
crc = .241281250000E+03;
crs = -.144062500000E+02;
cic = .447034835815E-07;
cis = .167638063431E-07;

num = fix(0.5*24*3600/del_t);
t = del_t.*(1:1:num);
t = t +3.5*24*3600-3*3600;
koord = zeros(num,3);
koord_1 = zeros(num,3);
gps_time = zeros(num,2);
koord_skyview = zeros(num,3);
LL_potr = [55.756655/180*pi 37.703099/180*pi 170];
beta = zeros(num,1);
alfa = zeros(num,1);

for i = 1:num
    gps_time(i,1) = 2040; 
    gps_time(i,2) = t(i);
    tk = t(i) - toe;
    Mk = M0 + (sqrt(mu)/(a_sqr^3) + del_n)*tk;
    Ek = Mk;
    for j = 1:5
        Ek = Mk + e*sin(Ek);
    end
    Vk = atan2(sqrt(1-e*e)*sin(Ek),cos(Ek)-e);
    Uk = omega + Vk + cuc*cos(2*(omega + Vk)) + cus*sin(2*(omega + Vk));
    rk = a_sqr*a_sqr*(1-e*cos(Ek)) + crc*cos(2*(omega+Vk))+crs*sin(2*(omega+Vk));
    ik = i0 + i_dot*tk + cic*cos(2*(omega + Vk)) + cis*sin(2*(omega + Vk));
    lambk = omega0 + (omega_dot - we)*tk - we*toe;
    R1_i = [1 0         0
            0 cos(-ik)  sin(-ik)
            0 -sin(-ik) cos(-ik)];
    R3_lamb = [cos(-lambk)  sin(-lambk) 0
               -sin(-lambk) cos(-lambk) 0
               0            0           1];
    R3_u = [cos(-Uk)  sin(-Uk) 0
            -sin(-Uk) cos(-Uk) 0
            0         0        1];
    koord(i,:) = R3_lamb*R1_i*R3_u*[rk;0;0];
    R = norm(koord(i,:)) - 6371000;   
    [koord_1(i,:)] = ecef2eci(gps_time(i,:), koord(i,:));
    L = atan2(koord(i,2),koord(i,1));
    Q = norm(koord(i,1:2));
    B = atan2(koord(i,3), Q*(1-e*e));
    B0 = 0;
    while (abs((B0 - B)/B)) >= 0.01
        B0 = B;
        W = sqrt(1-(e*sin(B)).^2);
        N = a_sqr*a_sqr/W;
        T = koord(i,3) + N*e*e*sin(B);
        B = atan2(T,Q);
    end
    H = Q*cos(B)+koord(i,3)*sin(B)-N*(1-(e*sin(B))^2);
    koord_skyview(i,1) = B*180/pi;
    koord_skyview(i,2) = L*180/pi;
    koord_skyview(i,3) = H;
    gamma = acos(sin(B)*sin(LL_potr(1)) + cos(B)*cos(LL_potr(1))*cos(LL_potr(2)-L));
    beta(i) = atan2(cos(gamma)*(Rz+H), sin(gamma)*(Rz+H)-Rz);
%     if beta(i)<0
%         beta(i) = beta(i) + 2*pi;
%     end
    alfa(i) = atan2(B - LL_potr(1), L - LL_potr(2));
end

[Xsf, Ysf, Zsf] = sphere(25);
alfa1 = pi/180.*(1:359)';
beta1 = 88.*ones(359,1);
plot3(koord(:,1)./1000, koord(:,2)./1000, koord(:,3)./1000);
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
plot3(koord_1(:,1)./1000, koord_1(:,2)./1000, koord_1(:,3)./1000);
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
% polar(alfa, 180/pi.*beta);
% hold on
% polar(alfa1, beta1, 'r--');
% hold off
plot(koord_skyview(:,2), koord_skyview(:,1));
hold on
plot(180*LL_potr(2)/pi, 180*LL_potr(1)/pi, 'ro--');
grid on
title('Широта и долгота');
xlabel('Долгота');
ylabel('Широта');
hold off
toc;