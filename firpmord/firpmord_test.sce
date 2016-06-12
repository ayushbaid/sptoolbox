// Tests for firpmord

// Date: 16-07-12
// Author: Ayush

clear;
clc;

exec('firpmord.sci',-1);

loadmatfile('test_data.mat');

// *****************************************************************************
// Test 1: Low pass filter; with fs
// *****************************************************************************
[n1_,fo1_,ao1_,w1_] = firpmord(f1,a1,dev1,fs1);

assert_checkalmostequal(n1,n1_);
assert_checkalmostequal(fo1,fo1_);
assert_checkalmostequal(ao1,ao1_);
assert_checkalmostequal(w1,w1_);


// *****************************************************************************
// Test 2: Filter with multiple transitions
// *****************************************************************************
[n2_,fo2_,ao2_,w2_] = firpmord(f2,a2,dev2,fs2);

assert_checkalmostequal(n2,n2_);
assert_checkalmostequal(fo2,fo2_);
assert_checkalmostequal(ao2,ao2_);
assert_checkalmostequal(w2,w2_);


// *****************************************************************************
// Test 3: invalid values in f (>fs/2)
// *****************************************************************************
try
    [n3,fo3,ao3,w3] = firpmord(f1,a1,dev1,1e3);
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end


// *****************************************************************************
// Test 4: Invalid sizes of f and a
// *****************************************************************************
try
    [n3,fo3,ao3,w3] = firpmord([f1,0],a1,dev1,fs1);
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end

try
    [n3,fo3,ao3,w3] = firpmord([f1,a1,[dev1,0],fs1);
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end
