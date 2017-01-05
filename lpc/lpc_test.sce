funcprot(0);
exec('lpc.sci', -1);

loadmatfile('test.mat');

// ****************************************************************************
// Test 1: single column vector
// ****************************************************************************
[a1_,g1_] = lpc(x1,p1);
assert_checkalmostequal(a1_,a1);
assert_checkalmostequal(g1_,g1);


// *****************************************************************************
// Test 2: single row vector
// *****************************************************************************
[a2_,g2_] = lpc(x2,p2);
assert_checkalmostequal(a2_,a2);
assert_checkalmostequal(g2_,g2);


// *****************************************************************************
// Test 3: 2 signals as column vectors
// *****************************************************************************
[a3_,g3_] = lpc(x3,p3);
assert_checkalmostequal(a3_,a3);
assert_checkalmostequal(g3_,g3);


// *****************************************************************************
// Test 4: complex input signal
// *****************************************************************************
[a4_,g4_] = lpc(x4,p4);
assert_checkalmostequal(a4_,a4);
assert_checkalmostequal(g4_,g4);

// *****************************************************************************
// Test 5: Incorrect number of input arguments
// *****************************************************************************
try
    lpc(x1,p1,1);
catch
    [error_num, error_msg] = lasterror(%t);
    
    disp(error_num);
    disp(error_msg);
    
end
