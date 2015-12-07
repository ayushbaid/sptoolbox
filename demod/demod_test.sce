// Date of creation: 6 Dec, 2015
clear;
clf;
clc;

exec('/home/ayush/dev/scilab_workspace/sptoolbox/demod/modulate.sci', -1)
exec('/home/ayush/dev/scilab_workspace/sptoolbox/demod/demod.sci', -1)

//fs = 8000;
//t = (0:1000-1)'/fs;
//s = 4*cos(2*%pi*500*t);
//x = modulate(s,3e3,fs, 'fm', 0.1);
//
//rx = x;
//y = demod(rx,3e3,fs, 'fm');

// RESULT; a difference in scaling factor

// AM
//fs = 8000;
//t = (0:1000-1)'/fs;
//s = 4*cos(2*%pi*500*t);
//x = modulate(s,3e3,fs, 'am');
//
//rx = x;
//y = demod(rx,3e3,fs, 'am');
// a difference in the + shift by one index

// PM
//fs = 8000;
//t = (0:1000-1)'/fs;
//s = 4*cos(2*%pi*500*t);
//x = modulate(s,3e3,fs, 'pm');
//
//rx = x;
//y = demod(rx,3e3,fs, 'pm');
// RESULT: perfect match

// PWM
//fs = 8000;
//t = (0:1000-1)'/fs;
//s = 0.25*cos(2*%pi*500*t)+0.5;
//x = modulate(s,2e3,fs, 'pwm');
//
//rx = x;
//y = demod(rx,2e3,fs, 'pwm');
// RESULT: perfect match

// PPM
//fs = 8000;
//t = (0:1000-1)'/fs;
//s = 0.25*cos(2*%pi*500*t)+0.5;
//x = modulate(s,2e3,fs, 'ppm');
//
//rx = x;
//y = demod(rx,2e3,fs, 'ppm');
// RESULT: incorrect modulation

// QAM
fs = 8000;
t = (0:1000-1)'/fs;
s1 = 4*cos(2*%pi*500*t);
s2 = 4*cos(2*%pi*300*t);
x = modulate(s1,3e3,fs, 'qam',s2);

rx = x;
[y1,y2] = demod(rx,3e3,fs, 'qam');

// RESULT - shift by one + values inconsistent

plot(y1(1:100));
plot(y2(1:100),'r');
