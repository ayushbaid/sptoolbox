// Date of creation: 16 Dec, 2015
clc;
clear;

// ****************************************************************************
// Test 3: pxx (single column) and f
// ****************************************************************************

exec('/home/ayush/dev/scilab_workspace/sptoolbox/bandpower/bandpower.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/bandpower/test3.mat');

p1 = bandpower(pxx, f, 'psd');

// result: perfect match


// ****************************************************************************
// Test 4: pxx (single column), f and freqrange
// ****************************************************************************

exec('/home/ayush/dev/scilab_workspace/sptoolbox/bandpower/bandpower.sci', -1);
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/bandpower/test4.mat');

pband = bandpower(pxx,f,[50 100],'psd'); // expected - 0.5820
ptot = bandpower(pxx,f,'psd'); // expected - 1.5051

per_power1 = 100*(pband/ptot);

// result - perfect match
