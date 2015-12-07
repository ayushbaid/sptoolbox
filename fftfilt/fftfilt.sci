function y = fftfilt(b, x, varargin)
    // This function performs FFT-based FIR filtering using overlap-add method
    // Calling sequence
    // y = fftfilt(b,x)
    // y = fftfilt(b,x,n)   
    // y = fftfilt(d,x)
    // y = fftfilt(d,x,n)
    // Parameters
    // x: data vector
    // b: filter coefficients vector
    // n: used to determine the length of the fft
    // d: digitalFilter object
    // Description
    // y = fftfilt(b,x) filters the data in vector x with the filter described by coefficient vector b. It returns the data vector y.
    // y = fftfilt(b,x,n) uses n to determine the length of the FFT.
    // y = fftfilt(d,x) filters the data in vector x with a digitalFilter object, d.
    // y = fftfilt(d,x,n) uses n to determine the length of the FFT.
    // Authors
    // Ayush


    // Not implementing gpuArray based function

    // TODO: add multicolumn support


    [lhs, rhs] = argn(0);

    // performing input arguments number check
    if rhs==3 then
        if length(varargin)>1 then
            error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), "atomsInstall", 1, 2));
        end,
        n = varargin(1);
    elseif rhs~=2 then
        error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), "atomsInstall", 1, 2));
    end

    // performing input arguments type check
    // TODO:

    // check if input is a column vector; else convert it into column
    m = size(x,1);
    if m==1 then
        x = x(:);
    end

    // getting the length of data vector x
    nx = size(x,1);


    // TODO: What is this?
    if min(size(b))>1 then
        if ((size(b,2)~=size(x,2)) & (size(x,2)>1)) then
            error(message('signal:fftfilt:InvalidDimensions'))
        end,
    else
        b = b(:);   // make input a column
    end

    nb = size(b,1);

    if rhs==2 then // the param n was not passed
        // figure out the nfft (length of the fft) and L (length of fft inp block)to be used
        if (nb>=nx | nb>2^20) then 
            // take a single fft
            nfft = 2^nextpow2(nb+nx-1);
        else
            // estimated flops for the fft operation (2.5nlog n for n in powers of 2 till 20)
            fftflops = [5, 20, 60, 160, 400, 960, 2240, 5120, 11520, 25600, 56320, 122880, 266240, 573440, 1228800, 2621440, 5570560, 11796480, 24903680, 52428800];
            n = 2.^(1:20); 
            candidateSet = find(n>(nb-1));    // all candidates for nfft must be > (nb-1)
            n  = n(candidateSet);
            fftflops = fftflops(candidateSet);

            // minimize (number of blocks)*(number of flops per fft)
            L = n - (nb - 1);
            numOfBlocks = ceil(nx./L);
            [dum,ind] = min( numOfBlocks .* fftflops ); // 
            nfft = n(ind);
            L = L(ind);

        end,
    else  // nfft is given
        // TODO: Cast to enforce precision rules
        // nfft = signal.internal.sigcasttofloat(nfft,'double','fftfilt','N','allownumeric');
        if nfft < nb then
            nfft = nb;
        end,
        nfft = 2.^(ceil(log(nfft)/log(2))); // forcing nfft to a power of 2 for speed
        L = nfft - nb + 1;
    end

    // performing fft on b

    if nb<nfft then
        // perform padding
        temp = zeros(nfft-nb,1);
        b = [b; temp];
    end
    B = fft(b);
    
    y=zeros(size(x,1),size(x,2));

    blockStartIndex = 1;
    while blockStartIndex <= nx,
        blockEndIndex = min(blockStartIndex+L-1, nx);

        if blockEndIndex==blockStartIndex then
            // just a scalar in the block
            X = x(blockStartIndex(ones(nfft,1)),:);
        else
            block = x(blockStartIndex:blockEndIndex);
            // performing padding
            temp = nfft-(blockEndIndex-blockStartIndex)-1;
            if temp>0 then
                pad = zeros(temp,1);
                block = [block; pad];   
            end,

            X = fft(block);
        end,
        Y = ifft(X.*B);

        yEndIndex = min(nx, blockStartIndex+nfft-1);

        y(blockStartIndex:yEndIndex,:) = y(blockStartIndex:yEndIndex,:) + Y(1:(yEndIndex-blockStartIndex+1),:);

        blockStartIndex = blockStartIndex+L;
    end

    if ~(or(imag(b(:))) | or(imag(x(:)))) then
        y = real(y);
    end

    if ((m == 1) & (size(y,2) == 1)) then
        y = y(:).';    // turn column back into a row
    end

endfunction













