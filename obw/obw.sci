// Date Of Creation: 9 Dec, 2015
// TODO: complete documentation
// TODO: periodogram
// TODO: plot
// TODO: remove positive check for freqrange
function [bw, flo, fhi, pwr] = obw(varargin)
    // Computes The Occupied Bandwidth
    // Calling Sequence
    // BW = obw(X)
    // BW = obw(X, FS)
    // BW = obw(PXX, F)
    // BW = obw(SXX, F, RBW)
    // BW = obw(_, FREQRANGE, P)
    // [BW, FLO, FHI, POWER] = obw(_)
    // obw(_)
    // parameters
    // x: int|double - vector|matrix - input signal
    //      in case of a matrix columns act as independent inputs
    // fs: int|double - positive real scalar - sample rate
    // pxx: int|double - vector|matrix - power spectral density
    // f: int|double - vector - frequencies corresponding to pxx
    // sxx: int|double - vector|matrix - power spectral estimate
    // rbw: int|double - positive scalar - resolution bandwidth
    // freqrange: int|double - 2 element vector - frequency range to be considered
    //      if not specified, the entire bandwidth is considered
    // p: int|double - positive scalar - power percentage
    // Description
    // bw = obw(x)
    //      returns the 99% occupied bandwidth of the input signal x
    // bw = obw(x, fs)
    //      returns the occupied bandwidth in terms of sample rate fs
    // bw = obw(pxx, f)
    //      returns the 99% occupied bandwidth of the power spectral density (psd) estimate pxx and the corresponding frequencies f
    // bw = obw(sxx, f, rbw)
    //      returns the 99% occupied bandwidth of the power spectral estimate sxx, the corresponding frequencies f. rbw is the resoltuon bandwith used to integrate the power estimates
    // bw = obw(_, freqrange, p)
    //      the calculation of the occupied bandwidth is done over the interval specified by the freqrange.
    //      p specifies the total signal power contained in the occupied band
    // [bw, flo, fhi, power] = obw(_)
    //      the additional output arguments are the lower and upper bounds of the occupied bandwidth, and the power in that bandwidth
    // obw(_)
    //      plots the psd or the power spectrum and annotates the occupied bandwidth
    // Examples
    // TODO:
    // See also
    // bandpower | periodogram | plomb | powerbw | pwelch
    // Author
    // Ayush Baid
    // References
    // TODO: 

    [lhs rhs] = argn(0);

    // Number Of Output Arguments Check
    if ~or(lhs==[0, 1, 4]) then
        error("Wrong number of output arguments; 0,1 or 4 expected");
    end

    // Number Of Input Arguments Check
    if rhs<1 | rhs>5 then
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
    p = 0.99;
    primaryInputType = 1;   // variable depicting whether the primary input is signal x (1), psd (2) or power spectrum estimate (3)

    L = rhs;    // num of elements in varargin
    if rhs>=4 then
        // the last two entries are supposed to be freqrange and p respectively
        freqrange = varargin($-1);
        p = varargin($);

        if ~IsIntOrDouble(freqrange, %T) then
            disp("error!");
            error(msprintf(gettext("Wrong type for argument #%d (freqrange); positive vector of 2 elements expected"), (rhs-1))); 
        end
        if ~IsIntOrDouble(p, %F) & temp3>=0 & temp3<=100  then
            error(msprintf(gettext("Wrong type for argument #%d (p); 0<p<100"), rhs)); 
        end
        freqrange = double(freqrange)(:);
        p = double(p)/100; // converting to a ratio from percentage

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
        // input can be (x,fs) or (pxx,f)t to Kobe for being
