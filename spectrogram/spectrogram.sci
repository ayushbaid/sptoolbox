// created on 07-12-15

function varargout = spectrogram(x, varargin)

    // valid function calls
    // S = SPECTROGRAM(X)
    //    S = SPECTROGRAM(X,WINDOW)
    //    S = SPECTROGRAM(X,WINDOW,NOVERLAP)
    //    S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT)
    //    S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT,Fs)
    //    [S,F,T] = SPECTROGRAM(...)
    //    [S,F,T] = SPECTROGRAM(X,WINDOW,NOVERLAP,F,Fs)
    //    [S,F,T,P] = SPECTROGRAM(...)

    // other input params - freqrange, spectrumtype, freqloc, threshold, reassigned
    // other output params - fc, tc


    // *****possible params****
    // x
    // window
    // noverlap - the number of points to overlap
    // nfft - the number of points in the fft calc

    // TODO: do something for the Nx/4.5

    [lhs rhs] = argn(0);

    if lhs==0 then
        // just plot the spectrogram, no return
    elseif lhs==1 then
        // return the spectgram s
    elseif lhs==3 then
        // returns a vector of freqeuncies (f/w) and a vector of time instansts (t) at which the spectogram is computed, along with s
    elseif lhs==2 then
        // returns power spectral density esimates ps along with s
    elseif lhs==4 then
        // returns s, f, t, ps where fc and tc are the frequency and time of the center of energy for each psd
    elseif lhs==6 then
        // return s, f, t, ps, fc, tc
    else
        error(msprintf(gettext("%s: Wrong number of output arguments; {0,1,2,3,4,6} expected"), "atomsInstalled");
    end

    // assigning default values for optional parameters
    isReassigned = %F; // boolean that indicates whether to reassigns each PSD or power spectrum estimate to the location of its center of energy
    minThreshold = 0;

    // setting default value for freqrange
    // 1 -> one sided
    // 2 -> two sided
    // 3 -> centered
    if isreal(x) then
        freqRange = 1;
    else
        freqRange = 2;
    end

    // freqLoc - location of frequency
    // 1->xaxis
    // 2->yaxis
    // ignored if call to spectrogram is with output arguments.
    freqLoc = 1;

    // spectrumType: 1->psd, 2-> power
    spectrumType = 1;

    // thres - lower threshold for the power spectrum values
    // Infinity by default
    thres = %inf;

    for i=1:rhs
        // check for existance of string as an argument
        if type(varargin(i))==10 then
            if strcmpi(varargin(i), "reassigned")==0 then
                isReassigned = %T;
            elseif strcmpi(varargin(i), "MinThreshold")==0 then
                if i~=rhs then
                    thres = varargin(i+1)
                    if type(thres)~=1 & type(thres)~=8 then
                        // neither an integer nor a double
                        error(msprintf(gettext("%s: Wrong type for argument #%d: An integer or double expected for min-threshold"), "atomsInstall", i));
                    end
                    varargin(i+1)=[];
                else
                    error(msprintf(gettext("%s: Missing input argument. Value of minimum threshold not specified"), "atomsInstall"));
                end
                // checking for freqRange param
            elseif strcmpi(varargin(i), "onesided")==0 then
                if ~isreal(x) then
                    error("Incompatible argument onesided as freqrange for complex input");
                end
                freqRange = 1;
            elseif strcmpi(varargin(i), "twosided")==0 then
                freqRange = 3;
            elseif strcmpi(varargin(i), "centered")==0 then
                freqRange = 2;
                // checking for spectrumType param
            elseif strcmpi(varargin(i), "psd")==0 then
                spectrumType = 1;
            elseif strcmpi(varargin(i), "power")==0 then
                spectrumType = 2;
                // checking for freqLoc
            elseif strcmpi(varargin(i), "xaxis")==0 then
                freqLoc = 1;
            elseif strcmpi(varargin(i), "yaxis")==0 then
                freqLoc = 2;
            else
                error(msprintf(gettext("%s: Invalid input argument #%d"), "atomsInstall", i));
            end
            varargin(i)=[];
        end
    end

    // process x; convert to column vector
    // TODO: confirm
    R = size(x,1);
    C = size(x,2);
    if R~=1 & C~=1 then
        error("input data must a vector, not a matrix")
    end
    x = x(:); // converting to column vector
    nx = length(x);

    // for the remaining arguments, only 5 should remain
    L = length(varargin);
    if L>5 then
        error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), "atomsInstall", 1, 10 ));
    end

    // *****parsing remaining arguments*****
    segmentSize = int(nx/8);  // window size without overlap; default - dividing into eigth segments 
    window = [];
    numOfOverlap = [];
    nfft = max(256 ,2^nextpow2(nx));
    fs = 1;
    f = []; // cyclical frequencies; atleast two

    if L>0 then
        // extract window
        temp = varargin(1);
        if ~isempty(temp) & (type(temp)~=1 | type(temp)~=8) then
            error(msprintf(gettext("%s: Argument #1 window should be a positive intgeger or numeric vector"), "atomsInstall"));
        end
        if isempty(temp) then
            window = window('hm', windowSize);
        elseif length(temp)==1 then
            if type(temp)~=8 then
                error(msprintf(gettext("%s: Argument #1 window should be a positive intgeger or numeric vector"), "atomsInstall"));
            end
            // the param is the window size
            windowSize = temp;
            window = window('hm', windowSize);
            // TODO: check if column vector returned
        elseif ~(size(temp,1)~=1 & size(temp,2)~=1) then
            error(msprintf(gettext("%s: Argument #2 window should be a positive integer or numeric vector"), "atomsInstall"));
        else
            // we have been given a window
            window = double(temp(:));
            windowSize = length(window);
        end
    end
    if L>1 then
        // extract noverlap
        temp = varargin(2);
        if ~isempty(temp) & type(temp)~=8 then
            error(msprintf(gettext("%s: Argument #3 noverlap should be a positive integer"), "atomsInstall"));
        end
        if ~isempty(temp) then
            if temp>0 & temp<windowSize then
                numOfOverlap = temp;
            else
                error(msprintf(gettext("%s: Argument #3 noverlap should be positive and less than the window size"), "atomsInstall"));
            end
        else
            // setting it to 50% overlap
            numOfOverlap = int(0.5*windowSize);
        end
    end
    if L>2 then
        // extract nfft (scalar) of f(vector)
        temp = varargin(3);
        if ~isempty(temp) then
            error(msprintf(gettext("%s: Argument #4 nfft should be positive integer or a vector of positive scalars"), "atomsInstall"));
        end
        if length(temp)==1 & type(temp)==8 & temp>0 then
            nfft = temp;
        elseif type(temp)==1 then
            f = temp(:);
        else
            error(msprintf(gettext("%s: Argument #4 nfft should be positive integer or a vector of positive scalars"), "atomsInstall"));
        end
    end
    if L>3 then
        // extract fs
        temp = varargin(4);
        if isempty(temp) | temp<=0 then
            error(msprintf(gettext("%s: Argument #5 fs should be a a positive scalar"), "atomsInstall"));
        elseif type(temp)==8 then
            fs = double(temp);
        else
            fs = temp;
        end
    end


    // *****Evaluation*****
    // determining the length of each segment
    numOfSegments = int16((nx-windowSize)/(windowSize-numOfOverlap));

    // creating a xMat where each column of xMat represents a segment (with overlap) of x
    segmentStartIndices = 1+(0:(numOfSegments-1))*(windowSize-numOfOverlap);    // the start index for each segment
    rowIndices = (1:windowSize)';
    xMat = zeros(windowSize, numOfSegments);
    xMat = x(rowIndices(:,ones(1:numOfSegments)) + segmentStartIndices(ones(1:windowSize,:)))-1;
    
    // apply window on xMat column by column
    xMat = window(:,ones(1:numOfSegment)).*xMat;
    
    // evaluate DFT for each column of xMat
    // if f=[], use FFT to calculate for nfft frequency values
    // otherwise, evaluate on values in f using Goertzel algo
    if isempty(f) then
        [y, f] = computeDFT(x, nfft, fs);
    else
        // TODO: goertal's algorithm not implemented correclty
        [y, ~] = computeDFT(x, f);
    end

    


endfunction



