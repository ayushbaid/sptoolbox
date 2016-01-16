// tests for function uencode
// Author Ayush

funcprot(0)
exec('uencode.sci', -1);

// *****************************************************************************
// Test 1
// testing for correctness of output
// *****************************************************************************

// ** A) using 3 arguments
u = -2:0.5:2;
y = uencode(u,5,1);

y_expected = [0,0,0,8,16,24,31,31,31];
assert_checkalmostequal(double(y),y_expected);

// Result - PASS


// ** B) using the sign flag
u = -2:0.5:2;
y = uencode(u,5,2,'signed');

y_expected = [-16,-12,-8,-4,0,4,8,12,15];
assert_checkalmostequal(double(y),y_expected);

// Result - PASS


// **C) u is a 2D matrix
u = [0.2,0.3,0.4;-0.3;0.8;1.5];
n = 3;
y = uencode(u,n);

y_expected = [4,5,5;2,7,7];
assert_checkalmostequal(double(y),y_expected);


