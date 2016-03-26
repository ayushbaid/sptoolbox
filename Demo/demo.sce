// Date of creation: 30 Jan, 2016
loadmatfile("demo.mat");

exec("statelevels.sci",-1);
exec("risetime.sci",-1);
exec("midcross.sci",-1);
exec("falltime.sci",-1);
exec("slewrate.sci",-1);

figure(1);
plot(time1, clock1);
xlabel('Time (secs)'), ylabel('Voltage');

[levels,histogram] = statelevels(clock1);

samples = 1:length(time1);
dummy = ones(size(clock1,1),size(clock1,2));
level1 = dummy.*levels(1);
level2 = dummy.*levels(2);

figure(2);
plot(samples,clock1,'b-',samples,level1,'r-.',samples,level2,'r-.');
xlabel('Samples'), ylabel('Level (volts)');
title('State Levels');

//risetime(clock1,time1);


// falltime(clock1,time1,'PercentReferenceLevels',[20 80],'StateLevels',[0 5])


// SLEW RATE
sr = slewrate(clock1(1:100), Fs);

disp("Slew rate:");
disp(sr);
