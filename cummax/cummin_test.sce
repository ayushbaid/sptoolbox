// Date of creation: 29 Feb, 2016

clear;
clc;

exec('cummax.sci',-1);

loadmatfile('test.mat');

// *************************************************************************
// Test 1
// *************************************************************************
// cumulative maximum for real values along a row vector

M1_ = cummax(v1);
assert_checkequal(M1_,M1);


// *************************************************************************
// Test 2
// *************************************************************************
// cumulative maximum for real values along a column vector and reverse

M2_ = cummax(v2,'reverse');
assert_checkequal(M2_,M2);


// *************************************************************************
// Test 3
// *************************************************************************
// Along the second dimension of the 3-dimensional vector

M3_ = cummax(v3);
assert_checkequal(M3_,M3);


// *************************************************************************
// Test 4, 5
// *************************************************************************
// Complex input

M4_ = cummax(v4);
assert_checkequal(M4_,M4);

M5_ = cummax(v5);
assert_checkequal(M5_,M5);

// TODO: inconsistent results for phase ordering

// *************************************************************************
// Test 6
// *************************************************************************
// No input

try
    M = cummax();
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end


// *************************************************************************
// Test 7
// *************************************************************************
// String for argument 1

try
    M = cummax('invalid');
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end


// *************************************************************************
// Test 8
// *************************************************************************
// String for argument 2 (dimension)

try
    M = cummax(v1,'invalid');
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end

// *************************************************************************
// Test 9
// *************************************************************************
// Invalid direction

try
    M = cummax(v3,2,'invalid');
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end


// *************************************************************************
// Test 10
// *************************************************************************
// 2 output arguments

//try
//    [M,N] = cummax(v3,2,'reverse');
//catch
//    [err_num,err_msg] = lasterror(%t);
//    
//    disp(err_num);
//    disp(err_msg);
//end

// Result - scilab crashes
