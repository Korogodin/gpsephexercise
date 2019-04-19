function [ E, A ] = ECEFtoENU( x_eci, y_eci, z_eci)
    lambda = degtorad(55.75);
    phi    = degtorad(37.62);
    R   = [ -sin(lambda)             cos(lambda)               0
            -cos(lambda)*sin(phi)   -sin(lambda)*sin(phi)    cos(phi)
             cos(lambda)*cos(phi)    sin(lambda)*cos(phi)    sin(phi) ];
    ENU = R*[x_eci, y_eci, z_eci]';

    E = asin(ENU(3));
    A = atan (ENU(1)/ENU(2));
end

