// Tests for impzlength
exec('impzlength.sci',-1);

loadmatfile('impzlength_test.mat');

// ****************************************************************************
// Test 1
// Stable functions 
// ****************************************************************************
len1_ = impzlength(b1,a1);
assert_checkalmostequal(len1_,len1);

// ****************************************************************************
// Test 2
// Unstable functions 
// ****************************************************************************
len2_ = impzlength(b2,a2);
assert_checkalmostequal(len2_,len2);

// ****************************************************************************
// Test 3
// Stable functions with tolerance
// ****************************************************************************
len3_ = impzlength(b3,a3,tol3);
assert_checkalmostequal(len3_,len3);

// ****************************************************************************
// Test 4
// Unstable functions with tolerance
// ****************************************************************************
len4_ = impzlength(b4,a4,tol4);
assert_checkalmostequal(len4_,len4);

// ****************************************************************************
// Test 5
// Periodic functions 
// ****************************************************************************
len5_ = impzlength(b5,a5);
assert_checkalmostequal(len5_,len5);

// ****************************************************************************
// Test 6
// Periodic functions with tolerance
// ****************************************************************************
len6_ = impzlength(b6,a6);
assert_checkalmostequal(len6_,len6);
