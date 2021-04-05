clear 
close all hidden


reftime=1:2000;
reftemp=(sin(reftime/20)-4.*(1-reftime/2000));
figure
hold on
subplot(2,1,1)
plot(reftime,reftemp)
xlabel('years')
ylabel('\Deltat')
xlim([1 max(reftime)])
title('Animated deglaciation')
    
% consider glacier slope of 15 degrees
% consider horizontal glacier flow of 25 cm per day
% then vertical glacier flow is 6.7 cm/day
% that is vertical 2 m/ month or 24 m per year
verticalannualflow=24;
altref=[0:verticalannualflow:1345]';
altref2=[0:verticalannualflow/10:1345]';

subplot(2,1,2)
hold on
slope=15; %degrees
% distancesfromsea=altref/tan(deg2rad(slope));
distancesfromsea=altref.^0.5/max(altref.^0.5)*max(altref)/tan(deg2rad(slope));
distancesfromsea2=altref2.^0.5/max(altref2.^0.5)*max(altref2)/tan(deg2rad(slope));
ylim([0 max(altref)*1.2])
xlim([0 max(distancesfromsea)])
stable=0;
year=0;
accumulated=altref.*0;
while stable==0
    year=year+1;
    
    deltat=interp1(reftime,reftemp,year);
    deltap=0;
    
    % in scotland
    month=1:12;
    monthnames=[{'Jan'},{'Feb'},{'Mar'},{'Apr'},{'May'},{'Jun'},{'Jul'},{'Aug'},{'Sep'},{'Oct'},{'Nov'},{'Dec'}];
    T0= [4,5,7,8,12,14,16,16,13,10,7,5]+deltat; % average temperature at sea levelAverage temper
    Trate=8; %degreees/km
    T= @(alt) T0-Trate*alt/1000;
    Precip=[175,125,150,100,75,100,100,125,125,175,175,175]+deltap; % mm
    Snow_accumulation=@(alt) Precip/1000 .* ( T(alt)<5 );
    % Day-night temperature range is c. 5 celsius => average day temperature is T+2.5
    % Considering thermal conductivity of the snow matle ~10 W//K/m^2, a latent heat of fusion of ~350kJ/kg and a density of ~0.3 g/l
    % 0.35*(60*60*24*30.5)/350E3/0.3;
    % 10*(60*60*24*30.5/2)/350E3/0.3;
    % Then, considering the day temperature, an average of 0.05 m of snow per month will be melted for each degree over 0
    Snow_melting=@(alt) max(0,T(alt)+2.5)*0.05;
    
    % then we can calculate the mass balance for each month
    Mb=@(alt) Snow_accumulation(alt)-Snow_melting(alt);
    
    

    MonthlyMb=Mb(altref);
    AnnualMb=sum(MonthlyMb,2);
    
    % remember last conditions
    lastyearacc=accumulated;
    % calculate flow
    accumulated=[accumulated(2:end);0];
    % calculate snow accumulation
    accumulated=max(0,accumulated+AnnualMb);
    % check if the total snow is different to last year
%     if accumulated==lastyearacc
%         stable=1;
%     end
    if year==max(reftime)
        stable=1;
    end
    
    accumulated2=interp1(altref,accumulated,altref2);
    
    % animated plot
    subplot(2,1,1)
    hold on
    plot(reftime(year),reftemp(year),'.r')
    subplot(2,1,2)
    front=max(altref2(accumulated2==0));
    distfront=interp1(altref2,distancesfromsea2,front);
    plot(distancesfromsea2,altref2+accumulated2*3,'-b','LineWidth',1)
    hold on
    if sum(accumulated2)>0
        text(distfront,front,'\downarrow','HorizontalAlignment','center','VerticalAlignment','bottom','Color','r')
    end
    plot(distancesfromsea2,altref2,'-k')
    ylim([0 max(altref)*1.2])
    xlim([0 max(distancesfromsea)])
    title(['Year ' num2str(year)])
    xlabel('Distance from coast')
    ylabel('Altitude')
    hold off
    pause( 0.02 );
    
   
end

return
% plot the glacier
slope=15; %degrees
distancesfromsea=altref/tan(deg2rad(slope));


figure
subplot(1,2,1)
hold on
plot(distancesfromsea/1000,accumulated+altref,'-b') % plot glacier
for n=1:length(distancesfromsea)
    plot([distancesfromsea(n),distancesfromsea(n)]/1000,[altref(n),accumulated(n)+altref(n)],'-b','LineWidth',2)
end
plot(distancesfromsea/1000,altref,'-k') % plot slope
ylabel('Altitude (m)')
xlabel('Km from sea')
% title(['Stable after ' num2str(year) ' years'])
title('Glacier on slope')
xlim([0 max(distancesfromsea/1000)])
ylim([0 max(altref)])


% figure
subplot(1,2,2)
hold on
plot(accumulated,altref,'-b') % plot glacier
% ylabel('Altitude (m)')
xlabel('Snow/ice thickness (m)')
title(['Stable after ' num2str(year) ' years'])
ylim([0 max(altref)])

% Calculate the accumulated snow (start in september [9] to minimize the chances of having snow at the beginning)
accumulated=0.*altref;
Snow_mass=0.*Mb(altref);
Mbmatrix=Mb(altref);
for monthstep=[9:12,repmat(1:12,1,year*2)]
accumulated=max(0,accumulated+Mbmatrix(:,monthstep));
Snow_mass(:,monthstep)=accumulated;
end

% snow chart
figure
subplot(2,1,1)
hold on
[X,Y]=meshgrid(1:12,altref);
Z=Snow_accumulation(altref)>0;
plot(X(Z==1),Y(Z==1),'*k')
Z=Snow_mass>0;
plot(X(Z==1),Y(Z==1),'ob')
contour(X,Y,T(altref),[0,-2.5],'-r')
ylabel('Alt.')
xlim([0.5 12.5])
set(gca,'xtick',1:12,'xticklabel',monthnames)
box on

subplot(2,1,2)
hold on
yyaxis left % only in Matlab
plot(month,Precip,'-b')
ylabel('P')
yyaxis right
plot(month,T0,'-r')
ylabel('Sea level T')
xlim([0.5 12.5])
set(gca,'xtick',1:12,'xticklabel',monthnames)
box on