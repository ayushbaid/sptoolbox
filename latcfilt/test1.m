% Test data generation for latcfilt

% *************************************************************************
% IIR all pole filter
% *************************************************************************

datapoints =(1:512)';
x = sin(datapoints);
[f,g] = latcfilt([1/2 1],1,x);

save('test1.mat','f','g','x');

[f1,g1] = latcfilt([1/2 1],[1/2 1/5 1],x);

save('test2.mat','f1','g1');
