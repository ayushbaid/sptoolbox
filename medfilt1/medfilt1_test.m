% Data generation for test on medfilt1

% *************************************************************************
% Test 1
% Median filtering of a sine wave, includenan and zeropad
% *************************************************************************
fs = 100;
t = 0:1/fs:1;
x1 = sin(2*pi*t*3)+0.25*sin(2*pi*t*40);
y1 = medfilt1(x1,10);

% *************************************************************************
% Test 2
% Median filtering of a sine wave, includenan and truncate
% *************************************************************************
y2 = medfilt1(x1,10,'truncate');


% *************************************************************************
% Test 3
% Median filtering of a sine wave with some random NaNs, includenan and zeropad
% *************************************************************************
x3 = x1;
nan_idx = unidrnd(size(x1,1));
num_nans = uint8(size(x1,1)*0.1);
x3(nan_idx(1:num_nans)) = NaN;
y3 = medfilt1(x3,9,'includenan');


% *************************************************************************
% Test 4
% Median filtering of a sine wave with some random NaNs, omitnan and truncate
% *************************************************************************
y4 = medfilt1(x3,9,'omitnan','truncate');


% *************************************************************************
% Test 5
% Random 3d array
% *************************************************************************
x5 = rand(10,10,4);
y5 = medfilt1(x5, 3, 2, 2);


save('test.mat','x1','y1','y2','x3','y3','y4','x5','y5');
