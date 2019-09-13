% Plots a decaying sine function
clear;
clc;

x=linspace(0,5,101);
y1=exp(-x);
y2=sin(4*pi*x);
y=y1.*y2;

plot(x,y1,x,y2,x,y);
plot(x,y);



% Exercise #1: Making a Simple Script
clear;
clc;

x=linspace(-8,8,101);
y=(x.^2).*(sin(4*pi*x));

grid on;
plot(x,y);



% Exercise #2: Indexing Vectors
clear;
clc;

x=linspace(-8,8,101);
y=(x(1:end).^2).*(sin(4*pi*x(1:end)));

grid on;
plot(x(1:end),y(1:end));
