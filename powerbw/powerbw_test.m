% Test3

nSamp = 1024;
Fs = 1024e3;
SNR = 40;
rng default

t = (0:nSamp-1)'/Fs;

x = sin(2*pi*t*100.123e3);
x = x + randn(size(x))*std(x)/db2mag(SNR);

[Pxx,f] = periodogram(x,kaiser(nSamp,38),[],Fs);

[bw, flo, fhi, power] = powerbw(Pxx,f);

save('test3.mat','Pxx','f','bw','flo','fhi','power');

x2 = 2*sin(2*pi*t*257.321e3);
x2 = x2 + randn(size(x2))*std(x2)/db2mag(SNR);

[Pyy,f] = periodogram([x x2],kaiser(nSamp,38),[],Fs);

[bw, flo, fhi, power] = powerbw(Pyy,f);

save('test4.mat','Pyy','f','bw','flo','fhi','power');


d = fir1(88,[0.25 0.45]);
[bw, flo, fhi, power] = powerbw(d,[],[0.2 0.6]*pi,3);
save('test5.mat', 'd', 'bw', 'flo', 'fhi', 'power');
