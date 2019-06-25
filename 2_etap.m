clear all, close all
for i = 1:86400
    mu = 3.986005*10^14;                %гравитационная постоянная земли 
    dOmega_e_dt = 7.2921151467*10^(-5); %скорость вращения земли
    t_oe = 309600 + 18;                 % эфемеридное время
    Az = 26560593.206;                  % квадратный корень большой полуоси
    e = 0.00427016;                     % эксцентричность
 
    i_0 = 55.581618;                    %угол наклона в эталонное время
    i_0 = degtorad(i_0);                
 
    OMEGA_0 = -124.17322;               %долгота
    OMEGA_0 = degtorad(OMEGA_0);      
 
    omega = -20.13571;                  %Аргумент Перигея
    omega = degtorad(omega);          
 
    M_0 = -179.27475;                   %средняя аномалия
    M_0 = degtorad(M_0);              
 
    delta_n = 2.4458E-07;             
    delta_n = degtorad(delta_n);      

    OMEGAdot = -4.6211E-07;             %скорость правильного вознесения
    OMEGAdot = degtorad(OMEGAdot);    
 
    IDOT = -3.1719E-09;                 %скорость угла наклона
    IDOT = degtorad(IDOT);      
    C_uc = -2.0713E-06;         
    C_us = 6.1411E-06;          
    C_rc = 2.6525E+02;          
    C_rs = -4.1188E+01;         
    C_ic = -4.6566E-08;          
    C_is = 3.7253E-08;          

    n_0 = sqrt(mu/Az^3);   
    t = 396000 + 18 + i;                % время передачи + високосные секунды
    t_k = t - t_oe;                     % время из эфемерид эталонной эпохи
    n = n_0 + delta_n;
    M_k = M_0+n*t_k;
    m = 1;
    x(1) = 0;
    for m = 1:200
        x(m+1) = M_k + e*sin(x(m)); 
        if abs(x(m+1) - x(m))<10^(-8)
            break
        end
        m = m + 1;
    end
E_k = x(m+1);
     v_k = atan2( (sqrt(1-e^2)*sin(E_k))/(1 - e*cos(E_k)),(cos(E_k) - e)/(1 - e*cos(E_k)));
 
    Phi_k = v_k + omega;
 
    delta_u_k = C_us*sin(2*Phi_k) + C_uc*cos(2*Phi_k);                          %аргумент коррекции широты
    delta_r_k = C_rs*sin(2*Phi_k) + C_rc*cos(2*Phi_k);                          %радиус коррекции 
    delta_i_k = C_is*sin(2*Phi_k) + C_ic*cos(2*Phi_k);                          %коррекция наклона
   u_k = Phi_k+delta_u_k;                                                      
    r_k = Az*(1 - e*cos(E_k)) + delta_r_k;                                       
    i_k = i_0 + delta_i_k+ IDOT*t_k;                                            
 
    x_k_orb = r_k*cos(u_k);
    y_k_orb = r_k*sin(u_k);
 
    Omega_k = OMEGA_0 + (OMEGAdot - dOmega_e_dt)*t_k - dOmega_e_dt*t_oe;
 
    x_ecef = x_k_orb*cos(Omega_k) - y_k_orb*cos(i_k)*sin(Omega_k);
    y_ecef = x_k_orb*sin(Omega_k) + y_k_orb*cos(i_k)*cos(Omega_k);
    z_ecef = y_k_orb*sin(i_k);
    X(1,i) = x_ecef;
    Y(1,i) = y_ecef;
    Z(1,i) = z_ecef;
     
    %Перевод из ECEF в ECI 
    theta = dOmega_e_dt * t_k;
    
    x_eci = x_ecef*cos(theta) - y_ecef*sin(theta);
    y_eci = x_ecef*sin(theta) + y_ecef*cos(theta);
    z_eci = z_ecef;
    X_eci(1,i) = x_eci;
    Y_eci(1,i) = y_eci;
    Z_eci(1,i) = z_eci;
    %Нахождение азимута и угла места
    lat = 55.75;
    lon = 37.62;
    [East,North,Up] = ecef2enu(x_ecef,y_ecef,z_ecef, lat, lon, 150, wgs84Ellipsoid );
    p = sqrt(East^2 + North^2 + Up^2);
  
    El = asin(Up/p);
    Az = atan2(East,North);
    E_i(1,i) = -El*180/pi + 90;
    A_i(1,i) = Az;   
end
figure;
plot(E_i(1,:)); 
grid on;
 
figure;
polar (A_i(1,:),E_i(1,:));
camroll(90)
 
N = 20;
thetavec = linspace(0,pi,N);
phivec = linspace(0,2*pi,2*N);
[th, ph] = meshgrid(thetavec,phivec);
R = 6.371*10^6; 
 
x = R.*sin(th).*cos(ph);
y = R.*sin(th).*sin(ph);
z = R.*cos(th);
 
lat = degtorad(55);
lon = degtorad(37);
x_msk = R*cos(lat)*cos(lon);
y_msk = R*cos(lat)*sin(lon);
z_msk = R*sin(lat);
 
figure;   
surf(x,y,z);
axis equal
hold on
plot3(X(1,:), Y(1,:),Z(1,:));
axis vis3d
grid on
title('Earth-Centered, Earth-Fixed (ECEF) coordinate system'); 
xlabel('X, m'); 
ylabel('Y, m'); 
zlabel('Z, m'); 
 
 
figure ;
surf(x,y,z);
axis equal
hold on
plot3(X_eci(1,:), Y_eci(1,:),Z_eci(1,:),x_msk,y_msk,z_msk, 'k.','MarkerSize',20 );
axis vis3d
grid on
title('Earth-centered inertial (ECI) coordinate system'); 
xlabel('X, m'); 
ylabel('Y, m'); 
zlabel('Z, m');

