// Date of creation: 14 Dec, 2015
// TODO: complete tests after implementation of periodogram
// TODO: plot functionality
function [bw, flo, fhi, power] = powerbw(varargin)
    // Computes The 3-dB (half power) bandwidth
    
    // Calling Sequence
    // BW = powerbw(X)
    // BW = powerbw(X, FS)
    // BW = powerbw(PXX, F)
    // BW = powerbw(SXX, F, RBW)
    // BW = powerbw(_, FREQRANGE)
    // BW = powerbw(_, FREQRANGE, R)
    // [BW, FLO, FHI, POWER] = powerbw(_)
    // powerbw(_)
    //
    // Parameters
    // x: int|double - vector|matrix
    //      Input Signal
    //      In case of a matrix columns act as independent inputs
    // fs: int|double - positive real scalar
    //      Sampling Frequency
    // pxx: int|double - vector|matrix
    //      Power Spectral Density
    // f: int|double - vector
    //      Frequencies
    //      Frequencies corresponing to the power spectral density values.
    // sxx: int|double - vector|matrix
    //      Power Spectral Estimate
    // rbw: int|double - positive scalar
    //      Resolution Bandwidth
    // freqrange: int|double - 2 element vector
    //      Frequency Range To Be Considered
    //      If not specified, the entire bandwidth is considered.
    // r: int|double - positive scalar
    //      Power Level Drop
    //
    // Description
    // bw = powerbw(x)
    //      Returns the 3-dB bandwidth of the input signal x
    //      First, psd is computed using rectangular window. The highest value
    //      of the psd is taken as the reference level for bandwidth computation
    // bw = powerbw(x, fs)
    //      returns the 3-dB bandwidth in terms of sample rate fs
    // bw = powerbw(pxx, f)
    //      returns the 3-dB bandwidth of the power spectral density (psd) 
    //      estimate pxx and the corresponding frequencies f
    // bw = powerbw(sxx, f, rbw)
    //      returns the 3-dB bandwidth of the power spectral estimate sxx
    //      the corresponding frequencies f. rbw is the resoltuon bandwith used 
    //      to integrate the power estimates
    // bw = powerbw(_, freqrange, r)
    //      the frerange specifies the range of frequencies to compute the 
    //      reference level. If specified, the 
    //      reference level will be the average power level in the region 
    //      described by the frequency range. Otherwise, the reference level 
    //      will be the maximum psd value
    // 
    //      if r is specified, the frequency difference is calculated where
    //      the spectrum drops by r-dB below the reference level. Default value
    //      of r is approximately 3.01dB
    // [bw, flo, fhi, power] = powerbw(_)
    //      the additional output arguments are the lower and upper bounds of the occupied bandwidth, and the power in that bandwidth
    // powerbw(_)
    //      plots the psd or the power spectrum and annotates the bandwidth
    //
    // Examples
    // 1) Sine wave with additive guassian noise
    //      x = sin(1:1000) + randn(1,1000);
    //      bw = powerbw(x)
    // 
    //
    // See also
    // bandpower | obw | periodogram | plomb | pwelch
    //
    // Author
    // Ayush Baid
    
    [lhs rhs] = argn(0);

    // Number Of Output Arguments Check
    if ~or(lhs==[0, 1, 4]) then
        error("Wrong number of output arguments; 0,1 or 4 expected");
    end

    // Number Of Input Arguments Check
    if rhs<1 | rhs>6 then
        error("Wrong Number Of Input Arguments. 1 To 5 Expected");
    end

    // ************************************************************************
    // Extracting Input Arguments
    // ************************************************************************

    // assigning default values
    x = [];
    pxx = [];
    sxx = [];
    f = [];
    fs = 2*%pi;
    rbw = [];
    freqrange = [];
    r = 10*log10(2);
    primaryInputType = 1;   // variable depicting whether the primary input is signal x (1), psd (2) or power spectrum estimate (3)

    L = rhs;    // num of elements in varargin
    if rhs==5 then
        // the last two entries are supposed to be freqrange and p respectively
        freqrange = varargin($-1);
        r = varargin($);

        if ~parseFreqrange(freqrange) then
            error(msprintf(gettext("Wrong type for argument #%d (freqrange); positive vector of 2 elements expected"), (rhs-1))); 
        end
        if ~parseR(r)  then
            error(msprintf(gettext("Wrong type for argument #%d (r); positive scalar expected"), rhs)); 
        end
        freqrange = double(freqrange)(:);
        r = double(r); // converting to double

        // deleting the two extracted entries
        varargin($)=[];
        varargin($)=[];
        L = L-2;
    end
    primaryInput = varargin(1);

    R = size(x,1);
    C = size(x,2);
    if R==1 then
        primaryInput = primaryInput(:); // convert to column vector
    end

    if ~IsIntOrDouble(primaryInput, %F) then
        error("Wrong type for argument #1; int or double expected expected");            
    end
    if L==1 then
        primaryInputType=1;
    elseif L==2 then
        // input can be (x,fs) or (pxx,f) or (x,frange)
        temp2 = varargin(2);
        
        if parseFs(temp2) then
            fs = double(temp2);
            primaryInputType = 1;
        elseif parseFVector(temp2, size(primaryInput,1)) then
            f = double(temp2(:));
            primaryInputType = 2;
        elseif parseFreqrange(temp2) then
            freqrange = double(temp2(:));
            primaryInputType = 1;
        else
            error("Invalid input argument #2; must be fs (positive scalar), f(numeric vector) or freqrange (2 element numeric vector)");
        end
    elseif L==3 then
        // input candidates: (x,freqrange,r), (sxx,f,rbw), (pxx,f,freqrange) and 
        // (x, fs, freqrange)
        temp2 = varargin(2);
        temp3 = varargin(3);
        
        if parseFreqrange(temp2) & parseR(temp3) then
            freqrange = double(temp2)(:);
            r = double(temp3);
            primaryInputType = 1;
        elseif parseFVector(temp2, size(primaryInput,1)) & parseRbw(temp3) then
            f = double(temp2)(:);
            rbw = double(temp3);
            primaryInputType = 3;
        elseif parseFVector(temp2, size(primaryInput,1)) & parseFreqrange(temp3) then
            f = double(temp2)(:);
            freqrange = double(temp3)(:);
            primaryInputType = 2;
        elseif parseFs(temp2) & parseFreqrange(temp3) then
            fs = double(temp2);
            freqrange = double(temp3(:));
            primaryInputType = 1;
        else
            error("Invalid input arguments; Possible options: [x, freqrange, r], [sxx, f, rbw], [pxx, f, freqrange] and [x, fs, freqrange]");
        end
    elseif L==4 then
        // input candidates are (x, fs, freqrange, r), (pxx, f, freqrange, r),
        // (sxx, f, rbw, freqrange)
        [temp2 temp3 temp4] = varargin(2:4);
        
        if parseFs(temp2) & parseFreqrange(temp3) & parseR(temp4) then
            fs = double(temp2);
            freqrange = double(temp3(:));
            r = double(temp4);
            primaryInputType = 1;
        elseif parseFVector(temp2, size(primaryInput,1)) & parseFreqrange(temp3) & parseR(temp4) then
            f = double(temp2(:));
            freqrange = double(temp3(:));
            r = double(temp4);
            primaryInputType = 2;
        elseif parseFVector(temp2, size(primaryInput,1)) & parseRbw(temp3) & parseFreqrange(temp4) then
            f = double(temp2(:));
            rbw = double(temp3);
            freqrange = double(temp4(:));
            primaryInputType = 3;
        else
            error("Invalid input arguments; Possible options: [x, fs, freqrange, r], [pxx, f, freqrange, r] and [sxx, f, rbw, freqrange]");
        end
    else
        error("Invalid input arguments");
    end
    
    if ~isempty(freqrange) then
        // check if freqrange is consistent with f and increasing
        if freqrange(1)>=freqrange(2) then
            error("invalid freqrange; the second element should be greater than the first element");
        end
        if freqrange(1)<f(1) | freqrange(2)>f($) then
            error("freqrange is out of bounds");
        end
    end
    // else freqrange remains []
    
    // ************************************************************************
    // Evaluation
    // ************************************************************************
    if primaryInputType==1 then
        x = primaryInput;

        // using rectangular window
        rectWindow = ones(size(x,1),1);
        rbw = enbw(rectWindow);

        if isreal(x) then
            // [pxx, f] = periodogram(x, rectWindow, size(x,1), fs, 'psd');
            pxx = (pspect(length(rectWindow)/2, length(rectWindow), 're', x));
            
            
        else
            [pxx, f] = periodofram(x, rectWindow, size(x,1), fs, 'centered', 'psd');
        end
    elseif primaryInputType==2 then
        pxx = primaryInput;
    elseif primaryInputType==3 then
        sxx = primaryInput;

        // ensure that rbw is larger than a bin widths of f
        minBinWidth = min(diff(f));

        if rbw<minBinWidth then
            error("Resolution bandwidth should be greater than atleast one bin of frequencies");
        end

        pxx = sxx/rbw;
    end
    
    numOfCols = size(pxx, 2);
    freqBinWidths = getFreqBinWidths(f);
    
    powerSpectrum = zeros(size(pxx,1), size(pxx,2));
    // TODO: speedup
    for i=1:numOfCols
        powerSpectrum(:,i) = pxx(:,i) .* freqBinWidths;
    end
    
    // correct psd if spectrum is one-sided
    if f(1)==0 then
        pxx(1,:) = 2*pxx(1,:);
    end
    
    // TODO: what about the nyquist bin thing?
    
    
    flo = zeros(1,numOfCols);
    fhi = zeros(1,numOfCols);
    power = zeros(1,numOfCols);
    
    if isempty(freqrange) then
        // calculate the reference value from the maximum power level
        [refPSD, refIndex] = max(pxx, 'r');
        
        // defining the index bounds for bandwidth boundary search
        leftSearchIndexBound = refIndex;
        rightSearchIndexBound = refIndex;
        
    else
        validIndices = find(freqrange(1)<=f & freqrange(2)>=f);
        
        // calculating the total power
        totalPower = sum(powerSpectrum(validIndices,:), 'r');
        
        // refPSD = totalPower ./ freqBinWidths(validIndices);
        refPSD = sum(pxx(validIndices,:), 'r');
        
        // search for the frequency in the center of the channel
        freqCenter = sum(freqrange)/2;
        temp = find(f<freqcenter);
        rightSearchIndexBound = temp($);
        leftSearchIndexBound = find(f>freqcenter,1);
    end
    
    // freq value at edge of the required region
    refPSD = refPSD*(10^(-r/10));

    // performing a cumulative sum of power along columns; 0 as the first entry
    cumPower = [zeros(1,numOfCols); cumsum(powerSpectrum,1)];

    // associating the cumulative power to the frequencies which are 
    // midpoint between original frequency pairs; with original endpoints
    cumFreq = [f(1); 0.5*(f(1:$-1)+f(2:$)); f($)];
    
    for col=1:numOfCols
        // processing each column independently4
        leftBound = leftSearchIndexBound(col);
        rightBound = rightSearchIndexBound(col);
        
        temp = find(pxx(1:leftBound,col) <= refPSD(col));
        leftIndex = temp($);
        rightIndex = find(pxx(rightBound:$,col) <= refPSD(col),1)+rightBound-1;
        
        [flo(col), fhi(col), power(col)] = ...
            getBW(leftIndex,rightIndex,leftBound,rightBound,pxx(:,col),...
                f,cumPower(:,col),cumFreq,refPSD(col));     
    end
