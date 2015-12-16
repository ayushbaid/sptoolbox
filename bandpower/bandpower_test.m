% *************************************************************************
% Test 1
% *************************************************************************

t = 0:0.001:1-0.001;
x = cos(2*pi*100*t)+randn(size(t));

p = bandpower(x);

% save('test1.mat', 'x', 'p');

% *************************************************************************
% Test 2
% *************************************************************************

rng('default')

t = 0:0.001:1-0.001;
x = cos(2*pi*100*t)+randn(size(t));
fs = 1000;
frange1 = [50 150];
frange2 = [0 500];

pband = bandpower(x,fs,frange1);
ptot = bandpower(x,fs,frange2);
per_power = 100*(pband/ptot);

% save('test2.mat', 'x', 'fs', 'frange1', 'frange2', 'per_power');


% *************************************************************************
% Test 3
% *************************************************************************

t = 0:0.001:1-0.001;
Fs = 1000;
x = cos(2*pi*100*t)+randn(size(t));

[pxx,f] = periodogram(x,rectwin(length(x)),length(x),Fs);
p = bandpower(pxx,f,'psd');

% save('test3.mat', 'pxx', 'f', 'p');


% *************************************************************************
% Test 4
% *************************************************************************

Fs = 1000;
t = 0:1/Fs:1-0.001;
x = cos(2*pi*100*t)+randn(size(t));

[pxx,f] = periodogram(x,rectwin(length(x)),length(x),Fs);
pband = bandpower(pxx,f,[50 100],'psd');
ptot = bandpower(pxx,f,'psd');
per_power = 100*(pband/ptot);

% save('test4.mat', 'pxx', 'f', 'per_power');


