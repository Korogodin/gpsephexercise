clear all, close all
mu = 3.986005*10^14; 
dOmega = 7.2921151467*10^-5; 
TOW = 396000 + 18 + i;
t0e = 309600 + 18;%время альманаха от нач. недели 
i0 = 56.36564*(pi/180); %наклонение
A = 26560589.313; %корень из б. полуоси
e = 0.01299050; %эксцентриситет 
omegadot = -4.4144*10^-7 *(pi/180); %скорость долготы узла
omega0 = -120.38566*(pi/180); %долгота узла
omega = -98.70576*(pi/180); %аргумент перигея 
M0 = 159.51923*(pi/180); %средняя аномалия 
deltan = 2.1943*10^-7 *(pi/180);
IDOT = -7.0395*10^-9 *(pi/180); 
	
Cuc = -3.3230*10^-6; 
Cus = 6.1765*10^-6; 
Crc = 2.6916*10^2; 
Crs = -66.125; 
Cic = 1.3039*10^-7; 
Cis = -5.2154*10^-8; 
	
shirota = 55.45;
dolgota = 37.42;
visota = 156;
     
for i = 1:900
   
    TOW = TOW + i;
    n0 = sqrt(mu/(A^3));
    Tk = TOW - t0e;
	Mk = M0 + (n0 + deltan)*Tk;
    
    E = 0;  
    while(true)
    Ek = Mk + e*sin(E);
    if (abs(E - Ek) <= 10^-8)
    break;
    end   
    E = Ek;
   end
  
nu = atan2(((sqrt(1-e^2)*sin(Ek))/(1 - e*cos(Ek))), ((cos(Ek) - e)/(1 - e*cos(Ek))));
fi = nu + omega;
deltaU = Cus*sin(2*fi) + Cuc*cos(2*fi);
deltaR = Crs*sin(2*fi) + Crc*cos(2*fi);
deltaI = Cis*sin(2*fi) + Cic*cos(2*fi);
U = fi + deltaU; 
R_Zeml = A*(1 - e*cos(Ek)) + deltaR;
I = i0 + deltaI + IDOT*Tk;

Xorb = R_Zeml*cos(U);
Yorb = R_Zeml*sin(U);
OmegaK = omega0 + (omegadot - dOmega)*Tk - dOmega*t0e;
x = Xorb*cos(OmegaK) - Yorb*cos(I)*sin(OmegaK);
y = Xorb*sin(OmegaK) + Yorb*cos(I)*cos(OmegaK);
z = Yorb*sin(I);
	
R(i,:)=[x y z];
teta = dOmega*Tk;
xeci = x*cos(teta) - y*sin(teta);
yeci = x*sin(teta) + y*cos(teta);
zeci = z;
ECI(i,:) = [xeci yeci zeci];

[East, North, Up] = ecef2enu(x, y, z, shirota, dolgota,visota, wgs84Ellipsoid);
SAT = sqrt(East^2 + North^2 + Up^2);
AZ(i) = atan2(East, North);
EL(i) = -asin(Up/SAT)*180/pi + 90;
end
[X, Y, Z] = sphere(10);

% figure(1);
% plot3(R(:,1),R(:,2),R(:,3))
% hold on;
% grid on; 
% surf(X*6371*10^3, Y*6371*10^3, Z*6371*10^3);
% 
% figure(2);
% plot3(ECI(:,1),ECI(:,2),ECI(:,3));
% hold on;
% grid on; 
% surf(X*6371*10^3, Y*6371*10^3, Z*6371*10^3);
 
figure(3);
polar (AZ, EL);
hold on;
grid on;                         
camroll(90);


