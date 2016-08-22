funcprot(0);
exec('medfilt1.sci', -1);

loadmatfile('test.mat');

y1_ = medfilt1(x1,10);
assert_checkalmostequal(y1_,y1);

y2_ = medfilt1(x2, 3, 2, 2);
assert_checkalmostequal(y2_,y2);
