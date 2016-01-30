// Date of creation: 10 Jan, 2016
function [S,f,v,e] = peig(varargin)
    // Psuedospectrum using the eigenvector method.
    //
    // Calling Sequence
    // [S,w] = peig(x,p)
    // [S,w] = peig(x,p,w)
    // [S,w] = peig(x,p,nfft)
    // [S,w] = peig(x,p,nfft,fs)
    // [S,w] = peig(x,p,f,fs)
    // [S,f] = peig(...,'corr')
    // [S,f] = peig(x,p,nfft,fs,nwin,noverlap)
    // [...] = peig(...,freqrange)
    // [...,v,e] = peig(...)
    // peig(...)
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
    // rooteig | pmusic | pmtm | pcov | pmcov | pburg | pyulear | pwelch | corrmtx
    //
    // Authors
    // Ayush Baid
    //
    // References
    // [1] Petre Stoica and Randolph Moses, Introduction To Spectral
    //     Analysis, Prentice-Hall, 1997, pg. 15
    // [2] S. J. Orfanidis, Optimum Signal Processing. An Introduction. 
    //     2nd Ed., Macmillan, 1988.
    
    funcprot(0);
    
    exec('subspaceMethodsInputParser.sci',-1);
    exec('musicBase.sci',-1);

    // ("**start**");
    [data, msg] = subspaceMethodsInputParser(varargin);
    // disp("**input parsed**");

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
    musicData.eigenvals,data.w,data.nfft, data.fs, data.freqrange,data.isFsSpecified);
        
    v = musicData.noiseEigenvects;
    e = musicData.eigenvals;

endfunction

function [pspec,w] = pseudospectrum(noiseEigenvects, eigenvals, freqvector, ...
    nfft, fs, freqrange,isFsSpecified)
    // disp("noise eigenvects in pseudospectrum - ");
    // disp(noiseEigenvects);
    
    // NOTE: the only difference from the pmusic code
    // Using the noise subspace eigenvalues as weights
    weights = eigenvals($-size(noiseEigenvects,2)+1:$); 

    denominator = 0;

    for i=1:size(noiseEigenvects,2);
        // disp("looping in pseudospectrum");
        if isempty(freqvector) then
            [h,w] = computeFreqResponseByFFT(noiseEigenvects(:,i),nfft,fs,...
                            isFsSpecified);
        else
            h = computeFreqResponseByPolyEval(noiseEigenvects(:,i),...
                            freqvector,fs,isFsSpecified);
            w = freqvector;
        end
        denominator = denominator + (abs(h).^2)./weights(i);
        // disp(h(1:10));
    end
    
    // disp(denominator(1:5));
    // computing pseudospectrum pspec
    pspec = 1.0 ./ denominator;
    // converting to column vector
    pspec = pspec(:);
    // correcting the range of pspec according to the user specification
    if strcmpi(freqrange, 'onesided')==0 then
        if modulo(nfft,2) then
            // nfft is odd
            range = 1:(1+nfft)/2;
        else
            range = 1:nfft/2+1;
        end
        pspec = pspec(range);
        w = w(range);
    elseif strcmpi(freqrange,'centered')==0 then
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

function [h,w] = computeFreqResponseByFFT(b,n,fs,isFsSpecified)
    // returns the frequency response (h) and the corresponding frequency 
    // values (w) for a digital filter with numerator b. The evaluation of the 
    // frequency response is done at n points in [0,fs) using fft algorithm
    //
    // Similar to MATLAB's freqz(b,a,n,'whole',fs)
    if isempty(fs) then
        fs=1;
    end
    w = linspace(0,2*%pi/fs,n+1)';
    w($) = [];
    w(1) = 0;   // forcing the first frequency to be 0
    
    // forcing b and a to be column vectors
    b = b(:);
    
    // zero padding for fft
    zeroPadLength = n - length(b);
    zeroPad = zeros(zeroPadLength,1);
    b = [b; zeroPad];


    h = fft(b);
    
    if isFsSpecified then
        w = w*fs/(2*%pi);
    end
    
endfunction

function h = computeFreqResponseByPolyEval(b,f,fs,isFsSpecified)
    // returns the frequency response (h) for a digital filter with numerator b.
    // The evaluation of the frequency response is done at frequency values f
    
    f = f(:);
    b = b(:);
    if isFsSpecified then
        // normalizing the f vector
        w = f*2*%pi/fs;
    else
        w = f;
    end
    
    n = length(b);
    powerMatrix = zeros(length(f),n);
    powerMatrix(:,1) = 1;
    for i=2:n
        powerMatrix(:,i) = exp(w*(-i+1)*%i);
    end
    
    h = powerMatrix*b;
     
endfunction
