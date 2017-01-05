// tests for function udecode
// Author Ayush

funcprot(0)
exec('udecode.sci', -1);

// *****************************************************************************
// Test 1
// testing for correctness of output
// *****************************************************************************

// ** A) using 3 arguments
u = int8([-1 1 2 -5]);
y = udecode(u,3);

y_expected = [-0.25,0.25,0.5,-1];
assert_checkalmostequal(y,y_expected);

// Result - PASS


// ** B) using the peak magnitude
y = udecode(u,3,6)

y_expected = [-1.5,1.5,3.0,-6.0];
assert_checkalmostequal(y,y_expected);

// Result - PASS


// **C) using the wrap flag
y = udecode(u,3,6,'wrap');

y_expected = [-1.5,1.5,3.0,4.5];
assert_checkalmostequal(y,y_expected);

// Result - PASS