1: An absolute legend
2: Awesome to work with!
        temp2 = varargin(2);
        if ~isvector(temp2) then
            error("Wrong dimension for argument #2; should be a vector");
        end
        temp2 = temp2(:);

        if length(temp2)==1 then
            // (x, fs) possible
            if ~IsIntOrDouble(temp2, %T) then
                error("Wrong type for argument #2 (fs); positive scalar expected"); 
            end
            fs = double(temp2);
            primaryInputType = 1;
        elseif size(temp2,1)==size(primaryInput, 1) then
            // (pxx, f) candidate
            if ~IsIntOrDouble(temp2, %F) then
                error("Wrong type for argument #2 (f); numeric vector|matrix expected"); 
            end
            f = double(temp2);
            primaryInputType = 2;
        else
            error("Incorrect arguments");
        end
    elseif L==3 then
        // input candidates - (x, freqrange, p), (sxx, f, rbw)
        temp2 = varargin(2);
        temp3 = varargin(3);

        if ~isvector(temp2) then
            error("Wrong dimension for argument #2; should be a vector");
        end
        temp2 = temp2(:);
        if length(temp2)==2 & length(temp3)==1 then
            // (x, freqrange, p) possible
            if ~IsIntOrDouble(temp2, %T) then
                error("Wrong type for argument #2 (freqrange); positive vector of 2 elements expected"); 
            end
            if ~IsIntOrDouble(temp3, %F) & temp3>=0 & temp3<=100  then
                error("Wrong type for argument #3 (p); 0<p<100"); 
            end
            freqrange = double(temp2)(:);
            p = double(temp3)/100; // converting to a ratio from percentage
            primaryInputType = 1;
        elseif size(temp2,1)==size(primaryInput,1) & length(temp3)==1 then
            // (sxx, f, rbw) is candidate
            if ~IsIntOrDouble(temp2, %F) then
                error("Wrong type for argument #2 (f); numeric vector|matrix expected"); 
            end
            if ~IsIntOrDouble(temp3, %T);
                error("Wrong type for argument #3 (rbw); positive scalar expected");
            end 
            f = double(temp2);
            rbw = temp3;
            primaryInputType = 3;
        else
            error("Incorrect arguments");
        end
    end


    // ************************************************************************
    // Evaluation
    // ************************************************************************
    if primaryInputType==1 then
        x = primaryInput;

        // using rectangular window
        rectWindow = ones(size(x,1),1);
        rbw = enbw(rectWindow);

        if isreal(x) then
            [pxx, f] = periodogram(x, rectWindow, size(x,1), fs, 'psd');
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

    if ~isempty(freqrange) then
        // check if freqrange is consistent with f and increasing
        if freqrange(1)>=freqrange(2) then
            error("invalid freqrange; the second element should be greater than the first element");
        end
        if freqrange(1)<f(1) | freqrange($)>f($) then
            error("freqrange is out of bounds");
        end
    else
        // assign a default range
        freqrange = zeros(2,1);
        freqrange(1) = f(1);
        freqrange(2) = f($);
    end
    
    C = size(pxx,2);
    freqBinWidths = getFreqBinWidths(f);
    power = zeros(size(pxx,1), size(pxx,2));
    // TODO: speedup
    for i=1:C
        power(:,i) = pxx(:,i) .* freqBinWidths;
    end

    // performing a cumulative sum of power along columns; 0 as the first entry
    cumPower = [zeros(1,C); cumsum(power,1)];

    // associating the cumulative power to the frequencies which are 
    // midpoint between original frequency pairs; with original endpoints
    cumFreq = [f(1); 0.5*(f(1:$-1)+f(2:$)); f($)];

    // linearly interpolating cumPower for freqrange values
    // TODO: check if ignoring checks is gonna hurt; coz freqrange is already inside f
    powerLowerFreq = zeros(1, C);  // cumulative power at lower freq range
    powerHigherFreq = zeros(1, C);  // cumulative power at higher freq range
    // todo speedup desired
    for i=1:C    // iterating on columns    
        powerLowerFreq(1,i) = interp1(cumFreq, cumPower(:,i), freqrange(1), 'linear');
        powerHigherFreq(1,i) = interp1(cumFreq, cumPower(:,i), freqrange(2), 'linear'); 
    end

    // power between the search range
    totPower = powerHigherFreq - powerLowerFreq; 

    // Calculating the lower and upper powrer vals for a given ratio of
    // power enclosed
    powerLo = powerLowerFreq + 0.5*(1-p)*totPower;
    powerHi = powerHigherFreq - 0.5*(1-p)*totPower;

    // interpolating the frequencies at these power values
    flo = zeros(1, C);  // cumulative power at lower freq range
    fhi = zeros(1, C);  // cumulative power at higher freq range
    // TODO: speedup desired
    for i=1:C    // iterating on columns    
        flo(1,i) = interp1(cumPower(:,i), cumFreq, powerLo(1,i), 'linear');
        fhi(1,i) = interp1(cumPower(:,i), cumFreq, powerHi(1,i), 'linear');
    end

    bw = fhi - flo; // occupied bandwidth
    pwr = p*totPower; // occupied power    
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
    if isPositiveCheck & or(inputNum<0) then
        result = %F;
        return
    end

    result = %T;
    return
endfunction
