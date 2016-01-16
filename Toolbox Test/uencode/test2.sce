// tests for function uencode
// Author Ayush

funcprot(0)
exec('uencode.sci', -1);

// *****************************************************************************
// Test 2
// testing exception handling for incorrect number of arguments
// *****************************************************************************


// ** A) No input arguments
try
    uencode();
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    
    disp("error message - ");
    disp(error_msg);
    
end

// Result: exception handled but error_number incorrect



// ** B) 5 input arguments
try
    uencode([1,2,3],5,1,'signed',1);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    
    disp("error message - ");
    disp(error_msg);
    
end

// Result: exception handled but error_number incorrect



// ** C) 2 output arguments
[out1,out2] = uencode([1,2,3],5,1);
try
    [out1,out2] = uencode([1,2,3],5,1);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    
    disp("error message - ");
    disp(error_msg);
    
end

// Result: FAIL; cannot handle