endfunction

function [fLo, fHi, power] = getBW(iL,iR,leftBound,rightBound,pxx,f,...
                                cumPower,cumFreq,refPSD)                     
    if isempty(iL) then
        // no left index found, choose the first freq value
        fLo = f(1);
    elseif iL==rightBound then 
        // no value on left 
        fLo = %inf;
    else
        // fLo is between f(iL) and f(iL+1)
        // use log interpolation to get power value
        fLo = linInterp(log10(pxx(iL)), log10(pxx(iL+1)), f(iL), f(iL+1), ...
                    log10(refPSD));
    end

    if isempty(iR) then
        // no right index found, choose the last frequency value
        fHi = f($);
    elseif iR==leftBound then 
        // no value on right 
        fHi = %inf;
    else
        // fHi is between f(iR) and f(iR-1)
        // use log interpolation to get power value
        fHi = linInterp(log10(pxx(iR)), log10(pxx(iR-1)), f(iR), f(iR-1), ...
                    log10(refPSD));
    end

    // find the integrated power for the low and high frequency range
    
    pLo = interp1(cumFreq, cumPower, fLo);
    pHi = interp1(cumFreq, cumPower, fHi);
    
    power = pHi-pLo;
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


function yReq = linInterp(x1, x2, y1, y2, xReq)
    // Linearly interpolcate between 2 points
    // Corresponds to the algorithm in IEEE Std 181-2003 Section 5.3.3.2 
    // step (b) for computing reference level instants between two samples
    // find yReq = f(xReq) where y1=f(x1), y2=f(x2) and f is a straight line 
    // function
    
    slope = (y2-y1)/(x2-x1);
    yIntercept = y2-slope*x2;
    
    yReq = slope*xReq + yIntercept;
    
