// Date of creation: 15 Dec, 2015

clear;
clc;



// ****************************************************************************
// Test 3: pxx (single column) and f
// ****************************************************************************

exec('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/powerbw.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/test3.mat');

[bw1, flo1, fhi1, pwr1] = powerbw(Pxx, f);

keypress = input("press any key");

// result: perfect match

// ****************************************************************************
// Test 4: pyy (double column) and f
// ****************************************************************************
exec('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/powerbw.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/test4.mat');

[bw1, flo1, fhi1, pwr1] = powerbw(Pyy, f);

keypress = input("press any key");

// result - all perfect expect a small difference in power (magnitude of E-14)


// ****************************************************************************
// Test 4: signal, freqrange and r
// ****************************************************************************
exec('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/powerbw.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/powerbw/test5.mat');

[bw1, flo1, fhi1, pwr1] = powerbw(d,[],[0.2 0.6]*%pi,3);

keypress = input("press any key");

// result - cannot execute test without periodogram


// TODO: implement remaining tests
