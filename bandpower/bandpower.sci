// Date of creation: 15 Dec, 2015
function p = bandpower(varargin)
    // Computes the band power
    //
    // Calling Sequence
    // p = bandpower(x)
    // P = bandpower(x, fs, freqrange)
    // P = bandpower(PXX, F, 'PSD')
    // P = bandpower(PXX, F, FREQRANGE, 'PSD')
    //
    // Parameters
    // x: int|double - vector|matrix - input signal
    //      in case of a matrix, the columns are treated as independently
    // fs: int|double - positive real scalar - sample rate
    //      default value - 1
    // freqrange: int|double - vector - frequency range for the band power
    //      computation. If the input signal x has N samples, then frequency
    //      range must be within the following intervals
    //          * [0 fs/2] is x is real-valued and N is even
    //          * [0 (N-1)fs/2N] if x is real-valued and N is odd
    //          * [-(N-2)fs/2N fs/2] if x is complex-valued and N is even
    //          * [-(N-1)fs/2N (N-1)fs/2N] is x is complex-valued and N is odd
    // pxx: int|double - vector|matrix of nonnegative entries - power spectral 
    //      density (PSD). In case of matrix, each column in treated as an 
    //      independent channel
    // f: int|double - vector - frequency vector for PSD estimates
    // 'PSD' flag: to specify that the primary input is PSD instead of the
    //      signal
    //
    // Description
    // p = bandpower(x)
    //      returns the average power of the input signal x. If x is a matrix,
    //      average power for each column is computed independently
    // p = bandpower(x, fs, freqrange) 
    //      computes the band power between the two frequency limits specified 
    //      by the freqrange vector. fs is the sampling rate for the input 
    //      signal. The power is estimated using a hamming window and using the 
    //      periodogram of the same length as the input vector. There are 
    //      restrictions on the freqrange depending on x
    // p =  bandpower(pxx, f, 'psd')
    //      returns the average power computed via rectangular approximation of 
    //      integral of the PSD pxx whose corresponding frequencies are f. If 
    //      pxx is a matrix, then each column is treated as an independent 
    //      channel
    // p = bandpower(pxx, f, freqrange, 'psd')
    //      the additional input argument freqrange specified the range of 
    //      frequencies over which the band power has to be computed
    //
    // Note: if the freqrange values does not exactly match the frequency values
    //       stored in f, the the closest values in f are used instead
    //
    // Examples
    // TODO:
    //
    // See also
    // powerbw | obw | periodogram | sfdr | pwelch | meanfreq | medfreq | plomb
    //
    // Authors
    // Ayush Baid
    //
    // References
    // TODO:
    
    [numOfOutputArgs numOfInputArgs] = argn(0);
    
    if numOfOutputArgs~=1 then
        error("Wrong number of output arguments; 1 expected");
    end
    
    if numOfInputArgs<1 | numOfInputArgs>4 then
        error("Wrong number of input arguments; 1-4 expected");
    end
    
    // checking for presence of 'psd' flag
    stringIndices = list();  
    for i=1:numOfInputArgs
        e = varargin(i);
        if type(e)==10 then
            stringIndices($+1)=i
        end
    end
    flagIndices = find(strcmpi(varargin(stringIndices), "psd")==0);
    isPSD = or(flagIndices);
    varargin(stringIndices) = [];
    
    if isPSD then
        p = computeBandPowerFromPSD(varargin(1), varargin(2), varargin(3));
    else
        p = computeBandPowerFromSignal(varargin(1), varargin(2), varargin(3));
    end
endfunction

function p = computeBandPowerFromPSD(pxx, f, freqrange)
    // ************************************************************************
    // Checking input arguments
    // ************************************************************************
    // if pxx is a vector, convert to column vector
    if size(pxx,1)==1 then
        pxx = pxx(:);
    end
    if ndims(pxx)<1 | ndims(pxx)>2 then
        error("Wrong dimesnion for argument #1 (pxx); must be vector or a 2D matrix");
    end
    // check data type
    if ~IsIntOrDouble(pxx, %F) then
        error("Wrong type for argument #1 (pxx); must be int or double")
    end
    // check non-negativity
    if or(pxx<0) then
        error("Invalid values for argument #1 (pxx); must be non-negatives")
    end
    pxx = double(pxx);
    
    
    if ~isvector(f) | size(pxx,1)~=length(f) then
        error("Wrong dimension for argument #2 (f); must a vector whose length is the number of rows of pxx");
    end
    if ~IsIntOrDouble(f,%F) then
        error("Wrong type for argument #2 (f); must be int or double");
    end
    // strictly increasing
    if or(diff(f)<=0) then
        error("Invalid values for argument #2 (f); must be strictly increasing");
    end
    f = double(f(:));


    if ~isempty(freqrange) then
        // only 2 elements
        if length(freqrange)~=2 then
            error("Wrong dimension for argument #3 (freqrange); must be a vector of 2 elements");
        end
        if ~IsIntOrDouble(freqrange, %F) then
            error("Wrong type for argument #3 (freqrange); must be int or double");
        end
        // 2nd value should be greater than the first value
        if freqrange(1)>=freqrange(2) then
            error("Invalid value for argument #3 (freqrange); 2nd element should be greater than the 1st");
        end
        // checking if freqrange values are in f
        if freqrange(1)<f(1) | freqrange(2)>f($) then
            error("Invalid value for argument #3(freqrange); values must be contained in f"); 
        end
        freqrange = double(freqrange(:));
    end


    // ************************************************************************
    // Computing power
    // ************************************************************************    
    if ~isempty(freqrange) then
        // find indices of f whose values are just loose than freqrange
        iL = length(f) - find(f($:-1:1)<=freqrange(1),1) + 1;
        iR = find(f>=freqrange(2), 1);
        binWidths = [diff(f); 0];    // don't use the last bin
    else
        iL = 1;
        iR = length(f);
        binWidths = getFreqBinWidths(f);
    end
    
    disp(iL);
    disp(iR);
    
    // calculating power from PSD using rectangular approximations
    p = binWidths(iL:iR)'*pxx(iL:iR,:);
       
