// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 7
// incorrect output arguments
// *****************************************************************************
b = [1];
a = [1 -0.9];



try
    impzlength(b,a);
    [l1, l2] = impzlength(b,a); 
catch
    [error_message,error_number]=lasterror(%t);
    disp("actual error number");
    disp(error_number);
end

// Result - FAIL
// 2nd command gives exception
