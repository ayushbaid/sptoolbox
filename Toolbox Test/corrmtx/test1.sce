// tests for function corrmtx
// Author Ayush

funcprot(0)
exec('corrmtx.sci', -1);

// *****************************************************************************
// Test 1
// testing for correctness of output
// *****************************************************************************

// loading the expected results
loadmatfile('test1.mat');

// default method
n = 0:99;
s = exp(%i*%pi/2*n)+2*exp(%i*%pi/4*n)+exp(%i*%pi/3*n);
m = 12;

// ** A) default method **
[X,R] = corrmtx(s,m);

assert_checkalmostequal(X,X1);
assert_checkalmostequal(R,R1);

// Result - FAIL; differing by a multiplicative factor



// ** B) autocorrelation method **
[X,R] = corrmtx(s,m,"autocorrelation");

assert_checkalmostequal(X,X3);
assert_checkalmostequal(R,R3);

// Result - FAIL; differing by a multiplicative factor



// ** C) prewindowed method **
[X,R] = corrmtx(s,m,"prewindowed");

assert_checkalmostequal(X,X4);
assert_checkalmostequal(R,R4);


// ** D) postwindowed method **
[X,R] = corrmtx(s,m,"postwindowed");

assert_checkalmostequal(X,X5);
assert_checkalmostequal(R,R5);

// Result - FAIL; differing by a multiplicative factor



// ** E) covariance method **
[X,R] = corrmtx(s,m,"covariance");

assert_checkalmostequal(X,X6);
assert_checkalmostequal(R,R6);

// Result - FAIL; different values




// ** F) modified method **
[X,R] = corrmtx(s,m,"modified");

assert_checkalmostequal(X,X2);
assert_checkalmostequal(R,R2);

// Result - FAIL; different values

