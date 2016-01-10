// Date of creation: 20 Dec, 2015
clear;
clc;

stacksize('max')

exec('pmusic.sci',-1);



// ****************************************************************************
// Test 1
// ****************************************************************************
// pmusic with no extra params
loadmatfile('test1.mat');
[s1,w1,v1,e1] = pmusic(x,4);

assert_checkalmostequal(s1,s);
assert_checkalmostequal(w1,w);


// ****************************************************************************
// Test 2
// ****************************************************************************
// specifying fs and subspace dimension
// [] corresponds to ?
// fs=8k
// nwin = 7
loadmatfile('test2.mat');
[P2_1,f2_1,v2_1,e2_1] = pmusic(x, [%inf,1.1], [], 8000, 7);

// assert_checkalmostequal(P2_1,P2);
assert_checkalmostequal(f2_1,f2);

// Result - difference in SVD values


// ****************************************************************************
// Test 3
// ****************************************************************************
// correlation matrix as an input
disp("test 3");
loadmatfile('test3.mat');
[P3_1,f3_1] = pmusic(R,4,'corr');

//assert_checkalmostequal(P3_1,P3);
assert_checkalmostequal(f3_1,f3);

// result - difference in spec used for eigenvalues

// ****************************************************************************
// Test 4
// ****************************************************************************
// entering the signal data matrix
loadmatfile('test4.mat');
[P4_1,f4_1] = pmusic(Xm,2);

assert_checkalmostequal(P4_1,P4);
assert_checkalmostequal(f4_1,f4);

// ****************************************************************************
// Test 5
// ****************************************************************************
// using windowing to create effect of a single data matrix
loadmatfile('test5.mat');
[P5_1,f5_1] = pmusic(x,2,512,[],7,0);

assert_checkalmostequal(P5_1,P5);
assert_checkalmostequal(f5_1,f5);

