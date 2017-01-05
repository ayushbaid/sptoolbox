// tests for function rms
// Author Ayush

funcprot(0);
exec('rms.sci',-1);

// *****************************************************************************
// Test 4
// Testing with incorrect input arguments datatype
// *****************************************************************************

x = 'teststring";

try
    rms(x);
catch
    [err_msg,err_num] = lasterror(%t);
    disp("error number");
    disp(err_num);
end

// Result - Exception not handled correctly

x = 'teststring";

try
    rms(x,"asa");
catch
    [err_msg,err_num] = lasterror(%t);
    disp("error number");
    disp(err_num);
    
    disp(err_msg);
end

// Result - Exception not handled correctly
