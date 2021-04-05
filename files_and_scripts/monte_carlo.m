clear
close all hidden

%% Production rates
P=[4.35,0.0985,0.0855]; % production rates in at/g/a
L=[160,1137,1842]; % attenauation lengths in g/cm^2
l=4.9975E-7; % decay contant in a^(-1)

%% Field data
density=1.8; % g/cm^3
z=[267,195,141,95,46,3]; % depth of the sameples in cm
Be10=[91000,184000,265000,430000,732000,1070000]; % 10Be concentrations in atoms/g
Be10error=[9100,16000,18000,29000,61000,81000]; % 10Be uncertainties in atoms/g



%% Monte carlo experiment
tic % start the chronometer
nummodels=100000; % define how many models
C0i=rand(1,nummodels)*min(Be10); % random inheritences
ti=rand(1,nummodels)*3e6; % random ages
erosioni=rand(1,nummodels)*0.005; % random erosion rates
chisquarevalues=rand(1,nummodels)*NaN; % allocate memory for the chi square array

% calculate the chi squared vales for each model
for n=1:nummodels
    % calculate the model concetratios for the depths z
    Cmodel=exposure_model(P,L,l,density,z,C0i(n),erosioni(n),ti(n));
    % calculate the chi squared for this model
    chisquarevalues(n)=sum(((Cmodel-Be10)./Be10error).^2);
end

toc % stop the chronometer and display the time

DOF=3; % degrees of freedom (# of samples - # of parameters)
minchi=min(chisquarevalues); % minimum chi-square value corresponding to our best model
best=find(chisquarevalues==minchi); % location of the best model
onesigma=find(chisquarevalues<minchi+DOF); % location of the models fitting one sigma

% display previous infrormation
disp(['Min chi-squared value = ' num2str(minchi)])
disp([num2str(length(onesigma)) ' modles fitting one sigma'])
disp(['Age: ' num2str(min(ti(onesigma))/1e3) ' - '...
    num2str(max(ti(onesigma))/1e3) ' ka'])
disp(['Erosion: ' num2str(min(erosioni(onesigma))*1e4) ' - '...
    num2str(max(erosioni(onesigma))*1e4) ' m/Ma'])
disp(['Inheritance: ' num2str(min(C0i(onesigma))) ' - '...
    num2str(max(C0i(onesigma))) ' atoms/g'])


figure % start a figure

subplot(3,2,2) % age plot
hold on
plot(ti,chisquarevalues,'.b') % plot the age results
plot([0,max(ti)],[0,0]+DOF+minchi,'--k') % plot limit of one-sigma
xlim([0 max(ti)])
ylim([0 min(chisquarevalues)+DOF*3])
xlabel('t')
ylabel('chi-sq')

subplot(3,2,4) % erosion plot
hold on
plot(erosioni,chisquarevalues,'.b')
plot([0,max(erosioni)],[0,0]+DOF+minchi,'--k')
ylim([0 min(chisquarevalues)+DOF*3])
xlim([0 max(erosioni)])
xlabel('erosion')
ylabel('chi-sq')

subplot(3,2,6) % inheritance plot
hold on
plot(C0i,chisquarevalues,'.b')
plot([0,max(C0i)],[0,0]+DOF+minchi,'--k')
ylim([0 min(chisquarevalues)+DOF*3])
xlim([0 max(C0i)])
xlabel('C0')
ylabel('chi-sq')

subplot(3,2,[1 5]) % plot the depth profile
hold on
zplot=0:max(z)+10; % select depth values to plot
% plot models fitting one-sigma
for n=onesigma
    plot(exposure_model(P,L,l,density,zplot,C0i(n),erosioni(n),ti(n)),-zplot,'-','Color',[0.7 0.7 0.7])
end
% plot the best fitting model
plot(exposure_model(P,L,l,density,zplot,C0i(best),erosioni(best),ti(best)),-zplot,'-b')
% plot the samples
for n=1:length(z)
    plot(Be10(n),-z(n),'*r')
    plot([Be10(n)-Be10error(n),Be10(n)+Be10error(n)],[-z(n),-z(n)],'-r')
end
xlabel('[10Be]')
ylabel('-depth')

figure % plot the relation between age and erosion rate
hold on
% models fittting one sigma
for n=onesigma
    plot(erosioni(n),ti(n),'.k')
end
% best fit
plot(erosioni(best),ti(best),'*b')
xlabel('erosion rate')
ylabel('age')

return

close all hidden
zref=0:300; % depth reference in cm
concentrations=exposure_model(P,L,l,density,zref,0,0.0001,10000);
plot(concentrations,-zref,'-b')
