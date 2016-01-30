// Date of creation: 30 Jan, 2016
clear;
clc;


exec('rootmusic.sci',-1);



// ****************************************************************************
// Test 1
// ****************************************************************************
// pmusic with no extra params
loadmatfile('test1.mat');
[W1,P1] = rootmusic(R,2,"corr");

assert_checkalmostequal(W1,W);
assert_checkalmostequal(P1,P);
