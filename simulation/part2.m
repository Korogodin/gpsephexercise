%{
    Курсовой проект. Часть 2.
    Студент: Опанасенко А.А,
    Группа: ЭР-15-14
%}

clear all;
clc;

% Исходные данные
% Square root of semi-major axis
A = sqrt(26560971.874)^2;
% Ephemerides reference epoch in seconds within the week
Toe = 288018;
% Mean anomaly at reference epoch
M0 = 2.01704*pi/180;
% Longitude of ascending node at the beginning of the week
omega_zero = 55.82613*pi/180;
% Argument of perigee
omega =  98.53938*pi/180;
% Rate of node's right ascension
omega_dot = -4.6497e-7*(pi/180);
% WGS 84 value of earth's rotation rate
omega_dot_e = 7.2921151467e-5;
% Eccentricity
e = 0.00146475;
% Inclination at reference epoch
I0 = 54.57146*pi/180;
% Mean motion difference
delta_n = (2.7403e-7)*pi/180;
M = 3.986005*10^14;
% Rate of inclination angle
IDOT = (-1.8028e-8)*pi/180;
% Compute mean motion
n0 = sqrt(M/A^3);
% Correct mean motion
n = n0 + delta_n;

Cus = 8.6408e-6;
Cuc = -8.6054e-7;
Crs = -1.5281e1;
Crc = 2.0794e2;
Cis = -4.2841e-8;
Cic = -8.7544e-8;

% Решение
for k=1:86400
    
    T = 302418 + k;
    Tk = T - Toe;
    % Time from ephemeris reference epoch
    if (Tk > 302400) 
        Tk = Tk - 604800;
    elseif (Tk < -302400) 
        Tk = Tk + 604800;
    end
   
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
    Vk = atan(((sqrt(1-e^2)*sin(Ek))/(1 - e*cos(Ek))) / ((cos(Ek) - e)/(1 - e*cos(Ek))));

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
    % Координаты в системе ECEF
    xk_fixed(k) = xk*cos(Wk) - yk*cos(Ik)*sin(Wk);
    yk_fixed(k) = xk*sin(Wk) + yk*cos(Ik)*cos(Wk);
    zk_fixed(k) = yk*sin(Ik);

    Range(k) = sqrt((xk_fixed(k))^2 + (yk_fixed(k))^2 + (zk_fixed(k))^2); 

    % Переведем координаты в систему ECI
    theta = omega_dot_e*Tk;

    xk_eci(k) = xk_fixed(k)*cos(theta) - yk_fixed(k)*sin(theta); 
    yk_eci(k) = xk_fixed(k)*sin(theta) + yk_fixed(k)*cos(theta);
    zk_eci(k) = zk_fixed(k);
    
    Range_eci(k) = sqrt((xk_eci(k))^2 + (yk_eci(k))^2 + (zk_eci(k))^2); 
    
    % Нахождение азимута и угла места
    lat = (55.75);
    lon = (37.62);
    [East, North, Up] = ecef2enu(xk_fixed(k), yk_fixed(k), zk_fixed(k), lat, lon, 6371000, referenceEllipsoid);
  
    
    
end

%{
E = asin(East);
    A = atan(East/North);
    E_k(k) = cos(E);
    A_k(k) = A;    

polar(A_k, E_k);
%}


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

% В системе ECEF
figure;   
surf(x, y, z);
axis equal;
hold on;
plot3(xk_fixed(1,:), yk_fixed(1,:), zk_fixed(1,:));
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
plot3(xk_eci(1,:), yk_eci(1,:), zk_eci(1,:), coordMoscowX, coordMoscowY, coordMoscowZ, 'k.','MarkerSize', 30);
axis vis3d;
grid on;
title('Траектория спутника в системе ECI'); 
xlabel('x, м'); 
ylabel('y, м'); 
zlabel('z, м'); 














