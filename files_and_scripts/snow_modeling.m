clear 
close all hidden

% ask altitude in m
% alt = input('Please input altitude in meters:')

figure% remove this
step=0;% remove this
for alt=[200,500,600,750,1000,1345,1500,2000]% remove this
    step=step+1;% remove this
    
% in scotland
month=1:12;
monthnames=[{'Jan'},{'Feb'},{'Mar'},{'Apr'},{'May'},{'Jun'},{'Jul'},{'Aug'},{'Sep'},{'Oct'},{'Nov'},{'Dec'}];
T0= [4,5,7,8,12,14,16,16,13,10,7,5]; % average temperature at sea level
Trate=8; %degreees/km
T=T0-Trate*alt/1000;
Precip=[175,125,150,100,75,100,100,125,125,175,175,175];
Snow_accumulation=Precip .* ( T<5 );
% Day-night temperature range is c. 5 celsius => average day temperature is T+2.5
% Considering thermal conductivity of the snow matle ~10 W//K/m^2, a latent heat of fusion of ~350kJ/kg and a density of ~0.3 g/l
% 0.35*(60*60*24*30.5)/350E3/0.3;
% 10*(60*60*24*30.5/2)/350E3/0.3;
% Then, considering the day temperature, an average of 0.1 m of snow per month will be melted for each degree over 0
Snow_melting=max(0,T+2.5)*100; 

% then we can calculate the mass balance for each month
Mb=Snow_accumulation-Snow_melting;


% Calculate the accumulated snow (start in september [9] to minimize the chances of having snow at the beginning)
accumulated=0;
Snow_mass=zeros(1,12);
for monthstep=[9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12]
accumulated=max(0,accumulated+Mb(monthstep));
Snow_mass(monthstep)=accumulated;
end

% If we find snow in august => Glacier!
if Snow_mass(8)>0
%     disp('We have a glacier here!')
disp(['We have a glacier here! ' num2str(sum(Mb))]) % remove this
else % remove this
    disp(['No a glacier here! ' num2str(sum(Mb))]) % remove this

end

% plot snow accumulation
% figure
subplot(3,5,step)% remove this
hold on
plot(month,Snow_mass/1000,'-b')

if Snow_mass(8)>0 % remove this
plot(month,Snow_mass/1000,'-r')% remove this
end% remove this

xlabel('Month')
ylabel('Snow depth (m)')
title([num2str(alt) ' m asl'])
ylim([0 max(0.1,max(Snow_mass/1000))]) % remove this
xlim([1 12])
end
