// Date of creation: 9 Dec, 2015
function [y, f] = computeDFT(x, freqArg, varargin)
    // TODO: choose between Goertzel and CZT
    [lhs rhs] = argn(0);
    if rhs>3 then
        error(msprintf(gettext("%s: Wrong number of input arguments; %d to %d expected"), "atomsInsalled", 2, 3));
    end
    if rhs==3 then
        fs = varargin(1);
        if type(fs)==8 then
            fs = double(fs);
        elseif type(fs)~=1 then
            error(msprintf(gettext("%s: Wrong type for argument #%d: A positive scalar expected"), "atomsInsalled", 3));
        end    
        if ~(isreal(fs) & fs>0) then
            error(msprintf(gettext("%s: Wrong type for argument #%d: A positive scalar expected"), "atomsInsalled", 3));
        end
    else
        fs = 2*%pi;
    end

    if type(freqArg)==8 then
        freqArg = double(freqArg);
    end

endfunction


function [y, f] = computeFFT(x, nfft, fs)

    // perform wrapping/padding on each segment (i.e. columns) of x to make it of size nfft
    numOfRows = size(x,1);
    numOfColumns = size(x,2);
    xMod = zeros(nfft, numOfColumns);

    if numOfRows<nfft then
        // perform zero pad
        xMod(1:numOfRows,:) = x;
    else
        temp = int16(nfft/numOfRows);
        for i=1:temp-1
            xMod = xMod + x(1+(i-1)*nfft:i*nfft,:);
        end
        xMod = xMod + x(1+(temp-1)*nfft:$,:);
    end
    
    y = fft(x, nfft);
    
    // calculating the fft evaluation frequencies in terms of fs
    // TODO: fancy stuff
    fmax = 2*%pi;
    f = linspace(0, fmax, nfft)'*fs;
    
endfunction

function [y, f] = computeGoertzel(x, f)
    y = goertzel(x,f,2);
endfunction
