// Date of creation: 13 Mar, 2016
// Author: Ayush

clear;
clc;

exec('latc2tf.sci',-1);


// Test file for latc2tf
loadmatfile('test_data.mat');


// ****************************************************************************
// Test 1: Normal FIR filter
// ****************************************************************************
[num1_,den1_] = latc2tf(k1);

assert_checkalmostequal(num1_,num1);
assert_checkalmostequal(den1_,den1);



// ****************************************************************************
// Test 2: Max FIR filter
// ****************************************************************************
[num2_,den2_] = latc2tf(k2,'max');

assert_checkalmostequal(num2_,num2);
assert_checkalmostequal(den2_,den2);


// ****************************************************************************
// Test 3: MIN FIR filter
// ****************************************************************************
[num3_,den3_] = latc2tf(k3,'min');

assert_checkalmostequal(num3_,num3);
assert_checkalmostequal(den3_,den3);


// ****************************************************************************
// Test 4: IIR filter
// ****************************************************************************
[num4_,den4_] = latc2tf(k4,v4);

assert_checkalmostequal(num4_,num4);
assert_checkalmostequal(den4_,den4);


// ****************************************************************************
// Test 5: IIR allpass filter
// ****************************************************************************
[num5_,den5_] = latc2tf(k5,'allpass');

assert_checkalmostequal(num5_,num5);
assert_checkalmostequal(den5_,den5);


// ****************************************************************************
// Test 6: IIR allpole filter
// ****************************************************************************
[num6_,den6_] = latc2tf(k6,'allpole');

assert_checkalmostequal(num6_,num6);
assert_checkalmostequal(den6_,den6);
