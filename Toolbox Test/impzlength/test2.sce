// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 2
// 2 input arguments (b,a); correct datatypes
// *****************************************************************************

b = 1;
a = [1 -0.9];
len = impzlength(b,a);

[flag,msg] = assert_checkequal(len,93);

if ~flag then
    disp(msg);
end

// Result - FAIL; expected - 93; got 48
