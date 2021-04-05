%% Start fresh!
clear 
close all

%% data: GISS Surface Temperature Analysis (GISTEMP v4)
gistempdata=csvread('gistemp.csv',1,0);
years=gistempdata(:,1);
temp=gistempdata(:,2);

%% interpolation and extrapolation
figure
hold on
plot(years,temp,'*k')

% linear interpolation
myyears=min(years):1:max(years);
mytemp=interp1(years,temp,myyears);
plot(myyears,mytemp,'-r')

% spline interpolation
myyears=min(years):1:max(years);
mytemp=interp1(years,temp,myyears,'spline');
plot(myyears,mytemp,'-b')

% linear extrapolation
myyears=max(years):1:max(years)+100;
mytemp=interp1(years,temp,myyears,'linear','extrap');
plot(myyears,mytemp,'--r')

% spline extrapolation
myyears=max(years):1:max(years)+100;
mytemp=interp1(years,temp,myyears,'spline','extrap');
plot(myyears,mytemp,'--b')



%% Smoothing

smoothingtime=50;
yearssmooth=1900:10:2000;
for n=1:length(yearssmooth)
   % select data around the year yearssmooth(n)
   selecteddata=(abs(yearssmooth(n)-years)<smoothingtime/2);
   tempsmooth(n)=mean(temp(selecteddata));
end
plot(yearssmooth,tempsmooth,'-m')

% extrapolate the smoothed temperatures
myyears=2000:1:2120;
mytemp=interp1(yearssmooth,tempsmooth,myyears,'linear','extrap');
plot(myyears,mytemp,'--m')

ylim([min(temp) 4])
xlim([min(years) max(years)+100])
xlabel('year')
ylabel('\DeltaT')
title('Playing with GISTEMP data')