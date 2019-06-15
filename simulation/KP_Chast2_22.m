clear all;
close all;
tic;
% считывание эфемерид из файла BINR_evening.nav на НКА с заданным номером
delimiterIn = ' ';
headerlinesIn = 5;
filename = 'C:\Users\Anna\Documents\Linux\LOGZZZ\BINR_evening.nav';
A = importdata(filename,delimiterIn,headerlinesIn);
ephemerides = A.data(:,1:6);
PRN = 24;
k = 0;
numbers = zeros(size(ephemerides,1)/8);
time = zeros(size(ephemerides,1)/8);
for i = 1:8:size(ephemerides,1)
    if ephemerides(i,1) == PRN
        k = k + 1;
        numbers(k) = i;
        time(k) = ephemerides(i,5);
    end
end

nomer = 1;
% запись необходимых эфемерид в матрицу
R = ephemerides((numbers(nomer)+1):(numbers(nomer)+5),:);
% запись эфемерид в текстовый файл
f = fopen('C:\Users\Anna\Documents\Linux\LOGZZZ\ephemeridy.txt','w');
fprintf(f,'%f %f %f %f \n',R);
fclose(f);
% задание эфемерид для расчета
toe = R(3,1);
sqrt_a = R(2,4);
e = R(2,2);
M0 = R(1,4);
omega = R(4,3);
i0 = R(4,1);
OMEGA0 = R(3,3);
delta_n = R(1,3);
IDOT = R(5,1);
OMEGADOT = R(4,4);
cuc = R(2,1);
cus = R(2,3);
crc = R(4,2);
crs = R(1,2);
cic = R(3,2);
cis = R(3,4);
% константы
mu=3.986004418E14;
OMEGADOTe = 7.2921151467E-5;
% АЛГОРИТМ РАСЧЕТА ПОЛОЖЕНИЯ СПУТНИКА В GPS
A = (sqrt_a)^2;
t = ((84-3)*3600):0.1:((96-3)*3600);   % тут за 12 часов надо
N = size(t,2);
for k = 1:N
    tk = t(k) - toe;
    if tk > 302400
        tk = tk - 604800;
    end
    if tk < -302400
        tk = tk + 604800;
    end
    
    Mk = M0 + (sqrt(mu/A^3) + delta_n) * tk;
    % решение уравнения Кеплера
    m=1;
    w(1)=0;
    while 1
        w(m+1)=Mk+e*sin(w(m));
        if abs(w(m+1)-w(m))<10^(-5)
            break
        end
        m=m+1;
    end
    Ek=w(m+1);
    vk = atan2((sqrt(1-e^2)*sin(Ek)),cos(Ek)-e);
    uk = omega + vk + cuc*cos(2*(omega+vk))+cus*sin(2*(omega+vk));
    rk = A*(1-e*cos(Ek))+crc*cos(2*(omega+vk))+crs*sin(2*(omega+vk));
    ik = i0+IDOT*tk+cic*cos(2*(omega+vk))+cis*sin(2*(omega+vk));
    x_k = rk*cos(uk);
    y_k = rk*sin(uk);
    
    lk = OMEGA0 - OMEGADOTe*toe+(OMEGADOT-OMEGADOTe)*tk;
    lk1 = OMEGA0 - OMEGADOTe*toe;
    % расчет координат в неинерциальной системе
    x(k) = x_k*cos(lk)-y_k*cos(ik)*sin(lk);
    y(k) = x_k*sin(lk)+y_k*cos(ik)*cos(lk);
    z(k) = y_k*sin(ik);
    % расчет координат в инерциальной системе
    x1(k) = x_k*cos(lk1)-y_k*cos(ik)*sin(lk1);
    y1(k) = x_k*sin(lk1)+y_k*cos(ik)*cos(lk1);
    z1(k) = y_k*sin(ik);
end
% построение графиков
[X,Y,Z] = sphere(50);
surf(X*6400000,Y*6400000,Z*6400000)
hold on
plot3(x,y,z,'b')
plot3(x1,y1,z1,'r')
grid on
% colormap(gray)
daspect([1 1 1])
% сохранение траектории в текстовый файл
F = [x',y',z'];
f = fopen('C:\Users\Anna\Documents\Linux\LOGZZZ\testmatlab.txt','w');
fprintf(f,'%f %f %f\n',F');
fclose(f);
hold on
% координаты Москвы, расчитанные в первом этапе
position = [2835903.37, 2192470.92, 5265921.01];
plot3(position(1),position(2),position(3),'*');
lat = atan(position(3)/sqrt(position(1)^2+position(2)^2));
lon = acos(position(1)/sqrt(position(1)^2+position(2)^2));
h = 180.59;
% пересчет координат из глобальной неинерциальной СК к локальной (ENU)
for k = 1:N
    [x0(k) y0(k) z0(k)] = ecef2enu(x(k),y(k),z(k),lat,lon,h,wgs84Ellipsoid,'radians');
    if z0(k)>0
        teta(k) = atan(sqrt(x0(k)^2+y0(k)^2)/z0(k));
        r(k) = sqrt(x0(k)^2+y0(k)^2+z0(k)^2);
        if x0(k) > 0
            phi(k) = atan(y0(k)/x0(k));
        elseif (x0(k)<0)&&(y0(k)>0)
            phi(k) = -atan(y0(k)/x0(k))+3*pi/2;
        elseif (x0(k)<0)&&(y0(k)<0)
            phi(k) = -atan(y0(k)/x0(k))-pi/2;
        end
    else teta(k) = NaN;
        r(k) = NaN;
        phi(k) = NaN;
    end
    k;
end

% Построение SkyView
figure;
polar(phi,teta*180/pi-pi,'r')
toc;
