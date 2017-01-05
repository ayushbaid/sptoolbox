// tests for function corrmtx
// Author Ayush

funcprot(0)
exec('corrmtx.sci', -1);

// *****************************************************************************
// Test 3
// testing for incorrect type/dimesnion for input arguments
// *****************************************************************************


// ** A) x is a scalar
try
    x = 1;
    m = 3;
    
    corrmtx(x,m);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp(error_num);
    disp(error_msg);
end

// Result - exception handled but error_number not correct


// ** B) length(x)<m check for some methods
try 
    x = [1,2,3,5,2,5,6,3,1,1,2];
    m = 15;
    
    corrmtx(x,m,"covariance");
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp(error_num);
    disp(error_msg);
end

// Result - FAIL; should throw error


// ** C) m is a vector
try
    x = [1,2,3,5,2,6,3,7,8];
    m = [1,5,2];
    
    corrmtx(x,m);
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp(error_num);
    disp(error_msg);
end

// Result - exception thrown but no error_number


// ** D) method name incorrect
try
    x = [1,2,3,5,2,6,3,7,8];
    m = 5;
    
    corrmtx(x,m,"invalidmethod");
catch
    [error_msg,error_num] = lasterror(%t);
    
    disp(error_num);
    disp(error_msg);
end
// Result - FAIL; exception not handled
