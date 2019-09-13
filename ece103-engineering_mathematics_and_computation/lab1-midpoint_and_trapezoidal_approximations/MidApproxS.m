function [area] = midpt(n)
delta = 3/n;
x = linspace(0,3,n+1);
xbar = (x(1:end-1) + x(2:end)) * 0.5;
f_xbar = sqrt(xbar + 1).*delta;
area = sum(f_xbar);
plot(xbar, f_xbar, 'r-');
end