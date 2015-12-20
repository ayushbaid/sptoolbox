// Date of creation: 20 Dec, 2015
clear;
clc;

exec('/home/ayush/dev/scilab_workspace/sptoolbox/pmusic/pmusic.sci',-1);
exec('/home/ayush/dev/scilab_workspace/sptoolbox/pmusic/subspaceMethodsInputParser.sci',-1);
exec('/home/ayush/dev/scilab_workspace/sptoolbox/pmusic/musicBase.sci',-1);


n = 0:199;
x = cos(0.257*%pi*n) + sin(0.2*%pi*n) + 0.01*rand(1,length(n),"normal");
[S,w] = pmusic(x,4);      // Set p to 4 because there are two real inputs
