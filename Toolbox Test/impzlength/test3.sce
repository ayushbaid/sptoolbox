// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 3
// 2 input arguments (b,a); empty values
// *****************************************************************************
b = [];
a = [1 -0.98];


try
    len = impzlength(b,a);
catch
    [error_message,error_number]=lasterror(%t);
    disp("actual error number - ");
    disp(error_number);
    
    disp(error_message);
end

// MATLAB gives len=490
// Result - FAIL;