endfunction

function p = computeBandPowerFromSignal(x, fs, freqrange)
    // ************************************************************************
    // Checking input arguments
    // ************************************************************************
    // if x is a vector, convert to column vector
    if isvector(x) then
        x = x(:);
    end
    if ndims(x)<1 | ndims(x)>2 then
        error("Wrong dimension for argument #1 (x); must be vector or a 2D matrix");
    end
    // check data type
    if ~IsIntOrDouble(x, %F) then
        error("Wrong type for argument #1 (x); must be int or double")
    end
    x = double(x);
    
    
    if isempty(freqrange) then
        // directly compute mean square value of x
        xSquare = x.^2;
        p = sum(xSqaure, 'r');
        return
    end
    
    if length(fs)~=1 then
        error("Wrong type for argument #2 (fs); must be a positive scalar");
    end
    if ~IsIntOrDouble(x, %T) then
        error("Wrong type for argument #2 (fs); must be a positive scalar");
    end
    fs = double(fs);
    
    if ~isempty(freqrange) then
        // only 2 elements
        if length(freqrange)~=2 then
            error("Wrong dimension for argument #3 (freqrange); must be a vector of 2 elements");
        end
        if ~IsIntOrDouble(freqrange, %F) then
            error("Wrong type for argument #3 (freqrange); must be int or double");
        end
        // 2nd value should be greater than the first value
        if freqrange(1)>=freqrange(2) then
            error("Invalid value for argument #3 (freqrange); 2nd element should be greater than the 1st");
        end
        freqrange = double(freqrange(:));
    end
    
    n = size(x,1);
    
    if isreal(x) then 
        [pxx, f] = periodogram(x, hamming(n), n, fs);
    else
        [pxx, f] = periodogram(x, hamming(n), n, fs, 'centered');
    end
    // calculate power using pxx
    p = computeBandPowerFromPSD(pxx, f, freqrange);
    
endfunction

function binWidths = getFreqBinWidths(f)
    // calculates the bin widths, i.e the difference between the 
    // frequency entries

    // All the bin widths, expect those at the extreme, can be 
    // calculated by a simple difference. Assume uniform intervals to
    // estimate the missing bin width

    // The location of the missing width is dependent on location of the zero
    // frequency value

    // When f(1) ~= 0, if the number of points is even, the
    // Nyquist point (Fs/2) is exact, therefore, the missing range is at
    // the left side, i.e., the beginning of the vector.  If the number
    // of points is odd, then the missing freq range is at both ends.
    // However, due to the symmetry of the real signal spectrum, it can
    // still be considered as if it is missing at the beginning of the
    // vector.  Even when the spectrum is asymmetric, since the
    // approximation of the integral is close when NFFT is large,
    // putting it in the beginning of the vector is still ok.
    //
    // When f(1)==0, the missing range is always at the end of
    // the frequency vector since the frequency always starts at 0.


    binWidths = diff(f);
    
    // assume a relatively uniform interval for calculating the missing width
    missingWidth = (f($) - f(1)) / (length(f) - 1);

    isStartWithZero = (f(1)==0);
    if ~isStartWithZero then
        binWidths = [missingWidth; binWidths];
    else
        binWidths = [binWidths; missingWidth];
    end
endfunction


function result = IsIntOrDouble(inputNum, isPositiveCheck)
    // Checks if The Input Is Integer Or Double
    // Also Checks if It Is Greater Than 0 For IsPositiveCheck = True

    if ~(type(inputNum)==1 | type(inputNum)==8) then
        result = %F;
        return
    end
    if isPositiveCheck & or(inputNum<=0) then
        result = %F;
        return
    end

    result = %T;
    return
endfunction

