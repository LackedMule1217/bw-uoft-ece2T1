% Author: Shi Jie (Barney) Wei
% Date: 01/14/19

% Function that will approximate the value of the integral
% Input:
%   1) Integration limit: x1
%   2) Integration limit: x2


function [y] = integration(x1, x2)
    n = 1000;
    vec_coef = [0;0;1];
    x_range = linspace(x1, x2, n);
    x_diff = (x2 - x1) / n;

    y = 0;
    for index1 = 1:length(x_range)
        for index2 = 1:length(vec_coef)
            result = vec_coef(index2) * x_range(index1)^(index2-1) * x_diff;
            y = y + result;
        end
    end
end