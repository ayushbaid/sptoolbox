function L = filternorm(b,a,varargin)
    // Calculates the L-2 norm or L-infinity norm of a digital filter
    //
    //
    // Calling sequence
    // L = filternorm(b,a)
    // L = filternorm(b,a,pnorm)
    // L = filternorm(b,a,2,tol)
    //
    // 
    // Description
    // L = filternorm(b,a)
    //      Computes the L-2 norm of the digital filter defined by numerator 
    //      coefficients b and denominator coefficients a
    // L = filternorm(b,a,pnorm)
    //      Computes the L-2 norm (or L-infinity norm), if pnorm is 2 (or inf)
    // L = filternorm(b,a,2,tol)
    //      Computes the L-2 norm of a IIR filter with specified tolerance. The
    //      tolerance can also be specified for L-2 norms. tol defaults to 10^(-8).
    //
    // Arguments
    // b: double
    //      The filter numerator coefficients. If b is a matrix, then each column
    //      is treated as an independent filter
    // a: double
    //      The filter denominator coefficients. If, a is a matrix, it must have
    //      the same number of columns as b
    // pnorm: 2 or inf
    //      The L-norm to be calculated.
    // tol: positive real scalar
    //      The tolerance of the L-2 norm to be calculated. If tol not specified,
    //      it defaults to 10^(-8).
    //
    //
    // Examples
    // 1) L-2 norm of a chebyshev type 1 filter with tol = 10^(-10)
    //
    //
    // See also
    // norm | zp2sos
    //
    // Authors
    // Ayush Baid
    
    // ** Check on number of input, output arguments
    [numOutArgs, numInArgs] = argn(0);
    
    if numInArgs<2 | numInArgs>4 then
        msg = "filternorm: Wrong number of input argument; 2-4 expected";
        error(77,msg);
    end
    if numOutArgs~1 then
        msg = "filternorm: Wrong number of output argument; 1 expected";
        error(78,msg);
    end
    
    // ** Check on b and a **
    if isempty(a) then
        a = 1;
    end
    if isempty(b) then
        b = 1;
    end
    
    // check on datatype
    if type(b)~=1 & type(b)~=8 then
        msg = "filternorm: Wrong type for argument #1 (b): Real or complex matrix expected";
        error(53,msg);
    end
    if type(a)~=1 & type(a)~=8 then
        msg = "filternorm: Wrong type for argument #2 (a): Real or complex matrix expected";
        error(53,msg);
    end
    
    // check on dimensions
    if size(b,1)==1 then
        b = b(:);
    end
    if size(a,1)==1 then
        a = a(:);
    end
    
    if size(b,2)~=size(a,2) then
        msg = "filternorm: Wrong size for arguments #1 (b) and #2(a): Same number of columns expected";
        error(60,msg);
    end
    
    // ** Parsing the remaining arguments **
    if length(varargin)==1 & ~isempty(varargin) then
        pnorm = varargin(1);
        if (pnorm~=2 & ~isinf(pnorm)) | length(pnorm)>1 then
            msg = "filternorm: Wrong value for argument #3 (pnorm): Must be 2 or inf";
            error(116,msg);
        end
        tol = 1e-8;
    elseif length(varargin)==2 then
        pnorm = varargin(1);
        if pnorm~=2 | length(pnorm)~=1 then
            msg = "filternorm: Wrong value for argument #3 (pnorm): Must be 2 when tolerance is used";
            error(116,msg);
        end
        tol = varargin(2);
        if tol<=0 | length(tol)~=1 then
            msg = "filternorm: Wrong value for argument #4 (tol): Must be a positive real scalar";
            error(116,msg);
        end
    else
        pnorm = 2;
        tol = 1e-8;
    end
    
    // ** Calculations **
    
    
    if size(a,1) = 1 then
        // the filter is FIR; impluse response is the filter coeffs; calc norm
        L = norm(b,pnorm)/a;
    else
        // the filter is IIR
        if isinf(pnorm) then
            // Calculate the frequency response and select the max magnitude
            h = computeFreqResponse(b,a,2048);
            L = max(abs(h),1);
        else
            // Checking for stability, as we wont be able to calc impulse response
            // within a given tolerance.
         
    
endfunction
    

function h = computeFreqResponse(b,a,n)
    // Computes the frequency response of a filter specified by b,a. n specifies
    // the discretization of the frequency space
    step = 2/n;
    w = %pi * (-1:step:1)';
    
    // Compute a matrix of all exp(jw) and its powers required
    max_pow = -max(size(b,1),size(a,1)) + 1;
    pow = 0:-max_pow;
    
    temp_mat = exp(w*max_pow);
    
    // Now evaluate numerator and denominator parts of the transfer function
    num = w(:,1:size(b,1))*b;
    den = w(:,1:size(a,1))*a;
    
    h = (num./den);

endfunction
