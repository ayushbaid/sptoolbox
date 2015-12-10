// Date of creation: 10 Dec, 2015


// ****************************************************************************
// Test 1: picked form matlab's website example involving pxx and f


// loadin both input and test results
loadmatfile('/home/ayush/dev/scilab_workspace/sptoolbox/obw/test1.mat');

exec('/home/ayush/dev/scilab_workspace/sptoolbox/obw/obw.sci', -1)

[obw1, flo1, fhi1, pwr1] = obw(Pxx, f);
