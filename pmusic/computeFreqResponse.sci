// Date of creation: 7 Jan, 2016
function [h,w] = computeFreqResponse(b,a,n,fs)
    // returns the frequency response (h) and the corresponding frequency 
    // values (w) for a digital filter with numerator b and denominator a. The 
    // evaluation of the frequency response is done at n points between 0 and fs.
    //
    // Similar to MATLAB's freqz(b,a,n,'whole',fs)
    isFsSpecified = ~isempty(fs);
    if ~isFsSpecified then
        fs=1;
    end
    w = linspace(0,2*%pi*fs,n+1)';
    w($) = [];
    w(1) = 0;   // forcing the first frequency to be 0

    maxPower = max(length(b),length(a));

    // creating a matrix which contains all the required powers of w
    wMatrix = zeros(n,maxPower);

    for i=1:maxPower
        wMatrix(:,i) = exp(w*%i*(-i+1));
    end

    // forcing b and a to be column vectors
    b = b(:);
    a = a(:);
    
    // zero padding numerator and denominator coefficients
    zeroPadLength = maxPower - length(b);
    zeroPad = zeros(zeroPadLength,1);
    b = [b; zeroPad];
    zeroPadLength = maxPower - length(a);
    zeroPad = zeros(zeroPadLength,1);
    a = [a; zeroPad];

    numerator = wMatrix*b;
    denominator = wMatrix*a;

    h = (numerator./denominator);
    
    if isFsSpecified then
        w = w/(2*%pi);
    end
    
endfunction
