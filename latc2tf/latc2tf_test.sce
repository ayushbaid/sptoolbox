// Date of creation: 13 Mar, 2016
// Author: Ayush

// Test file for latc2tf
loadmatfile('test_data.mat');


// ****************************************************************************
// Test 1: Normal FIR filter
// ****************************************************************************
[num1_,den1_] = latc2tf(k1);
