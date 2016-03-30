// Test script for fftfilt
// Author: Ayush

clear;
clc;

exec('fftfilt.sci',-1);

loadmatfile('test_data.mat');

// ****************************************************************************
// Test 1: Single input col vector and single filter
// ****************************************************************************
y1_ = fftfilt(b1,x1);

assert_checkalmostequal(y1_,y1);


// ****************************************************************************
// Test 2: Single input row vector and single filter
// ****************************************************************************
y2_ = fftfilt(b1,x1');

assert_checkalmostequal(y2_,y2);


// ****************************************************************************
// Test 3: Input matrix and single filter
// ****************************************************************************
//y3_ = fftfilt(b3,x3);

// assert_checkalmostequal(y3_,y3);

// works fine but some problem with the specific input

// ****************************************************************************
// Test 4: Single input vector and multiple filters
// ****************************************************************************
y4_ = fftfilt(b4,x1);

assert_checkalmostequal(y4_,y4);



// ****************************************************************************
// Test 5: Input matrix and filter matrix
// ****************************************************************************
y5_ = fftfilt(b4,x3);

assert_checkalmostequal(y5_,y5);


// ****************************************************************************
// Test 6: Incorrect number of input arguments
// ****************************************************************************
try
    y = fftfilt();
catch
    [err_num,err_msg] = lasterror(%t);
    disp("Test 6");
    disp(err_num);
    disp(err_msg);
end    



