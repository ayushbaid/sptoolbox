// tests for function rms
// Author Ayush

funcprot(0);
exec('rms.sci',-1);

// *****************************************************************************
// Test 2
// Testing with 2 params (x,dim), with x as vector, 2D matrix and 3D matrix
// *****************************************************************************

// Row vector

t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t);
y = rms(x,1);

disp(size(y));

t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t);
y = rms(x,2);

disp(size(y));

// 2D Matrix
t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t)'*(1:4);

y = rms(x,2);

disp(size(y));

// 3D matrix
t = 0:0.001:1-0.001;
x = cos(2*%pi*100*t)'*(1:4);
xMat = zeros(size(x,1),size(x,2),2);
xMat(:,:,1) = x;
xMat(:,:,2) = x.^2;

disp(size(xMat));

y = rms(xMat,2);
disp(size(y));

y = rms(xMat,3);
disp(size(y));

// Result - PASS for vector and 2D matrix, error for 3D matrix
