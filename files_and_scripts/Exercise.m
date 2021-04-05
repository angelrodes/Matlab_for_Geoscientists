clear
close all hidden

%% Production rates
P=[4.35,0.0985,0.0855]; % production rates in at/g/a
L=[160,1137,1842]; % attenauation lengths in g/cm^2
l=4.9975E-7; % decay contant in a^(-1)

%% Field data
density=1.8; % g/cm^3
z=[250 163 113 73 43 11]; % depth of the sameples in cm
Be10=[25    45    60   100   140   200]*1e3; % 10Be concentrations in atoms/g
Be10error=[2 3 5 7 10 15]*1e3; % 10Be uncertainties in atoms/g


%% Minimization approx
tic % start the chronometer
nummodels=10000; % define how many models
C0i=rand(1,nummodels)*min(Be10); % random inheritences
ti=rand(1,nummodels)*0.3e6; % random ages
erosioni=rand(1,nummodels)*0.01; % random erosion rates
chisquarevalues=rand(1,nummodels)*NaN; % allocate memory for the chi square array

% start testing models
for n=1:nummodels
    erosionref=[0,logspace(-5,2,100),10^10]'; % define an array with erosion rates
    % calculate the deviations corresponding to each erosion rate
    % deviations are defined as the sum of (Cmodel-Csample)/Uncertainty
    %     for all the samples
    deviations=...
        sum(...
        (exposure_model(P,L,l,density,z,C0i(n),erosionref,ti(n))-Be10)./...
        Be10error...
        ,2);
    % Interpolate the erosion rate values to find the one the model that
    % fit the data better (for the age and Co corresponding to this random
    % model). THen store the result at erosioni(n), ooverwriting the
    % previously defined value.
    erosioni(n)=interp1(deviations,erosionref,0);
    
    % calculate the model concetratios for the new erosion rate at the depths z
    Cmodel=exposure_model(P,L,l,density,z,C0i(n),erosioni(n),ti(n));
    % calculate the chi squared for this model
    chisquarevalues(n)=sum(((Cmodel-Be10)./Be10error).^2);
end
toc % stop the chronometer and display the time

DOF=length(Be10)-3; % degrees of freedom (# of samples - # of parameters)
minchi=min(chisquarevalues); % minimum chi-square value corresponding to our best model
best=find(chisquarevalues==minchi); % location of the best model
onesigma=find(chisquarevalues<minchi+DOF); % location of the models fitting one sigma

% display previous infrormation
disp(['Min chi-squared value = ' num2str(minchi)])
disp([num2str(length(onesigma)) ' models fitting one sigma'])
disp(['Age: ' num2str(min(ti(onesigma))/1e3) ' - '...
    num2str(max(ti(onesigma))/1e3) ' ka'])
disp(['Erosion: ' num2str(min(erosioni(onesigma))*1e4) ' - '...
    num2str(max(erosioni(onesigma))*1e4) ' m/Ma'])
disp(['Inheritance: ' num2str(min(C0i(onesigma))) ' - '...
    num2str(max(C0i(onesigma))) ' atoms/g'])


figure % start a figure

subplot(3,2,2) % age plot
hold on
plot(ti/1e3,chisquarevalues,'.b') % plot the age results
plot([0,max(ti)/1e3],[0,0]+DOF+minchi,'--k') % plot limit of one-sigma
xlim([0 max(ti)/1e3])
ylim([0 min(chisquarevalues)+DOF*3])
xlabel('Age (ka)')
ylabel('\chi^2')
grid on
box on

subplot(3,2,4) % erosion plot
hold on
plot(erosioni*1e4,chisquarevalues,'.b')
plot([0,max(erosioni)*1e4],[0,0]+DOF+minchi,'--k')
ylim([0 min(chisquarevalues)+DOF*3])
xlim([0 max(erosioni)*1e4])
xlabel('\epsilon (m/Ma)')
ylabel('\chi^2')
grid on
box on

subplot(3,2,6) % inheritance plot
hold on
plot(C0i,chisquarevalues,'.b')
plot([0,max(C0i)],[0,0]+DOF+minchi,'--k')
ylim([0 min(chisquarevalues)+DOF*3])
xlim([0 max(C0i)])
xlabel('C_0')
ylabel('\chi^2')
grid on
box on

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
xlabel('[^{10}Be]')
ylabel('Depth (cm)')
grid on
set(gca, 'XAxisLocation', 'top')
ylim([min(-zplot) 0])

return

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
% set(gca,'Yscale','log')
