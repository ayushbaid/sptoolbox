function [f,g,zf] = latcfilt(varargin)
    // ************************************************************************
    // Parsing the arguments
    
    // TODO: change size(v)=size(k)+1
    // TODO: zi
    [numInArgs,numOutArgs] = argn(0);
    
    
    // **** checking number of input arguments ****
    if numInArgs<2 | numInArgs>6 then
        msg = "latcfilt: Wrong number of input argument; 1-6 expected";
        error(77,msg);
    end
    
    
    // **** parsing k ****
    k = varargin(1);
    
    if ~IsIntOrDouble(k,%T) then
        msg = "latcfilt: Wrong type for argument #1 (k); real or complex vector/matrix expected ";
        error(53,msg);
    end
    if isvector(k) then
        // convert to column vector
        k = k(:);
    end
    
    // **** Parsing the initial conditions (if present) ****
    stringIndex = [];
    for i=1:numInArgs
        stringIndex = [stringIndex (type(varargin(i))==10)];
    end
    stringIndex = find(stringIndex);
    
    if length(stringIndex)>2 then
        msg = "latcfilt: Wrong number of string arguments; atmost 1 expected (ic)";
        error(42,msg);
    end
    
    ICFlag = %F;
    if ~isempty(stringIndex) then
        // ignoring all other strings except the corr flag
        ICFlag = or(strcmpi(varargin(stringIndex),"ic")==0);
        // considering only 1st
    end
    zi = [];
    if ICFlag then
        // get the initial conditions
        try
            zi = varargin(stringIndex+1);
            if ~IsIntOrDouble(zi,%f) then
                msg = msprintf(gettext("latcfilt: Wrong type for argument #%d (zi); real or complex vector of length-k expected "));
                error(53,msg);
            end
            varargin(stringIndex+1) = [];
        catch
            msg = "latcfilt: incompatible input arguments; zi expected after ic flag";
            error(42,msg);
        end
    end
    
    numInArgs=length(varargin);
    
    // **** parsing the remaining arguments ****
    dim = [];
    x = [];
    v = [];
    isFIR = %T; // indicating whether the filter is FIR or IIR
    isAllPole = %F;
    if numInArgs==4 then
        v = varargin(2);
        x = varargin(3);
        dim = varargin(4);
        
        // k must be a vector
        if ~isvector(k) then
            msg = "latcfilt: Wrong type for argument #1 (k); Real or complex vector expected";
            error(53,msg);
        end
        k = k(:);
        
        if length(v)==1 then
            isAllPole = %T;
            if v~=1 then
                msg = "latcfilt: Wrong input argument #2; Scalar 1 or vector expected";
                error(36,msg);
            end
        elseif ~isvector(v) then
            msg = "latcfilt: Wrong type for argument #2 (v); Real or complex vector expected";
            error(53,msg);
        else
            // v and k must be vectors of the same length
            v = v(:);
            if size(v)~=size(k) then
               msg = "latcfilt: Wrong type for arguments #2 (v) and #1 (k); Vectors of the same length expected";
               error(53,msg); 
            end
        end
        isFIR = %F;
    elseif numInArgs==3 then
        temp = varargin(3);
       
        // k must be a vector
        if ~isvector(k) then
            msg = "latcfilt: Wrong type for argument #1 (k); Real or complex vector expected";
            error(53,msg);
        end
        k = k(:);
       
        if length(temp)==1 then
            // must be dim
            dim = temp;
            x = varargin(2);
        else
            v = varargin(2);
            x = temp;
           
            if length(v)==1 then
                isAllPole = %T;
                if v~=1 then
                    msg = "latcfilt: Wrong input argument #2; Scalar 1 or vector expected";
                    error(36,msg);
                end
            elseif ~isvector(v) then
                msg = "latcfilt: Wrong type for argument #2 (v); Real or complex vector expected";
                error(53,msg);
            else
                // v and k must be vectors of the same length
                v = v(:);
                if size(v)~=size(k) then
                   msg = "latcfilt: Wrong type for arguments #2 (v) and #1 (k); Vectors of the same length expected";
                   error(53,msg); 
                end
            end
            isFIR = %F;
        end 
    else
        x = varargin(2);
    end
    
    //checking correctness of x
    if ~IsIntOrDouble(x,%F) then
        error(53,"latcfilt: Wrong type for input argument x; Real or Complex Matrix expected");
    end
    
    // checking correctness of dim
    if isempty(dim) then
        dim = [];
    else ~IsIntOrDouble(dim,%T);
        error(53,"latcfilt: Wrong type for input argument dim; Natural number expected");
    end
    
    
    inpType = 0;
    if isvector(k) & isvector(x) then
        inpType = 1;
        x = x(:);
        resultSize = size(x);
        f = x;
    elseif isvector(k) then
        inpType = 2;
        k=k(:);
        resultSize = size(x);
        f = x;
    else
        inpType = 3;
        x = x(:);
        resultSize = [size(x,1),size(k,2)];
        f = repmat(x,1,resultSize(2));
    end
    g = f;
    // TODO: given allocation only for FIR case
    M = size(k,1);
    
    // TODO: initial conditions
    f1 = zeros(size(f,1)-1,size(f,2));
    g1 = f1;
    
    
    // compute lattice for FIR filters
    if isFIR then
        for i=1:M
            if inpType~=3 then
                f1 = f(2:$,:) + k(i).*g(1:$-1,:);
                g1 = k(i).*f(2:$,:) + g(1:$-1,:);
                g = [k(:,i)*f(1,:); g1];
            else
                for j=1:size(f,2)
                    f1(:,j) = f(2:$,j) + k(i,j).*g(1:$-1,j);
                    g1(:,j) = k(i,j).*f(2:$,j) + g(1:$-1,j);
                    g(:,j) = [k(i,j).*f(1,j); g1(:,j)];
                end 
            end    
            f(2:$,:) = f1;
        end
    else
        numCols = size(x,2);
        f = zeros(resultSize(1),resultSize(2));
        g = f;
        zf = zeros(1,numCols); // TODO: check
        
        for i=1:numCols
            [t1,t2,t3] = filterLatticeIIR(x(:,i),k,v);
            f(:,i) = t1;
            g(:,i) = t2;
            zf(:,i) = t3;
            // [f(:,i),g(:,i),zf(:,i)] = filterLatticeIIR(x(:,i),k,v);
        end
    end
            
        
    
endfunction

function [fN,gN,zf] = filterLatticeIIR(x,k,v)
    // disp("in IIR processing");
    // TODO: extend for matrix x/k
    N = size(k,1);
    L = size(x,1);
    
    fMat = zeros(N+1,L);  // each column is fk
    gMat = zeros(N+1,L);  // each column is gk
    
    zf = 0;
    
    f(N+1,:) = x;
    
    // Do separately for n=1
    n=1;
    for i=N-1:-1:0
        f(i+1,n) = f(i+2,n);
        g(i+2,n) = k(i+1)*f(i+1,n);
    end
    g(1,n) = f(1,n);
    
    for n=2:L
        for i=N-1:-1:0
            f(i+1,n) = f(i+2,n)-k(i+1)*g(i+1,n-1);
            g(i+2,n) = k(i+1)*f(i+1,n)+g(i+1,n-1);
        end
        g(1,n) = f(1,n);
    end
    if v==1 then
        // disp("no sum");
        fN = f(1,:)';
    else
        // vMat = repmat(v,1,L);
        fN = (v'*g)';
    end
    gN = g($,:)';
    
    
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
