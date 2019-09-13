% Author: Shi Jie (Barney) Wei
% Date: 02/01/19

function [Etot,Ex,Ey,Ez]=lineofcharge(h,rhol,x,y,z,N)
    epsilon=8.854e-12;
    dz=2*h/N; % Discretize the total line length of 2h into N pieces
    zprime=linspace(-h,h,N); % The linspace command creates a vector that ranges
    
    % from -h to h and has N elements with equal spacing
    % Use a vectorized approach to "walk" along the line
    integrand=dz./((x^2+y^2+(z-zprime).^2).^(3/2));
    dEx=integrand;
    dEy=integrand;
    dEz=(z-zprime).*integrand;
    
    % Do the "integration" by summing up the differential pieces that result from
    % each value of zprime.
    Ex=((rhol*x)/(4*pi*epsilon))*sum(dEx);
    Ey=((rhol*y)/(4*pi*epsilon))*sum(dEy);
    Ez=(rhol/(4*pi*epsilon))*sum(dEz);
    Etot=(Ex^2+Ey^2+Ez^2)^0.5;