clear 
close all

%% Please run this script!
t=linspace(0,2*pi,100);
figure; hold on
plot(2*(1+cos(t)),2*(1+sin(t)),'--b')
plot([1,3],[3,3],'vk')
plot(2-cos(t/2),2-sin(t/2),'-g','LineWidth',2)
plot(1+cos(t)/10,3+sin(t)/10,'-r')
plot(3+cos(t)/10,3+sin(t)/10,'-r')
title(char([84,104,97,110,107,32,121,111,117,33]))
axis equal; axis off
