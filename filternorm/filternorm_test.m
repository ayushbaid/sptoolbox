% Create test data for filternorm matlab

% -----------------------------------------------------------------------------
% Test 1, 2, 3, 4, 5
% FIR filter
% -----------------------------------------------------------------------------
a1 = 1;
b1 = [1, 0.5, 1];
L1 = filternorm(b1, a1);
L2 = filternorm(b1, a1, 2);
L3 = filternorm(b1, a1, Inf);
L4 = filternorm(b1, a1, 2, 10e-5);
L5 = filternorm(b1, a1, Inf, 10e-5);

% -----------------------------------------------------------------------------
% Test 6, 7, 8, 9, 10
% IIR filter
% -----------------------------------------------------------------------------
b6 = [-3, 2];
a6 = [1, -0.5];
L6 = filternorm(b6, a6);
L7 = filternorm(b6, a6, 2);
L8 = filternorm(b6, a6, Inf);
L9 = filternorm(b6, a6, 2, 10e-7);
L10 = filternorm(b6, a6, Inf, 10e-7);



save('test_data.mat');
