// Date of creation: 17 Dec, 2015
function [data, msg] = subspaceMethodsInputParser(inputArgsList)
    // Input parser to be used by pmusic and peig

    // primaryInput, p, w, nfft, fs, nwin, noverlap, freqrange, isCorrFlag

    // Output arguments description:
    // data - struct with the following arguments
    //      x - input signal or correlation matrix
    //      p - scalar|2-element vector - signal subspace parameters
    //      w/f - vector
    //      nfft - positive scalar
    //      fs - positive scalar
    //      isWindowSpecified - boolean indicating if window specified in the 
    //                          input params
    //      windowLength - positive scalar
    //      windowVector - vector
    //      noverlap - scalar
    //      freqrange - string
    //      isCorrFlag - boolean
    //      isFsSpecified - boolean indicating if fs argument is present
    //                      (can be empty)
    // msg - error message (if any)

    //  TODO: why max 10 inp arguments for pmusic?

    msg = "";
    data = struct();
    
    
    numOfOutputArgs = argn(1);
    numOfInputArgs = length(inputArgsList);

    // ****getting indices of all string input arguments****
    stringIndices = list();  
    for i=1:numOfInputArgs
        e = inputArgsList(i);
        if type(e)==10 then
            stringIndices($+1)=i;
        end
    end


    isCorrFlag = %F;
    isOneSided = %F;
    isTwoSided = %F;
    isCentered = %F;
    
    if ~isempty(stringIndices) then
        // ****checking for corr flag****
        isCorrFlag = or(strcmpi(inputArgsList(stringIndices),"corr")==0);
        
        
        // ****checking for freqrange****
        isOneSided = or(strcmpi(inputArgsList(stringIndices),"onesided")==0);
        isTwoSided = or(strcmpi(inputArgsList(stringIndices),"twosided")==0 ...
                    | strcmpi(inputArgsList(stringIndices),"whole")==0);
        isCentered = or(strcmpi(inputArgsList(stringIndices),"centered")==0);
    end
    
    freqrange = "";
    if isTwoSided then
        freqrange = "twosided";
    elseif isCentered then
        freqrange = "centered";
    else
        freqrange = "onesided";
    end

    // deleting the string arguments from inputArgsList
    for index=stringIndices
        inputArgsList(index) = null();
    end



    L = length(inputArgsList);
    if L<2 then
        msg = "Input arguments must have x (signal) or R (corr. matrix)" + ...
        "as 1st argument and p as 2nd argument";
        return
    end


    // **** extracting x/R (signal/corr. matrix)
    primaryInput = inputArgsList(1);

    if ndims(primaryInput)<1 | ndims(primaryInput)>2 then
        msg = "Wrong dimensions for argument #1; must be a vector or a matrix";
        return
    end
    if ~IsIntOrDouble(primaryInput, %F) then
        msg = "Wrong type for argument #1; int or double expected";
        return
    end
    // covert to a column vector
    if ndims(primaryInput)==1 then
        primaryInput = primaryInput(:);
    end
    // casting to double
    primaryInput = double(primaryInput);


    //****extracting p****
    p = inputArgsList(2);

    // p must be either scalar or a 2-element vector
    if length(p)~=1 & length(p)~=2 then
        msg = "Wrong size of argument #2 (p); " + ...
        "must be a scalar or a 2-element vector";
        return
    end
    // first argument of p must be an integer
    if ~IsIntOrDouble(p(1),%T) then
        msg = "Wrong type for p(1); must be a positive integer";
        return
    end
    p(1) = int(p(1));
    // TODO: check if positive required
    // 2nd argument, if exists, must be a positive integer'
    if length(p)==2 then
        if ~IsIntOrDouble(p(2),%F) then
            msg = "Wrong type for p(2); must be a scalar";
            return 
        end
    end

    // ****extracting the remaining arguments****

    // assigning default values
    w = [];
    fs = [];
    isFsSpecified = %F;
    nfft = 256;
    windowLength = 2*p(1);
    isWindowSpecified = %F;
    windowVector = [];
    if windowLength==%inf then
        windowLength=[];
    end

    noverlap = [];

    if L==3 | L==4 then
        // (x,p,nfft) and (x,p,w) are candidates
        temp3 = inputArgsList(3);

        // should be a vector
        if ndims(temp3)~=1 then
            msg = "Wrong dimension for argument #3; must be a scalar|vector";
            return
        end

        if length(temp3)==1 then
            // must be nfft

            // positive integer check
            if ~type(temp3)==8 | temp3<=0 then
                msg = "Wrong type for argument #3 (nfft); must be a positive integer";
                return
            end
            nfft = temp3;
        else
            // must be w

            // numeric type check
            if ~IsIntOrDouble(temp3) then
                msg = "Wrong type for argument #3 (w); must be int or double";
                return
            end
            w = double(temp3(:)); 
        end

    end

    if L==4 | L==5 | L==6 then
        // 4th argument will be fs
        temp4 = inputArgsList(4);
        isFsSpecified = %T;
        if length(temp4)==1 then

            if ~IsIntOrDouble(temp4, %T) then
                msg = "Wrong type for argument #4 (fs); must be a positive scalar";
                return
            end
            fs = double(temp4);
        end
    end

    if L==5 | L==6 then
        // must be (x,p,nfft,fs,nwin [,noverlap])
        [temp3, temp4, temp5] = inputArgsList(3:5);

        if length(temp3)==1 then
            // must be nfft

            // positive integer check
            if ~IsIntOrDouble(temp3,%T) then
                msg = "Wrong type for argument #3 (nfft); must be a positive integer";
                return
            end
            nfft = int(temp3);
        elseif ~isempty(temp3) then
            msg = "Wrong type for argument #3 (nfft); must be a positive integer";
            return
        end            

        // fs already parsed

        // parsing window paramater
        if length(temp5)==1 then
            // window length is specified
            if ~IsIntOrDouble(temp5,%T) then
                msg = "Wrong type for argument #5 (nwin); must be a positive integer or a numeric vector";
                return
            end
            windowLength = int(temp5);
            isWindowSpecified = %T;
            // windowVector = window('re',windowLength);
        elseif ndims(temp5)==1 then
            // window is specified
            if ~IsIntOrDouble(temp5, %F) then
                msg = "Wrong type for argument #5 (nwin); must be a positive integer or a numeric vector";
                return
            end
            windowVector = double(temp5(:));
            windowLength = length(windowVector);
            isWindowSpecified = %T;
        elseif ~isempty(temp5) then
            msg = "Wrong type for argument #5 (nwin); must be a positive integer or a numeric vector";
            return
        end
        
        if L==6 then
            temp6 = varargin(6);
            // parsing noverlap
            if length(temp6)==1 then
                if ~(type(temp6)==8 | type(temp6)==1)| temp6<0 then
                    msg = "Wrong type for argument #6 (noverlap); must be a non-negative integer";
                end
                noverlap = int(temp6);
            elseif isempty(temp6) then
                noverlap = windowLength-1;           
            else
                msg = "Wrong type for argument #6 (noverlap); must be a non-negative integer";
            end
        else
            noverlap = windowLength-1; 
        end
    end
    
    // assigning default value for freqrange if not already specified
    if length(freqrange)==0 then
        if isreal(x) then
            freqrange = "onesided";
        else
            freqrange = "twosided";
        end
    end
    
    
    // normalizing w if it exists
    if ~isempty(w) then
        w = w/fs;
    end
    
    
    
    data.x = primaryInput;
    data.p = p;
    data.w = w;
    data.nfft = nfft;
    data.fs = fs;
    data.isWindowSpecified = isWindowSpecified;
    data.windowLength = windowLength;
    data.windowVector = windowVector;
    data.noverlap = noverlap;
    data.freqrange = freqrange;
    data.isCorrFlag = isCorrFlag;
    data.isFsSpecified = isFsSpecified;


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
