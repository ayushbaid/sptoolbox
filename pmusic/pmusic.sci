// Date of creation: 18 Dec, 2015
function [S,f,v,e] = pmusic(varargin)
    // Psuedospectrum using MUSIC algorithm
    //
    // Calling Sequence
    // [S,w] = pmusic(x,p)
    // [S,w] = pmusic(x,p,w)
    // [S,w] = pmusic(x,p,nfft)
    // [S,w] = pmusic(x,p,nfft,fs)
    // [S,w] = pmusic(x,p,f,fs)
    // [S,f] = pmusic(...,'corr')
    // [S,f] = pmusic(x,p,nfft,fs,nwin,noverlap)
    // [...] = pmusic(...,freqrange)
    // [...,v,e] = pmusic(...)
    // pmusic(...)
    //
    // Parameters:
    // x - int|double - vector|matrix
    //      Input signal. In case of a matrix, each row of x represents a 
    //      seperate observation of the signal. If 'corr' flag is specified, 
    //      then x is the correlation matrix.
    //      If w is not specified in the input, it is determined by the 
    //      algorithm. If x is real valued, then range of w is [0, pi]. 
    //      Otherwise, the range of w is [0, 2pi)
    // p - int|double - scalar|vector
    //      p(1) is the dimension of the signal subspace
    //      p(2), if specified, represents a threshold that is multiplied by 
    //      the smallest estimated eigenvalue of the signal's correlation matrix.
    // w - int|double - vector
    //      w is the vector of normalized frequencies over which the 
    //      pseuspectrogram is to be computed.
    // nfft - int - scalar (Default = 256)
    //      Length of the fft used to compute pseudospectrum. The length of S
    //      (and hence w/f) depends on the type of values in x and nfft.
    //      If x is real, length of s is (nfft/2 + 1) {Range of w = [0, pi]} if 
    //      nfft is even and (nfft+1)/2 {Range of w = [0, pi)} otherwise.
    //      If x is complex, length of s is nfft.
    // fs - int|double - scalar (Default = 1)
    //      Sampling rate. Used to convert the normalized frequencies (w) to 
    //      actual values (f) and vice-versa.
    // nwin - int|double - scalar (int only)|vector (Default = 2*p(1))
    //      If nwin is scalar, it is the length of the rectangular window.
    //      Otherwise, the vector input is considered as the window coefficients.
    //      Not used if 'corr' flag present.
    //      If x is a vector, windowing not done in nwin in scalar. If x is a 
    //      matrix, 
    // noverlap - int - scalar (Default = nwin-1)
    //      number of points by which successive windows overlap. noverlap not 
    //      used if x is a matrix
    // freqrange - string
    //      The range of frequencies over which the pseudospetrogram is 
    //      computed. Three possible values - 'onesided', 'twosided', 'centered'
    // 'corr' flag
    //      Presence indicates that the primary input x is actually a 
    //      correlation matrix
    //
    // Examples:
    // TODO:
    //
    // See also
    // pburg | peig | periodogram | pmtm | prony | pwelch | rooteig | rootmusic
    //
    // Authors
    // Ayush Baid
    //
    // References
    // [1] Petre Stoica and Randolph Moses, Introduction To Spectral
    //     Analysis, Prentice-Hall, 1997, pg. 15
    // [2] S. J. Orfanidis, Optimum Signal Processing. An Introduction. 
    //     2nd Ed., Macmillan, 1988.
    


    disp("start");
    [data, msg] = subspaceMethodsInputParser(varargin);
    disp("input parsed");

    if length(msg)==0 then
        // no error occured
    else
        error(msg);
    end

    [musicData,msg] = musicBase(data);

    if length(msg)~=0 then
        error(msg);
    end


    // computing the pseudospectrum
    [S,f] = pseudospectrum(musicData.noiseEigenvects, ...
    musicData.eigenvals,data.nfft, data.fs, data.freqrange);
        
    v = musicData.noiseEigenvects;
    e = musicData.eigenvals;

endfunction

function [pspec,w] = pseudospectrum(noiseEigenvects, eigenvals, nfft, fs, ...
    freqrange)
    // TODO: EVFlag

    weights = ones(1,size(noiseEigenvects,2));

    denominator = 0;

    for i=1:size(noiseEigenvects,2);
        [h,w] = computeFreqResponse(noise_eigenvects(:,i),1,nfft,fs);
        denominator = denominator + (abs(h).^2)./weights(i);
    end
    
    // computing pseudospectrum pspec
    pspec = 1./denominator;
    
    // correcting the range of pspec according to the user specification
    if strcmpi(freqrange, 'onesided') then
        if modulo(nfft,2) then
            // nfft is odd
            range = 1:(1+nfft)/2;
        else
            range = 1:nfft/2+1;
        end
        pspec = pspec(range);
        w = w(range);
    elseif strcmpi(freqrange,'centered') then
        // convert two sided spectrum to centered
        rem = modulo(nfft,2);
        
        if rem then
            idx = [(nfft+1)/2+1:nfft 1:(nfft+1)/2];
        else
            idx = [nfft/2+2:nfft 1:nfft/2+1];
        end
        pspec = pspec(idx);
        w = w(range);
        
        if rem then
            w(1:(nfft-1)/2) = w(1:(nfft-1)/2) - fs;
        else
            w(1:nfft/2-1) = w(1:nfft/2-1) - fs;
        end
    end

endfunction

function [h,w] = computeFreqResponse(b,a,n,fs)
    // returns the frequency response (h) and the corresponding frequency 
    // values (w) for a digital filter with numerator b and denominator a. The 
    // evaluation of the frequency response is done at n points between 0 and fs.
    //
    // Similar to MATLAB's freqz(b,a,n,'whole',fs)

    w = linspace(0,fs,n);
    w(1) = 0;   // forcing the first frequency to be 0

    maxPower = max(length(b),length(a));

    // creating a matrix which contains all the required powers of w
    wMatrix = zeros(maxPower,n);

    for i=1:maxPower
        wMatrix(i,:) = w.^(-i);
    end

    // forcing b and a to be a row vector
    b = b(:)';
    a = a(:)';

    numerator = b*wMatrix;
    denominator = a*wMatrix;

    h = numerator./denominator;
endfunction



