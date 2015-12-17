// Date of creation: 10 Dec, 2015

clear;
clc;

exec('/home/ayush/dev/scilab_workspace/sptoolbox/obw/obw.sci', -1);

// ****************************************************************************
// Test 1: picked form matlab's website example involving pxx and f
// ****************************************************************************

// loadin both input and test results
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/obw/test1.mat');

[bw1, flo1, fhi1, pwr1] = obw(Pxx, f);


// ****************************************************************************
// Test 2: picked form matlab's website example involving pyy and f
// ****************************************************************************
exec('/home/ayush/dev/scilab_workspace/sptoolbox/obw/obw.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/obw/test2.mat');
[bw1, flo1, fhi1, pwr1] = obw(Pyy, f);

// ****************************************************************************
// Test 3: custom
// ****************************************************************************
exec('/home/ayush/dev/scilab_workspace/sptoolbox/obw/obw.sci', -1);
freqrange = [3500 19000];
[bw, flo, fhi, power] = obw(Pxx, f, freqrange, 50);

// expected results:
//      bw = 4.8313e+03
//      flo = 1.2473e+04
//      fhi = 1.7304e+04
//      pwr = 5.2466e-07
disp(bw);
disp(flo);
disp(fhi);
disp(power);


// TODO: test when f is not in an increasing order
