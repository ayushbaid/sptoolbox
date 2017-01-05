// tests for function rms
// Author Ayush

funcprot(0);
exec('rms.sci',-1);

// *****************************************************************************
// Test 1
// Testing with single parameter x, as row vector, column vector and a matrix
// *****************************************************************************

// Row vector

t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t);
y = rms(x);

exp_y = 0.7071068;

assert_checkalmostequal(y,exp_y,1D-5);

// Column vector
y1 = rms(x');

[flag,msg] = assert_checkequal(y1,y);

if ~flag then
    disp("x as a row vs column vector gives different results");
end

// Matrix
t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t)'*(1:4);

y = rms(x);

y_exp = [0.7071, 1.4142, 2.1213, 2.8284];

assert_checkalmostequal(y,y_exp,1D-4);


// Result - PASS

    
