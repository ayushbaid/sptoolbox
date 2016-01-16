// tests for function uencode
// Author Ayush

funcprot(0)
exec('uencode.sci', -1);

// *****************************************************************************
// Test 3
// testing exception handling for incorrect type/dimension of input arguments
// *****************************************************************************


// ** A) u is not a numeric matrix
try
    u = "string";
    n = 3;
    uencode(u,n);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    disp("error message - ");
    disp(error_msg);
end

// Result: exception not handled correctly


// ** B) n is a string
try
    u = -2:0.5:2;
    uencode(u,"string",1);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    disp("error message - ");
    disp(error_msg);
end

// Result: exception not handled correctly



// ** C) v is a string
try
    u = -2:0.5:2;
    uencode(u,5,"string");
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    disp("error message - ");
    disp(error_msg);
end

// Result: exception not handled correctly



// ** D) sign flag has an incorrect value
try
    u = -2:0.5:2;
    uencode(u,5,1,"string");
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp("error number - ");
    disp(error_num);
    disp("error message - ");
    disp(error_msg);
end

// Result: the exception is handled correctly but the error_number is incorrect
