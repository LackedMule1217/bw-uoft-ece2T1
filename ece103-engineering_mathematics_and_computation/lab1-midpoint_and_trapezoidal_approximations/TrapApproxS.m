function [area] = TrapApproxS(n)
delta = (3/n);
x = linspace(0,3,n+1);
y = ((sqrt(x(1:end-1)+1)+sqrt(x(2:end)+1))/2)*delta;
area = sum(y);
plot((x(1:end-1)+x(2:end))/2, y, 'r-');
end