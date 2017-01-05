// Test for filternorm

exec('filternorm.sci', -1);
loadmatfile('test_data.mat');

// ****************************************************************************
// Test 1, 2, 3, 4, 5
// FIR filter
// ***************************************************************************

L1_ = filternorm(b1, a1);
L2_ = filternorm(b1, a1, 2);
L3_ = filternorm(b1, a1, %inf);
L4_ = filternorm(b1, a1, 2, 10e-5);
L5_ = filternorm(b1, a1, %inf, 10e-5);

assert_checkalmostequal(L1_, L1);
assert_checkalmostequal(L2_, L2);
assert_checkalmostequal(L3_, L3);
assert_checkalmostequal(L4_, L4);
assert_checkalmostequal(L5_, L5);


// ****************************************************************************
// Test 6, 7, 8, 9, 10
// IIR filter
// ***************************************************************************

L6_ = filternorm(b6, a6);
L7_ = filternorm(b6, a6, 2);
L8_ = filternorm(b6, a6, %inf);
L9_ = filternorm(b6, a6, 2, 10e-7);
L10_ = filternorm(b6, a6, %inf, 10e-7);

assert_checkalmostequal(L6_, L6);
assert_checkalmostequal(L7_, L7);
assert_checkalmostequal(L8_, L8);
assert_checkalmostequal(L9_, L9);
assert_checkalmostequal(L10_, L10);


// ****************************************************************************
// Test 11
// Incorrect number of input arguments
// ***************************************************************************

try
    L = filternorm(b1);
catch
    [err_num, err_msg] = lasterror(%t);

    disp('Test 11');
    disp(err_num);
    disp(err_msg);
end


// ****************************************************************************
// Test 12
// Incorrect pnorm
// ***************************************************************************

try
    L = filternorm(b1, a1, 3);
catch
    [err_num, err_msg] = lasterror(%t);

    disp('Test 12');
    disp(err_num);
    disp(err_msg);
end
