// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 4
// 2 input arguments (b,a); incorrect datatype for b
// *****************************************************************************
b = "randomstring";
a = [1 -0.9];

try
    len = impzlength(b,a);
catch
    [error_message,error_number]=lasterror(%t);
    disp("actual error number");
    disp(error_number);
end

// Result - FAIL
// error not handled
