% Author: Shi Jie (Barney) Wei
% Date: 01/14/19
% These commented lines directly below the function line will be displayed if
% you type help polynomialvalue at the command prompt. Often it is useful to
% give a copy of the function call so you can clearly see what the input and
% output variables are, meaning:
% [y]=polynomialvalue(x,plotflag)
% If plotflag is set to 1, the polynomial will be plotted.
% Otherwise the plot will not be created.

function [y]=polynomial_value(x,plotflag)
y = 6*x.^3+8*x.^2-3*x+12;
if plotflag == 1
figure;
plot(x,y,'b--');
end