endfunction

function result = parseFs(inp)
    // check if the input can be fs
    isEmptyAllowed = %T;

    result = %F;
    if isempty(inp) & isEmptyAllowed then
        result = %T;
    elseif length(inp)==1 & IsIntOrDouble(inp, %T) then
        result = %T;
    end
endfunction

function result = parseFVector(inp, expectedRowSize)
    // check if the input can be f
    isEmptyAllowed = %F;
    
    result = %F;
    if isempty(inp) & isEmptyAllowed then
        result = %T;
    elseif isvector(inp) & length(inp)==expectedRowSize & IsIntOrDouble(inp, %F) then
        result = %T;
    end
endfunction

function result = parseRbw(inp)
    // check if input can be rbw
    isEmptyAllowed = %F
    
    result = %F;
    if isempty(inp) & isEmptyAllowed then
        result = %T;
    elseif length(inp)==1 & IsIntOrDouble(inp, %T) then
        result = %T;
    end
endfunction

function result = parseFreqrange(inp)
    // check if input can be freqrange
    isEmptyAllowed = %T;
    
    result = %F;
    if isempty(inp) & isEmptyAllowed then
        result = %T;
    elseif length(inp)==2 & IsIntOrDouble(inp, %F) then
        result = %T;
    end
endfunction

function result = parseR(inp)
    // check if input can be r
    isEmptyAllowed = %T;
    
    result = %F;
    if isempty(inp) & isEmptyAllowed then
        result = %T;
    elseif length(inp)==1 & IsIntOrDouble(inp, %T) then
        result = %T;
    end
endfunction
