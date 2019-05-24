clear all, close all
for i = 1:43200


    mu = 3.986005*10^14;                %WGS 84 value of the earth's gravitational constant for GPS user
    dOmega_e_dt = 7.2921151467*10^(-5); %WGS 84 value of the earth's rotation rate
    t_oe = 288000 + 18;                 % Reference Time Ephemeris
    A = 26559371.973;                   % Square Root of the Semi-Major Axis^2
    e = 0.313590513542E-03;             % Eccentricity

    i_0 = 54.99258;                   % Inclination Angle at Reference Time [deg]
    i_0 = degtorad(i_0);              % -//- [circles]

    OMEGA_0 = 58.37197;               % Longitude of Ascending Node of Orbit Plane at Weekly Epoch [deg]
    OMEGA_0 = degtorad(OMEGA_0);      % -//- [circles]

    omega = -86.81172;                % Argument of Perigee [deg]
    omega = degtorad(omega);          % -//- [circles]

    M_0 = 170.75306;                  % Mean Anomaly at Reference Time [deg]
    M_0 = degtorad(M_0);              % -//- [circles/s]

    delta_n = 2.6429E-07;             % Mean Motion Difference From Computed Value [deg/s]
    delta_n = degtorad(delta_n);      % -//- [circles/s]

    OMEGAdot = -4.5867E-07;           % Rate of Right Ascension [deg/s]
    OMEGAdot = degtorad(OMEGAdot);    % [circles/s]

    IDOT = -1.7149E-08;         %Rate of Inclination Angle [deg/s]
    IDOT = degtorad(IDOT);      % -//- [circles/s]
    C_uc = -6.9290E-07;         % Amplitude of the Cosine Harmonic Correction Term to the Argument of Latitude [rad]  
    C_us = 8.8383E-06;          % -//- Sine -//- [meters]
    C_rc = 2.0738E+02;          % Amplitude of the Cosine Harmonic Correction Term to the Orbit Radius [meters]
    C_rs = -1.2594E+01;         % -//- Sine -//- [meters]
    C_ic = 5.4017E-08;          % Amplitude of the Cosine Harmonic Correction Term to the Angle of Inclination [rad]
    C_is = 1.1176E-08;          % -//- Sine -//- [rad]

    n_0 = sqrt(mu/A^3);   
    t = 302400 + 18 + i;        % Time of transmission + leap seconds
    t_k = t - t_oe;             % Time from ephemeris reference epoch
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

    delta_u_k = C_us*sin(2*Phi_k) + C_uc*cos(2*Phi_k);                          %Argument of Latitude Correction
    delta_r_k = C_rs*sin(2*Phi_k) + C_rc*cos(2*Phi_k);                          %Radius Correction
    delta_i_k = C_is*sin(2*Phi_k) + C_ic*cos(2*Phi_k);                          %Inclination Correction

    u_k = Phi_k+delta_u_k;                                                      %Corrected Argument of Latitude
    r_k = A*(1 - e*cos(E_k)) + delta_r_k;                                       %Corrected Radius
    i_k = i_0 + delta_i_k+ IDOT*t_k;                                            %Corrected Inclination

    x_k_orb = r_k*cos(u_k);
    y_k_orb = r_k*sin(u_k);

    Omega_k = OMEGA_0 + (OMEGAdot - dOmega_e_dt)*t_k - dOmega_e_dt*t_oe;

    x_ecef = x_k_orb*cos(Omega_k) - y_k_orb*cos(i_k)*sin(Omega_k);
    y_ecef = x_k_orb*sin(Omega_k) + y_k_orb*cos(i_k)*cos(Omega_k);
    z_ecef = y_k_orb*sin(i_k);
    X(1,i) = x_ecef;
    Y(1,i) = y_ecef;
    Z(1,i) = z_ecef;
     
    %Перевод из ECEF в ECI пункт 20.3.3.4.3.3.2 (стр 106) ИКД   
    theta = dOmega_e_dt * t_k;
    
    x_eci = x_ecef*cos(theta) - y_ecef*sin(theta);
    y_eci = x_ecef*sin(theta) + y_ecef*cos(theta);
    z_eci = z_ecef;
    X_eci(1,i) = x_eci;
    Y_eci(1,i) = y_eci;
    Z_eci(1,i) = z_eci;
    
    %Нахождение азимута и угла места
    p = sqrt((x_ecef)^2 + (y_ecef)^2 +(z_ecef)^2) - 6371000;
 
    lat = 55.75;
    lon = 37.62;
    [East,North,Up] = ecef2enu(x_ecef,y_ecef,z_ecef, lat, lon, 6371000, wgs84Ellipsoid );
  
    E = asin(degtorad(Up)/p);
    A = atan(degtorad(East/North));
    E_i(1,i) = cos(E);
    A_i(1,i) = A;    
 
    

end

polar (-A_i(1,:),E_i(1,:));


    
    


%{

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

figure;   %ecef
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
%}