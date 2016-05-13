function [a,g] = lpc(x,varargin)

    // ** Check on number of arguments **
    [numOutArgs,numInArgs] = argn(0);
    
    if numInArgs<1 | numInArgs>2 then
        msg = "lpc: Wrong number of input argument; 1-2 expected";
        error(77,msg);
    end
    if numOutArgs<1 | numOutArgs>2 then
        msg = "lpc: Wrong number of output argument; 1-2 expected";
        error(78,msg);
    end
    
    // ** Parsing input arguments **
    // 1) check on x
    
    // check on dimensions
    if size(x,1)==1 | size(x,2)==1 then
        // x is a single signal
        x = x(:); // converting to column vector
    end
    if ndims(x)>2 then
        msg = "lpc: Wrong size for argument #1 (x): a vector or 2D matrix expected"
        error(60,msg);
    end
    
    // check on data type
    if type(x)==8 then
        // convert int to double
        x = double(x);
    elseif type(x)~=1 then
        msg = "lpc: Wrong type for argument #1 (x): Real or complex matrix expected";
        error(53,msg);
    end
    
    if length(varargin)==0 then
        p = size(x,1)-1;
    else
        p = varargin(1);
        // 2) check on p
        if length(p)~=1 then
            msg = "lpc: Wrong size for argument #2 (p): Scalar expected";
            error(60,msg);
        end
        
        if type(p)~=1 & type(p)~=8 then
            msg = "lpc: Wrong type for argument #2 (p): Real scalar expected";
            error(53,msg);
        end
        
        if ~isreal(p) then
            msg = "lpc: Wrong type for argument #2 (p): Real scalar expected";
            error(53,msg);
        end
    end
    
    num_signals = size(x,2);

    // ** Processing **
    R = zeros(p+1,num_signals); // autocorrelation matrix
    N = size(x,1);
    
    for i=1:p+1
        R(i,:) = sum(x(1:N-i+1,:).*conj(x(i:N,:)),1);
    end
    R = R/size(x,1); // normalizing

    [a,g] = ld_recursion(R);
    
    // filter coeffs should be real if input is real
    for signal_idx=1:num_signals
        if isreal(x(:,signal_idx)) then
            a(signal_idx,:) = real(a(signal_idx,:)); 
        end
    end
    
endfunction

function [a,e] = ld_recursion(R)
    // Solve for LP coefficients using Levinson-Derbin recursion
    //
    // Paramaters
    // R: double
    //      Autocorrelation matrix where column corresponds to autocorrelation 
    //      to be treated independently
    // a: double
    //      Matrix where rows denote filter cofficients of the corresponding 
    //      autocorrelation values
    // e: double
    //      Column vector denoting error variance for each filter computation
    
    
    p = size(R,1)-1;
    num_filters = size(R,2);
    
    
    // Initial filter (order 0)
    a = zeros(num_filters,p+1);
    a(:,1) = 1;
    e = abs(R(1,:)');
    
    // disp('R=');
    // disp(R);
    
    // Solving in a bottom-up fashion (low to high filter coeffs)
    for m=2:p+1
        k_m = -sum(a(:,m-1:-1:1).*R(2:m,:)',2)./e;
        
        // disp(k_m);
        a(:,1:m) = a(:,1:m) + repmat(k_m,1,m).*conj(a(:,m:-1:1));
        
        e = (1-abs(k_m).^2).*e;
    end
    
endfunction
    
    
