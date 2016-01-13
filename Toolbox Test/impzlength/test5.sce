// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 5
// 1 input arguments (sos); correct arguments
// *****************************************************************************

sos = [1, 1.8116, 1, 1, -1.0095, 0.3954; 1, 1.1484, 1, 1, -0.5581, 0.7823];
len = impzlength(sos);

exp_len = 80;
[flag,msg] = assert_checkequal(len, exp_len);

if ~flag then
    disp(msg);
end

// Result - FAIL
