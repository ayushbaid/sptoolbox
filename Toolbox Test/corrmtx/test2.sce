// tests for function corrmtx
// Author Ayush

funcprot(0)
exec('corrmtx.sci', -1);

// *****************************************************************************
// Test 1
// testing for number of input/output exceptions
// *****************************************************************************

// ** A) 0 input arguments
try
    corrmtx();
catch
    [err_msg,err_num] = lasterror(%t);
    
    // expected errors are one of 39, 77
    
    disp("error number - ");
    disp(err_num);
    
    
    disp("error message - ");
    disp(err_msg);
end

// Result - Exception not handled in a correct in a correct way


// ** B) 3 input arguments
try
    corrmtx(1,3,2);
catch

    // expected errors are one of 39, 77
    
    disp("error number - ");
    disp(err_num);
    
    
    disp("error message - ");
    disp(err_msg);
end


