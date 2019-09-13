
%clear
clear;
clc;

%variable
a1=15*(pi/180);
a2=45*(pi/180);
a3=75*(pi/180);
v0=9.81;
y0=0;
g=9.81;
t=linspace(0,10,1000);

%function 1
x1=(v0).*cos(a1).*t;
y1=-((1/2)*g.*(t.^2)) + ((v0).*sin(a1).*t) + y0;

%function 2
x2=(v0).*cos(a2).*t;
y2=-((1/2)*g.*(t.^2)) + ((v0).*sin(a2).*t) + y0;

%function 3
x3=(v0).*cos(a3).*t;
y3=-((1/2)*g.*(t.^2)) + ((v0).*sin(a3).*t) + y0;


% plot
hold on;
plot(x1,y1,'-r','LineWidth',2);
plot(x2,y2,'-b','LineWidth',2);
plot(x3,y3,'-g','LineWidth',2);
grid on;
xlim([0,10]);
ylim([0,5]);
legend('15 degrees', '45 degrees', '75 degrees');
title('Motion of a Projectile');
xlabel('Distance (m)');
ylabel('Height (m)');