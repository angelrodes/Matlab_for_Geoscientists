clear
close all hidden

lat=56;

%% solar equations

% The declination of the Sun is the angle between the rays of the Sun and the plane of the Earth's equator.
% -23.44*cos(deg2rad(360/356*(days_after_Jan1+10)))
% https://en.wikipedia.org/wiki/Position_of_the_Sun#Calculations

declination=@(days_after_Jan1)-23.44*cos(deg2rad(360/356*(days_after_Jan1+10)));

% hour angle
% The angle may be expressed positive westward from 0° to 360°.
% The angle may be measured in degrees or in time, with 24h = 360° exactly. 
% https://en.wikipedia.org/wiki/Hour_angle

% hour angle 0-360
% hour_angle=@(hours_after_midnight)...
%     360/24.*...
%     ((hours_after_midnight-12).*(hours_after_midnight>=12)+...
%     (12+hours_after_midnight).*(hours_after_midnight<12));

% hour angle -180 - 180
hour_angle=@(hours_after_midnight)...
    180/12.*...
    (hours_after_midnight-12);

% The solar zenith angle is the angle between the zenith and the centre of the Sun's disc. 
% https://en.wikipedia.org/wiki/Solar_zenith_angle
solarzenith=@(latitude,days_after_Jan1,hours_after_midnight)...
    rad2deg(...
    acos(...
    sin(deg2rad(latitude)).*...
    sin(deg2rad(declination(days_after_Jan1)))+...
    cos(deg2rad(latitude)).*...
    cos(deg2rad(declination(days_after_Jan1))).*...
    cos(deg2rad(hour_angle(hours_after_midnight)))...
    )...
    );


% Equation of time
% Equation of time is the difference between the average solar time (usually measured by a clock) and the apparent solar time (time measured by a sundial).
% https://en.wikipedia.org/wiki/Equation_of_time
et=@(days_after_Jan1)...
    (...
    595*sin(deg2rad(198+1.9713*days_after_Jan1))+...
    442*sin(deg2rad(175+0.9856*days_after_Jan1))...
    )/60/60; % in days

% The solar azimuth angle is the azimuth angle of the Sun's position.
% https://en.wikipedia.org/wiki/Solar_azimuth_angle
% solarazimuth=@(latitude,days_after_Jan1,hours_after_midnight)...
%   180-rad2deg(...
%     asin(...
%     -sin(deg2rad(hour_angle(hours_after_midnight))).*...
%     cos(deg2rad(declination(days_after_Jan1)))./...
%     sin(deg2rad(solarzenith(latitude,days_after_Jan1,hours_after_midnight)))...
%     )...
%     );

% The solar azimuth angle is the azimuth angle of the Sun's position.
% https://en.wikipedia.org/wiki/Solar_azimuth_angle
% solarazimuthmorning=@(latitude,days_after_Jan1,hours_after_midnight)...
%     rad2deg(...
%     acos(...
%     (...
%     sin(deg2rad(declination(days_after_Jan1)))-...
%     cos(deg2rad(solarzenith(latitude,days_after_Jan1,hours_after_midnight))).*...
%     sin(deg2rad(latitude))...
%     )./(...
%     sin(deg2rad(solarzenith(latitude,days_after_Jan1,hours_after_midnight))).*...
%     cos(deg2rad(latitude))...
%     )...
%     )...
%     );

% % The solar azimuth angle is the azimuth angle of the Sun's position.
% % https://en.wikipedia.org/wiki/Solar_azimuth_angle
% solarazimuthmorning=@(latitude,days_after_Jan1,hours_after_midnight)...
%     rad2deg(...
%     acos(...
%     (...
%     sin(deg2rad(declination(days_after_Jan1))).*...
%     cos(deg2rad(latitude))-...
%     cos(deg2rad(hour_angle(hours_after_midnight))).*...
%     cos(deg2rad(declination(days_after_Jan1))).*...
%     sin(deg2rad(latitude))...
%     )./...
%     sin(deg2rad(solarzenith(latitude,days_after_Jan1,hours_after_midnight)))...
%     ));
% 
% solarazimuth=@(latitude,days_after_Jan1,hours_after_midnight)...
%     (hours_after_midnight<=12).*...
%     solarazimuthmorning(latitude,days_after_Jan1,hours_after_midnight)+...
%     (hours_after_midnight>12).*...
%     (360-solarazimuthmorning(latitude,days_after_Jan1,hours_after_midnight));



