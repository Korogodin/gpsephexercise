
clear all
for i = 1:95000
 
    %const  
    mu = 3.986005*10^14;                
    dOmega = 7.2921151467*10^(-5); 
    %almonach
    toe = 288018; % время альмонаха от начала недели               
    A = 26561396.452; %корень из большой полуоси, м**0.5                
    e = 0.01057272; % экстрисинтет             
    I = 54.99258;  %наклонение, полуциклы         
    I = degtorad(54.99258);
    OMEGA0 = -178.489062; % долгота узла, полуциклы;   
    OMEGA0 = degtorad(-178.489062); 
    omega = 30.86550; %аргумент перигея, полуцикл 
    omega = degtorad(30.86550);
    M_0 = 31.78651; %средняя аномалия, полуциклы
    M_0 = degtorad(31.78651);
    OMEGAdot = -4.6901e-07; %скорость долготы узла, полуциклы/c 
    OMEGAdot = degtorad(-4.6901e-07);
    delta_n = 2.3427e-07; 
    delta_n = degtorad(2.3427e-07);
    IDOT = 4.2974e-10;
    IDOT = degtorad(4.2974e-10);  
  
    C_uc = 2.1439e-06;          
    C_us = -4.6026e-06;         
    C_rc = 3.0238e+02;         
    C_rs = 3.9438e+01;         
    C_ic = -5.4017E-08;          
    C_is = 1.8440E-07;          
 
    % Из ИКД для GPS IS-GPS-200H
    n_0 = sqrt(mu/A^3);   
    t = 303540 + 18 + i;        
    tk = t - toe;             
    n = n_0 + delta_n;
    Mk = M_0+n*tk;
    m = 1;
    x(1) = 0;
    for m = 1:100
        x(m+1) = Mk + e*sin(x(m)); 
        if abs(x(m+1) - x(m))<10^(-8)
            break
        end
        m = m + 1;
    end
    E_k = x(m+1);
    
    nu = atan2( (sqrt(1-e^2)*sin(E_k))/(1 - e*cos(E_k)),(cos(E_k) - e)/(1 - e*cos(E_k)));
    Phi_k = nu + omega;
    deltau = C_us*sin(2*Phi_k) + C_uc*cos(2*Phi_k);                         
    deltar = C_rs*sin(2*Phi_k) + C_rc*cos(2*Phi_k);                         
    deltai = C_is*sin(2*Phi_k) + C_ic*cos(2*Phi_k);                         
    uk = Phi_k+deltau;                                                      
    rk = A*(1 - e*cos(E_k)) + deltar;                                      
    ik = I + deltai+ IDOT*tk;                                            
    x_k_orb = rk*cos(uk);
    y_k_orb = rk*sin(uk);
    Omega_k = OMEGA0 + (OMEGAdot - dOmega)*tk - dOmega*toe;
    x_k = x_k_orb*cos(Omega_k) - y_k_orb*cos(ik)*sin(Omega_k);
    y_k = x_k_orb*sin(Omega_k) + y_k_orb*cos(ik)*cos(Omega_k);
    z_k = y_k_orb*sin(ik);
    X(1,i) = x_k;
    Y(1,i) = y_k;
    Z(1,i) = z_k;
 
    r = sqrt((x_k)^2 + (y_k)^2 + (z_k)^2);
    
    theta = dOmega * tk;
 
    x_eci = x_k*cos(theta) - y_k*sin(theta);
    y_eci = x_k*sin(theta) + y_k*cos(theta);
    z_eci = z_k;
    X_eci(1,i) = x_eci;
    Y_eci(1,i) = y_eci;
    Z_eci(1,i) = z_eci;

 
   
 % Построим диаграмму SkyView
    moscowLatitude = 55.75;
    moscowLongitude = 37.62;
    moscowHeight = 150;
 
    [East, North, Up] = ecef2enu(x_k, y_k, z_k, moscowLatitude, moscowLongitude, moscowHeight, wgs84Ellipsoid);
    rangeFromRecieverToSatellite = sqrt(East^2 + North^2 + Up^2);
  
    elevation(i) = -asin(Up/rangeFromRecieverToSatellite)*180/pi + 90;
    azimuth(i) = atan2(East, North);
    end


% Построение SkyView
figure;
polar (azimuth, elevation);
title('SkyView'); 
grid on;
camroll(90);
 
N = 20;
thetavec = linspace(0,pi,N);
phivec = linspace(0,2*pi,2*N);
[th, ph] = meshgrid(thetavec,phivec);
R = 6.371*10^6; 
 
x = R.*sin(th).*cos(ph);
y = R.*sin(th).*sin(ph);
z = R.*cos(th);
 
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
plot3(X_eci(1,:), Y_eci(1,:),Z_eci(1,:));
axis vis3d
grid on
title('Earth-centered inertial (ECI) coordinate system'); 
xlabel('X, m'); 
ylabel('Y, m'); 
zlabel('Z, m'); 
