// Date of creation: 10 Jan, 2016
clear;
clc;

exec('peig.sci',-1);



// ****************************************************************************
// Test 1
// ****************************************************************************
// peig with data matrix
loadmatfile('test1.mat');
[S1,f1,v1,e1] = peig(X,3,"whole");

assert_checkalmostequal(S1,S);
assert_checkalmostequal(f1,f);

