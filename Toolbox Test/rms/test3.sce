// tests for function rms
// Author Ayush

funcprot(0);
exec('rms.sci',-1);

// *****************************************************************************
// Test 3
// Testing with incorrect number of input and output arguments
// *****************************************************************************

// No input params
try
    y = rms();
catch
    [error_message,error_number]=lasterror(%t);
    expected_error_num = 39;
    disp("actual error number - ");
    disp(error_number);
    
    disp("expected error number - ");
    disp(expected_error_num);
end

// Result - Expection thrown but incorrect error number


// 3 input arguments
a = [1 2];
b = 1;
c = 0.4;

try
    y = rms(a,b,c);
catch
    [error_message,error_number]=lasterror(%t);
    expected_error_num = 39;
    disp("actual error number - ");
    disp(error_number);
    
    disp("expected error number - ");
    disp(expected_error_num);
end

// Result - Expection thrown but incorrect error number



// 2 output arguments

exec('rms.sci',-1);
t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t);

try
    [y1,y2] = rms(x);  
catch
    disp("catching");
    [error_message,error_number] = lasterror(%t);
    expected_error_number = 78;
    
    disp("actual error number - ");
    disp(error_number);
    
    disp("expected error number - ");
    disp(expected_error_num);
end
[error_message,error_number]=lasterror(%t)

// Result - *Scilab crashes*
