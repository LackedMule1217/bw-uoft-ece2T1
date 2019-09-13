% clear
clear;
clc;

% function
t=linspace(0,4,1001);
y=-2*(t-2).^3+3*(t-2)+1;

% plot
hold on;
plot(t,y,'-b','LineWidth',2);
grid on;
title('Level 1 Plot: Roots');
xlabel('Time (seconds)');
ylabel('Hover Height (m)');



% Level 1: roots
plot(1,0,'*r','LineWidth',5);
plot(1.6340,0,'*r','LineWidth',5);
plot(3.366,0,'*r','LineWidth',5);
legend('Drone Position','root 1','root 2','root 3');
hold off;