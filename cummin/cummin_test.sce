// Date of creation: 29 Feb, 2016

clear;
clc;

exec('cummin.sci',-1);

loadmatfile('test.mat');

// *************************************************************************
// Test 1
// *************************************************************************
// cumulative minumum for real values along a row vector

M1_ = cummin(v1);
assert_checkequal(M1_,M1);


// *************************************************************************
// Test 2
// *************************************************************************
// cumulative minumum for real values along a column vector and reverse

M2_ = cummin(v2,'reverse');
assert_checkequal(M2_,M2);


// *************************************************************************
// Test 3
// *************************************************************************
// Along the second dimension of the 3-dimensional vector

M3_ = cummin(v3);
assert_checkequal(M3_,M3);


// *************************************************************************
// Test 4, 5
// *************************************************************************
// Complex input

M4_ = cummin(v4);
assert_checkequal(M4_,M4);

M5_ = cummin(v5);
assert_checkequal(M5_,M5);

// TODO: inconsistent results for phase ordering

// *************************************************************************
// Test 6
// *************************************************************************
// No input

try
    M = cummin();
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
    M = cummin('invalid');
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
    M = cummin(v1,'invalid');
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
    M = cummin(v3,2,'invalid');
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
//    [M,N] = cummin(v3,2,'reverse');
//catch
//    [err_num,err_msg] = lasterror(%t);
//    
//    disp(err_num);
//    disp(err_msg);
//end

// Result - scilab crashes
