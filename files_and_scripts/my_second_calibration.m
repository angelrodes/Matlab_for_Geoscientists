%% This is my second calibration script

clear % clear all previous data
close all hidden % close all figures

% Nominal concentrations of iron in some standards
STDSppm=[0,0.98,4.56,10.78,19.34,0,1.05,5.1,9.94,18.95];
% associated uncertainties
STDSppm_uncert=[0,0.02,0.06,0.11,0.19,0,0.02,0.06,0.10,0.19];
% ICP measured values of standards in counts per second (cps)
STDScps=[425,1724,7443,15221,30973,146,1832,7378,15124,27701];
% associated uncertainties
STDScps_uncert=[214,140,377,329,381,249,311,280,1129,1140];


% ICP measured values of unknowns in counts per second (cps)
SAMPLEScps=[9782,28746,13471,5870,28173,30492,13739,3588,813,12805];
% associated uncertainties
SAMPLEScps_uncert=[181,1042,1214,76,2899,2532,809,243,275,716];


%% Calibration and uncertainties
% build a reference calibration
CPSref=linspace(-abs(min(STDScps)),max(STDScps),100);
PPMref=NaN*CPSref;
PPMref_uncert=NaN*CPSref;
% make a simple fit
[ simplefit ] = leastsquares(STDScps,STDSppm);
% calculate the scatter of this simple fit as a function of cps
[ simplefit_uncert ] = leastsquares(STDScps,abs(STDSppm-simplefit(STDScps)));

% simulate the noise due to uncertainties in differnet rows
simulations=1000;
PPM=zeros(simulations,length(CPSref));
for s=1:simulations
    x=normrnd(STDScps,STDScps_uncert);
    y=normrnd(STDSppm,STDSppm_uncert);
    [ myfit ] = leastsquares( x,y );
    PPM(s,:)=myfit(CPSref);
end
% cCalculate the averages for each column
PPMref=mean(PPM,1);
% include the uncertainty of the fit and the noise
PPMref_uncert=sqrt(std(PPM,1).^2+simplefit_uncert(CPSref).^2);


%% BEC, LOD, LOQ
bec=-interp1(CPSref,PPMref,0,'linear','extrap');
dbec=abs(interp1(CPSref,PPMref_uncert,0,'linear','extrap'));
LOD=3*dbec;
LOQ=10*dbec;

%% Calibrate unknowns
SAMPLESppm=interp1(CPSref,PPMref,SAMPLEScps,'linear','extrap');
calibrationuncert=...
  interp1(CPSref,PPMref_uncert,SAMPLEScps,'linear','extrap');
measurementuncert=...
  interp1(CPSref,PPMref,SAMPLEScps+SAMPLEScps_uncert,'linear','extrap')-SAMPLESppm;
SAMPLESppm_uncert=sqrt(calibrationuncert.^2+measurementuncert.^2);

%% Start a figure
figure
hold on

% plot the unknowns with external-error-bars
for n=1:length(SAMPLEScps)
  plot(SAMPLEScps(n),SAMPLESppm(n),'.k')
  plot([SAMPLEScps(n)-SAMPLEScps_uncert(n),SAMPLEScps(n)+SAMPLEScps_uncert(n)],[SAMPLESppm(n),SAMPLESppm(n)],'-k')
  plot([SAMPLEScps(n),SAMPLEScps(n)],[SAMPLESppm(n)-SAMPLESppm_uncert(n),SAMPLESppm(n)+SAMPLESppm_uncert(n)],'-k')
end

% plot the standards with internal error-ellipsis
for n=1:length(x)
  theta=linspace(0,2*pi,100);
  xi=SAMPLEScps(n)+SAMPLEScps_uncert(n)*cos(theta);
  yi=SAMPLESppm(n)-measurementuncert(n)*sin(theta);
  plot(xi,yi,'-k')
end

% plot the standards with ellipsis
for n=1:length(x)
  theta=linspace(0,2*pi,100);
  xi=STDScps(n)+STDScps_uncert(n)*cos(theta);
  yi=STDSppm(n)+STDSppm_uncert(n)*sin(theta);
  plot(xi,yi,'-b')
  plot(STDScps(n),STDSppm(n),'.b')
end
% plot the calibration
plot(CPSref,PPMref,'-r')
plot(CPSref,PPMref+PPMref_uncert,'--r')
plot(CPSref,PPMref-PPMref_uncert,'--r')
xlim([0 max(SAMPLEScps)*1.2])
text(0,-bec,'\leftarrow BEC')

% put labels
xlabel('Intensity (cps)')
ylabel('Concentration (ppm)')

%% report

clc % clear the command window
disp(['Blank equivalent concentration: ' num2str(bec) ' ppm'])
disp(['Limit of detection: ' num2str(LOD) ' ppm'])
disp(['Limit of quantification: ' num2str(LOQ) ' ppm'])
disp(['Concentrations and internal and external uncertainties:'])
for n=1:length(SAMPLESppm)
    decimalpositions=1-floor(log10(measurementuncert(n)));
    concentration=round(SAMPLESppm(n),decimalpositions);
    interror=round(measurementuncert(n),decimalpositions);
    exterror=round(SAMPLESppm_uncert(n),decimalpositions);
    if SAMPLESppm(n)<LOD
        disp(['Sample#' num2str(n) ': < ' num2str(LOD) ' ppm'])
    elseif SAMPLESppm(n)<LOQ
        disp(['Sample#' num2str(n) ': ~ ' num2str(concentration) ' ppm'])
    else
        disp(['Sample#' num2str(n) ': ' num2str(concentration) ' +/- ' num2str(interror) ' (' num2str(exterror) ') ppm'])
    end
end

