
funcprot(0);
exec('latcfilt.sci',-1);


//loadmatfile('test.mat');
//
//[f_,g_] = latcfilt([1/2 1/3;1 2],x);


// k-v, x-v working


loadmatfile('test2.mat');
[f1_,g1_] = latcfilt([1/2 1],[1/2 1/5 1],x);

assert_checkalmostequal(f1_,f1);
assert_checkalmostequal(g1_,g1);

// working! :)
