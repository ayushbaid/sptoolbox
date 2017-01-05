// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 6
// 3 input arguments; checking exception
// *****************************************************************************
a = [1 3];
b = [2 4 1];
c = [-1 2];

try
    len = impzlength(a,b,c);
catch
    [error_message,error_number]=lasterror(%t);
    disp("actual error number");
    disp(error_number);
end

// Result - FAIL
// error not handled
