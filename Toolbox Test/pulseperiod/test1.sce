// tests for function pulseperiod
// Author Ayush

funcprot(0);
exec('pulseperiod.sci',-1);

// *****************************************************************************
// Test 1
// Testing with single parameter x (correct type)
// *****************************************************************************
loadmatfile('test1.mat');
p = pulseperiod(x);

exp_p = 5.003e-06;

assert_checkequal(p,exp_p);

// Result: FAIL
// inconsistent element-wise multiplication at line 297 of midcross.
