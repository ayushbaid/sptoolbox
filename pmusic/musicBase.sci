// Date of creation: 19 Dec, 2015
function [outputData,msg] = musicBase(inputData)
    // Implements the core of the MUSIC algorithm
    // Used by pmusic and rootmusic algorithm
    
    // TODO: complete docs
    
    msg = "";
    outputData = struct();
    
    [eigenvects,eigenvals, msg] = computeEig(inputData.x, inputData.isCorrFlag, ...
            inputData.windowLength, inputData.noverlap, inputData.windowVector);
            
    if length(msg)~=0 then
        return
    end
    
    pEffective = determineSignalSpace(inputData.p, eigenvals);
    
    if length(msg)~=0 then
        return
    end
    
    // Separating the eigenvects into signal and noise subspace
    signalEigenvects = eigenvects(:,1:pEffective);
    noiseEigenvects = eigenvects(:,pEffective+1:$);
    
    outputData.signalEigenvects = signalEigenvects;
    outputData.noiseEigenvects = noiseEigenvects;
    outputData.eigenvals = eigenvals;
    outputData.pEffective = pEffective;
endfunction


function [eigenvects,eigenvals,msg] = ...
    computeEig(x,isCorrFlag, windowLength, noverlap, window)
    // Computes the eigenvalues for the correlation matrix
    // If x is a correlation matrix, which is specified using the isCorrFlag, 
    // spec() is used for eigenvalue decomposition.
    // Otherwise, SVD is used for a proper restructure of x 
    // (i.e windowed version)
    
    // determine if input is a matrix
    xIsMatrix = ~or(size(x)==1);
    
    if xIsMatrix & isCorrFlag then
        // TODO: check the order of eigenvalues
        [al,be,eigenvects] = spec((R+R')/2); // ensuring hermitian property
        d = al./be;
        // sorting in decreasing order
        eigenvals = gsort(d);
        eigenvals = diag(d);
        
        // rearragning in decreasing order of eigenvalues
    else
        if xIsMatrix then
            // TODO: check for dimenion constraints
        else
            // x is vector
            // TODO: undestand the first condition in the reference code
            Lx = length(x);
            if Lx<=windowLength then
                msg = "Incorrrect value for window length; must be smaller than the signal length";
                return
            end
            x = createBufferMatrix(x, windowLength, noverlap);
            // scaling so as to get the correct value of R
            x = x/sqrt(Lx-windowLength);
        end
        
        // **applying window to each row of the data matrix
        // replicating window along the rows
        window = repmat(window',size(x,1),1);
        x = x.*window;
        
    end
    
    // computing eignevals and eigenvectors of R using SVD of x
    [temp,S,eigenvects] = svd(x);
    eigenvals = diag(sqrt(S));
    
    
    
endfunction


function [xMat,msg] = createBufferMatrix(x,windowLength,noverlap)
    // creates a matrix where each row represents a section which has to be 
    // windowed
    //
    // Input Arguments
    // x - input signal as a column vector
    // windowLength
    // noverlap
    //
    // will perform task similar to that performed by MATLAB's 
    // buffer(x,windowLength,noverlap)
    xMat = [];
    if ndims(x)~=1 then
        msg = "createBufferMatrix: x should be a vector";
        return
    end
    
    if size(x,1)~=1 then
        // covert to row vector
        x = x';
    end
    
    L = length(x);
    temp = windowLength - noverlap;
    numOfSections = ceil(L/temp);
    
    // performing zero padding of x
    zeroPadLength = numOfSection*temp - L;
    zeroPad = zeros(zeroPadLength,1);
    x = [x, zeroPad];
    
    xMat = zeros(windowLength, numOfSections);
    
    for i=1:numOfSections
        xMat(1:temp,i) = x(1+(i-1)*temp:i*temp);
        xMat(temp+1:windowLength,i) = x(1+i*temp:1+i*temp+noverlap);
    end
    
endfunction

function pEffective = determineSignalSpace(p, eigenvals)
    // Determines the effective dimension of the signal subspace
    
    // Inputs:
    //      p:  p(1) - signal subspace dimension
    //          p(2) (optional) - desired threshold
    //      eigenvals: vector conatining eigenvalues of the correlation
    //                 matrix in descreasing order
    // Output:
    //      pEffective - the effective dimension of the signal subspace. If 
    //                   a threshold is given as p(2), the signal subspace will
    //                   be equal to the number of eigenvalues greater than the 
    //                   threshold times the smallest eigenvalue. Also, 
    //                   pEffective<=p(1). So, minimum of the two values is 
    //                   considered. If the threshold criteria results in an 
    //                   empty signal subspace, we take pEffective = p(1).
    //
    disp(length(p));
    if length(p)==2 then
        threshold = p(2)*eigenvals($);
        signalIndices = find(eigenvals>threshold);
        
        if ~isempty(signalIndex) then
            pEffective = min(p(1), length(signalIndices));
        else
            // dont change p
            pEffective = p(1);
        end
    else
        pEffective = p;
    end
endfunction
