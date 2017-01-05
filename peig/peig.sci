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
    //
    //
    // Parameters
    // x: Input signal. In case of a matrix, each row of x represents a seperate observation of the signal. If 'corr' flag is specified, then x is the correlation matrix. If w is not specified in the input, it is determined by the algorithm. If x is real valued, then range of w is [0, pi]. Otherwise, the range of w is [0, 2pi)
    // p: p(1) is the dimension of the signal subspace. p(2), if specified, represents a threshold that is multiplied by the smallest estimated eigenvalue of the signal's correlation matrix.
    // w: Vector of normalized frequencies over which the pseuspectrogram is to be computed. If w is not specified in the input, it is determined by the algorithm. If x is real valued, then range of w is [0, pi]. Otherwise, the range of w is [0, 2pi).
    // nfft: Length of the fft used to compute pseudospectrum. Should be a natural number. Default value of 256.
    // fs: Sampling rate. Used to convert the normalized frequencies (w) to actual values (f) and vice-versa.
    // nwin: Window length/vector. If nwin is scalar, is must be a natural number and denoted the length of rectangular window. Otherwise, the vector input is considered as the window coefficients and must have the same length as a column of x. Not used if 'corr' flag present. If x is a matrix and nwin is scalar (window length), windowing is not performed.Assumes a default value of 2*p(1)
    // noverlap: Number of sample points by which successive windows overlap. Not used if x is a matrix. Should be a natural number. Assumes default value of (window length-1).
    // freqrange: Range of frequencies to include in f or w. Three possible values - 'onesided', 'twosided', 'centered'
    // 'corr' flag: Indicates that the primary input x is actually a correlation matrix
    // S: Pseudospectrum Estimate.
    // f: Frequency corresponding to S
    // w: Normalized Frquency corresponding to S
    // v: Matrix of noise eigenvectors
    // e: Eigenvalues associated with eigenvectors in v
    //
    //
    // Description
    // peig computes the pseudospectrum using MUSIC (MUltiple Signal Classification). The algorithm uses the eigenspace of the signal's correlation matrix to estimate frequency content. Eigenvalues are used to weight the contributions from eigenvectors towards the spectrum.
    // The length of S (and hence w/f) depends on the type of values in x and nfft. If x is real, length of s is (nfft/2 + 1) {Range of w = [0, pi]}. If nfft is even and (nfft+1)/2 {Range of w = [0, pi)} otherwise. If x is complex, length of s is nfft.
    //
    //
    // Examples
    // // Pseudospectrum of two sinusoids with additive noise
    //      n = 0:249;
    //      x = sin(0.3*n*%pi) + sin(0.2*n*%pi) + 0.01*randn(size(n));
    //      [S, w] = peig(x, 4);
    // // Using windowing
    //      n = 0:749;
    //      x = sin(0.25*n*%pi) + 0.05*randn(size(n));
    //      Xcorr =  corrmtx(x, 7, 'mod'); // Creating correlation matrix
    //      [S, w] = peig(Xm, 2);
    //
    //
    // See also
    // corrmtx
    // pburg
    // periodogram
    // pmtm
    // pmusic
    // prony
    // pwelch
    // rooteig
    // rootmusic
    //
    //
    // Authors
    // Ayush Baid
    //
    // Bibliography
    // [1] Petre Stoica and Randolph Moses, Introduction To Spectral Analysis, Prentice-Hall, 1997, pg. 15
    // [2] S. J. Orfanidis, Optimum Signal Processing. An Introduction. 2nd Ed., Macmillan, 1988.
    
    funcprot(0);
    
    exec('subspaceMethodsInputParser.sci',-1);
    exec('musicBase.sci',-1);

    [data, msg, err_num] = subspaceMethodsInputParser(varargin);
    
    if length(msg)==0 then
        // no error occured
    else
        error(err_num, "peig: " + msg);
    end

    [musicData,msg] = musicBase(data);

    if length(msg)~=0 then
        error("peig: " + msg);
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
    weights = eigenvals(($-size(noiseEigenvects,2)+1):$); 

    denominator = 0;
    
    isFreqGiven = %F;
    

    for i=1:size(noiseEigenvects,2);
        // disp("looping in pseudospectrum");
        if isempty(freqvector) then
            [h,w] = computeFreqResponseByFFT(noiseEigenvects(:,i),nfft,fs,...
                            isFsSpecified);
        else
            [h,w] = computeFreqResponseByPolyEval(noiseEigenvects(:,i),...
                            freqvector,fs,isFsSpecified);
            isFreqGiven = %T;
        end
        denominator = denominator + (abs(h).^2)./weights(i);
    end

    // computing pseudospectrum pspec
    pspec = 1.0 ./ denominator;
    // converting to column vector


    pspec = pspec(:);
    
    if ~isFreqGiven then
        // correcting the range of pspec according to the user specification
        if strcmpi(freqrange, 'onesided')==0 then
            if modulo(nfft,2) then
                // nfft is odd
                range = 1:(1+nfft)/2;
            else
                range = 1:((nfft/2)+1);
            end
            pspec = pspec(range);
            w = w(range);
            
        elseif strcmpi(freqrange,'centered')==0 then
            // convert two sided spectrum to centered
            rem = modulo(nfft,2);
            
            if rem then
                idx = [((nfft+1)/2+1):nfft 1:(nfft+1)/2];
            else
                idx = [(nfft/2+2):nfft 1:(nfft/2+1)];
            end
            pspec = pspec(idx);
            w = w(idx);
            
            if rem then
                w(1:(nfft-1)/2) = - w(nfft:-1:((nfft+1)/2+1));
            else
                w(1:(nfft/2-1)) = - w(nfft:-1:(nfft/2+2));
            end
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
    w = linspace(0,2*%pi,n+1)';
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

function [h,w] = computeFreqResponseByPolyEval(b,f,fs,isFsSpecified)
    // returns the frequency response (h) for a digital filter with numerator b.
    // The evaluation of the frequency response is done at frequency values f
    
    // disp(f);
    // disp(isFsSpecified);
    
    f = f(:);
    b = b(:);
    
    n = length(b);
    powerMatrix = zeros(length(f),n);
    powerMatrix(:,1) = 1;
    for i=2:n
        powerMatrix(:,i) = exp(f*(-i+1)*%i);
    end
    
    h = powerMatrix*b;
    
    if isFsSpecified then
        w = f * fs/(2*%pi);
    end
     
endfunction
