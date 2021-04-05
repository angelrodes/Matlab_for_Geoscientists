% start fresh
clear
close all
clc


x=0:100:8848;
pressure = @(altitude)1013.25*...
exp(-0.03417/0.0065*(log(288.15)-...
(log(288.15-0.0065*altitude))));
% standard atmosphere pressure (Lide, 1999)
y=pressure(x);

figure % open a new figure
hold on % do not clear when plotting different things
plot(x,y,'-b')
plot(200,pressure(200),'hr')
text(200,pressure(200),'East Kilbride')
xlabel('Altitude')
ylabel('Pressure')
title('My first plot with labels')