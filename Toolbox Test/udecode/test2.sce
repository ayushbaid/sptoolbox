// tests for function udecode
// Author Ayush

funcprot(0)
exec('udecode.sci', -1);

// *****************************************************************************
// Test 2
// testing exception handling for incorrect number of arguments
// *****************************************************************************


// ** A) No input arguments
try
    udecode();
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
    udecode([1,2,3],5,1,'saturate',1);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    
    disp("error message - ");
    disp(error_msg);
    
end

// Result: PASS



// ** C) 2 output arguments
try
    [out1,out2] = udecode([1,2,3],5,1);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    
    disp("error message - ");
    disp(error_msg);
    
end

// Result: FAIL; cannot handle
