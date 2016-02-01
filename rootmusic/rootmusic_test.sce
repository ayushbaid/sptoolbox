// Date of creation: 30 Jan, 2016
clear;
clc;


exec('rootmusic.sci',-1);



// ****************************************************************************
// Test 1
// ****************************************************************************
// 2 complex sinusoids
loadmatfile('test1.mat');
[W1_,P1_] = rootmusic(s1,2);

assert_checkalmostequal(W1_,W1);
assert_checkalmostequal(P1_,POW1);


// ****************************************************************************
// Test 2
// ****************************************************************************
// real sinusoid
loadmatfile('test2.mat');
[W2_,P2_] = rootmusic(s2,2);

assert_checkalmostequal(W2_,W2);
assert_checkalmostequal(P2_,POW2);

// ****************************************************************************
// Test 3
// ****************************************************************************
// p>required

loadmatfile('test3.mat');
[W3_,P3_] = rootmusic(s1,3);

assert_checkalmostequal(W3_,W3);
assert_checkalmostequal(P3_,POW3);


// ****************************************************************************
// Test 4
// ****************************************************************************
// p(2) (threshold) also specified which leaves out one sinusoid

loadmatfile('test4.mat');
[W4_,P4_] = rootmusic(s4,[2,2]);

assert_checkalmostequal(W4_,W4);
assert_checkalmostequal(P4_,POW4);


// ****************************************************************************
// Test 5
// ****************************************************************************
// Specifying fs

loadmatfile('test5.mat');
[F5_,P5_] = rootmusic(s1,2,4e3);

assert_checkalmostequal(F5_,F5);
assert_checkalmostequal(P5_,POW5);


// ****************************************************************************
// Test 6
// ****************************************************************************
// odd p(1) for real x; exception expected

try
    rootmusic(s2,3);
catch
    [err_num,err_msg] = lasterror(%t);
    
    disp(err_num);
    disp(err_msg);
end


