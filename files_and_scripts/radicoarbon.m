%% import calibration curve
% You can download the calibration data from
% https://journals.uair.arizona.edu/index.php/radiocarbon/article/downloadSuppFile/16947/275
fid = fopen('16947-25973-2-SP.14c');
imported = textscan(fid, '%f %f %f %f %f',...
'HeaderLines', 12,'Delimiter',',');
fclose(fid);

% select the data from the calibnration curve
calBP=imported{1};
C14=imported{2};
% note that we are ignoring the errors in  (imported{3}

%% interpolate calibration curve to arrays of 1 position per calibrated year
refcalBP=min(calBP):1:max(calBP);
refC14=interp1(calBP,C14,refcalBP);

%% input our data
C14age=2000;
C14ageerr=20; % one sigma error

% calculate probabilities of my data
% reuse the function created previously
C14probs=normalprobs(refC14,C14age,C14ageerr);

%% Plot the calibration curve and our data
% select only the "most" probable data to plot
sel=(C14probs>max(C14probs)/1000);

figure % start figure

% plot the part of the calibration curve that is relevent for us
subplot(3,3,[2 6]) % divide the figure in 3x3 "spaces"
hold on
plot(refcalBP(sel),refC14(sel))
title('Calibration curve')

% plot our data
subplot(3,3,[1 4]) % note how we expand our subplot
hold on
plot(C14probs(sel),refC14(sel))
ylabel('C14 age')
xlabel('P')

% plot the data calibrated
subplot(3,3,[8 9])
plot(refcalBP(sel),C14probs(sel)) 
xlabel('calibrated C14 age')
ylabel('P')