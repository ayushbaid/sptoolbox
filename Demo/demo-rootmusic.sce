// Date of creation: 30 Jan, 2016
clear;
clc;


exec('rootmusic.sci',-1);



// ****************************************************************************
// Test 1
// ****************************************************************************
// rootmusic with no extra params

// Matlab code
// Sinusoids of frequency 0.785 and 0.845

// n = (0:99)';
// frqs = [pi/4 pi/4+0.06];

// s = 2*exp(1j*frqs(1)*n)+1.5*exp(1j*frqs(2)*n)+ ...
//    0.5*randn(100,1)+1j*0.5*randn(100,1);

// [~,R] = corrmtx(s,12,'mod');
// [W,P] = rootmusic(R,2,'corr')

// Expected output:
// W = [0.7946; 0.8917]
// P = [4.153; 0.7797]
loadmatfile('test1.mat');
[W1,P1] = rootmusic(R,2,"corr");

disp("Frequencies = ");
disp(W1);

disp("Power = ");
disp(P1);