% simplified solar azimuth
solarazimuth=@(latitude,days_after_Jan1,hours_after_midnight)...
    hours_after_midnight*360/24+latitude.*0+days_after_Jan1.*0+et(days_after_Jan1);



%% calculate hours of sun

hoursinyear=0:1/60:365*24;
solarelevation=90-solarzenith(lat,hoursinyear/24,mod(hoursinyear,24));
solarinsolation=sin(deg2rad(solarelevation.*(solarelevation>0)));
sunnytimes=(solarelevation>0);
tstep=hoursinyear(2)-hoursinyear(1);
sunshines=hoursinyear([false,diff(sunnytimes)==1]);
sunsets=hoursinyear([false,diff(sunnytimes)==-1]);
lighthours=0*(1:365);
for d=1:365
    hours=(abs(hoursinyear/24-(d-0.5))<=0.5);
    lighthours(d)=sum(sunnytimes(hours))*tstep;
end

%% plots
figure
hold on

subplot(2,2,1)
hold on
plot(hoursinyear/24/365*12+1,solarelevation,'-k')
ylim([0 90])
xlim([0.99 12.99])
xlabel('Month')
ylabel('Solar elv.')
title(['Lat=' num2str(lat)])

subplot(2,2,2)
hold on
plot(sunshines/24,mod(sunshines,24),'.b')
plot(sunsets/24,mod(sunsets,24),'.r')
ylim([0 24])
xlim([1 365])
xlabel('Day')
ylabel('Time sunrise/set')
title(['Lat=' num2str(lat)])

subplot(2,2,3)
hold on
plot(1:365,lighthours,'-r')
plot([1,365],[12,12],'-g')
% ylim([0 24])
xlim([1 365])
xlabel('Day')
ylabel('Hours of light')
title(['Lat=' num2str(lat)])

subplot(2,2,4)
hold on
plot(hoursinyear/24/365*12+1,solarinsolation,'-k')
ylim([0 1])
xlim([0.99 12.99])
xlabel('Month')
ylabel('Solar insolation')
title(['Total = ' num2str(sum(solarinsolation)/length(solarinsolation)*100) '%'])



days=1:365;
decs=declination(days);
specialdays=days(decs==max(decs) | decs==min(decs) | decs==median(decs));

figure
subplot(2,3,1)
hold on
days=1:365;
plot(days,declination(days)-lat,'-k')
xlim([0 365])
ylabel('declination')
xlabel('day in year')
title(['Lat=' num2str(lat)])

subplot(2,3,2)
hold on
for day=specialdays
    hours=0:0.1:24;
    zen=solarzenith(lat,day,hours);
    azi=solarazimuth(lat,day,hours);
    plot(azi,90-zen,'-');
end
ylabel('solar elevation')
xlabel('solar azimuth')
xlim([0 360])
ylim([0 90])

subplot(2,3,3)
hold on
day=1:365;
    hours=13.00;
    zen=solarzenith(lat,day,hours);
    azi=solarazimuth(lat,day,hours);
    plot(azi,90-zen,'-');

ylabel('solar elevation')
xlabel('solar azimuth')
title('Analemma')
% xlim([0 360])
% ylim([0 90])
title([num2str(hours) 'h'])

subplot(2,3,4)
hold on
day=1:365;
    zen=solarzenith(lat,day,hours);
    azi=solarazimuth(lat,day,hours);
    plot(day,et(day)*60,'-');
ylabel('delta t (min.)')
xlabel('day')
% xlim([0 24])
% ylim([0 90])

subplot(2,3,5)
hold on
day=1:365;
    zen=solarzenith(lat,day,hours);
    azi=solarazimuth(lat,day,hours);
    plot(day,90-zen,'-');
ylabel('solar elevation')
xlabel('day')
% xlim([0 24])
% ylim([0 90])



subplot(2,3,6)
hold on
for day=specialdays
    hours=0:0.1:24;
    zen=solarzenith(lat,day,hours);
    azi=solarazimuth(lat,day,hours);
    plot(hours,azi,'-');
end
xlabel('hours')
ylabel('solar azimuth')
xlim([0 24])
% ylim([0 90])


