// tests for function impzlength
// Author Ayush

funcprot(0)
exec('impzlength.sci', -1);

// *****************************************************************************
// Test 1
// No input arguments
// *****************************************************************************
try
    impzlength();
catch
    [error_message,error_number]=lasterror(%t)
    expected_error_number = 39;
    
    disp("expected error number  - ");
    disp(expected_error_number);
    disp("actual error number - ");
    disp(error_number);
end

// Result - error thrown but incorrect error number




 











