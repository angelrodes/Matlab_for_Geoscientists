%% This is my first calibration script

clear % clear all previous data
close all hidden % close all figures

% Nominal concentrations of iron in some standards
STDSnominal=[0,0.98,4.56,10.78,19.34,0,1.05,5.1,9.94,18.95];
% associated uncertainties
STDSnominal_uncert=[0,0.02,0.06,0.11,0.19,0,0.02,0.06,0.10,0.19];
% ICP measured values of standards in counts per second (cps)
STDScps=[425,1724,7443,15221,30973,146,1832,7378,15124,27701];
% associated uncertainties
STDScps_uncert=[214,140,377,329,381,249,311,280,1129,1140];

% Define x and y
x=STDSnominal; dx=STDSnominal_uncert;
y=STDScps; dy=STDScps_uncert;

% ICP measured values of unknowns in counts per second (cps)
SAMPLEScps=[9782,28746,13471,5870,28173,30492,13739,3588,813,12805];
% associated uncertainties
SAMPLEScps_uncert=[181,1042,1214,76,2899,2532,809,243,275,716];

% define y for unknowns
yunk=SAMPLEScps; dyunk=SAMPLEScps_uncert;

%% Calibration and uncertainty
myfit = leastsquares(x,y);
myfiterror= mean(abs(y-myfit(x)));

%% Calibration line
xcal=linspace(min(x),max(x),100);
ycal=myfit(xcal);
ycalerror=myfiterror;

%% BEC, LOD, LOQ
bec=-interp1(ycal,xcal,0,'linear','extrap');
dbec=interp1(ycal,xcal,myfiterror,'linear','extrap')+bec;
LOD=3*dbec;
LOQ=10*dbec;

%% Calibrate unknowns
xunk=interp1(ycal,xcal,yunk,'linear','extrap');
calibrationuncert=...
  interp1(ycal,xcal,yunk+myfiterror,'linear','extrap')-xunk;
measurementuncert=...
  interp1(ycal,xcal,yunk+dyunk,'linear','extrap')-xunk;
dxunk=sqrt(calibrationuncert.^2+measurementuncert.^2);

%% Start a figure
figure
hold on

% plot the unknowns with error-bars
for n=1:length(xunk)
  plot(xunk(n),yunk(n),'.k')
  plot([xunk(n)-dxunk(n),xunk(n)+dxunk(n)],[yunk(n),yunk(n)],'-k')
  plot([xunk(n),xunk(n)],[yunk(n)-dyunk(n),yunk(n)+dyunk(n)],'-k')
end

% plot the standards with ellipsis
for n=1:length(x)
  theta=linspace(0,2*pi,100);
  xi=x(n)+dx(n)*cos(theta);
  yi=y(n)+dy(n)*sin(theta);
  plot(xi,yi,'-b')
end
plot(x,y,'.b')

% plot the calibration
plot(xcal,ycal,'-r')
plot(xcal,ycal+myfiterror,'--r')
plot(xcal,ycal-myfiterror,'--r')

% put labels
ylabel('Intensity (cps)')
xlabel('Concentration (ppm)')


