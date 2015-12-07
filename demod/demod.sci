function [x, x2] = demod(y, fc, fs, varargin)

    // checking the number of input arguments
    nargin = argn(2);
    if nargin==3 then
        // choosing 'am' as the method as nothing was passed
        method = 'am';
    elseif nargin==4 | nargin==5 then
        method = varargin(1);
    else
        error(msprintf(gettext("%s: Wrong number of input arguments: %d to %d expected.\n"), "atomsInstall", 3, 5));
    end

    // TODO: why check on fc?

    [r, c]  = size(y);

    if r*c==0 then
        // y is empty
        x = [];
        return
    end

    if r==1 then
        // convert y from row vector to column vector
        y = y(:);
        len = c;
    else
        len=r;
    end

    if strcmpi(method,'am')==0 | strcmpi(method,'amdsb-sc')==0 | ...
        strcmpi(method,'amdsb-tc')==0 | strcmpi(method,'amssb')==0 then
        t = (0:1/fs:((len-1)/fs))'; // sampling time instances for #samples = length
        t = t(:,ones(1,size(y,2))); // replicating the sampling time instances for each column

        x = y.*cos(2*%pi*fc*t);
        plot(x(1:100));
        // performing low-pass filtering using butterworth filter
        hz = iir(5, 'lp', 'butt', [fc/fs], []);
        
        // plotting - 
        // [hzm,fr]=frmag(hz,256);
        // plot2d(fr',hzm')

        // performing filtering for each column
        for i=1:size(y,2)
            x(:,i) = flts(x(:,i)', hz)';
        end

        if strcmpi(method,'amdsb-tc')==0 then
            // perform shifting if opt is passed
            if nargin == 5 then
                shift = varargin(2);
                x = x - shift;
            end
        end
    elseif strcmpi(method, 'fm')==0 then
        t = (0:1/fs:((len-1)/fs))';
        t = t(:,ones(1,size(y,2)));

        tempSignal = hilbert(y).*exp(-2*%pi*fc*t*%i);

        attenuation=1;
        if nargin == 5 then
            attenuation = varargin(2);
        end

        // instantenous frequnecy by calculating phase difference
        // boundary condition -> first derivative is zero
        x = (1/attenuation)*[zeros(1,size(tempSignal,2)); diff(unwrap(atan(imag(tempSignal),real(tempSignal))))];
    elseif strcmpi(method, 'pm')==0 then
        t = (0:1/fs:((len-1)/fs))';
        t = t(:,ones(1,size(y,2)));

        tempSignal = hilbert(y).*exp(-2*%pi*fc*t*%i);

        attenuation=1;
        if nargin == 5 then
            attenuation = varargin(2);
        end

        // instantenous frequnecy by calculating phase difference
        // boundary condition -> first derivative is zero
        x = (1/attenuation)*atan(imag(tempSignal),real(tempSignal));
    elseif strcmpi(method, 'pwm')==0 then
        // discretizing the input to 0 and 1 with 0.5 as threshold
        y = y>0.5;
        t = (0:1/fs:((len-1)/fs))';
        len = ceil( len * fc / fs);   // length of the output
        x = zeros(len,size(y,2));
        if nargin < 5 then
            opt = 'left';
        else
            opt = varargin(2);
        end

        // the interval for a sample is centered at that sample
        if strcmpi(opt, 'center')==0 then
            for i=1:len
                t_temp = t - (i-1)/fc;   // shifting the time axis to coincide with the sample
                block_indices =  t_temp>=(-1/(2*fc)) & t_temp<1/(2*fc); // generating indicator for the block at a sample
                // demodulate for each input y (i.e. each column)
                for j=1:size(y,2)
                    // to demodulate, sum all the values in the block
                    x(i,j1) = sum(y(block_indices,j))*fc/fs; // TODO: why *fc/fs
                end
            end 
        elseif strcmpi(opt, 'left')==0 then
            for i=1:len
                t_temp = t - (i-1)/fc;
                block_indices =  t_temp>=0 & t_temp<1/fc; // generating indicator for the block at a sample
                // demodulate for each input y (i.e. each column)
                for j=1:size(y,2)
                    x(i,j) = sum(y(block_indices,j))*fc/fs; // TODO: why *fc/fs
                end
            end
        else
            error('Invalid option: should be left of center');
        end 
    elseif strcmpi(method, 'ppm')==0 then
        // discretizing the input to 0 and 1 with 0.5 as threshold
        y = y>0.5;
        t = (0:1/fs:((len-1)/fs))';
        len = ceil( len * fc / fs);   // length of the output
        x = zeros(len,size(y,2));

        for i=1:len
            t_temp = t-(i-1)/fc; 
            // defining the block
            block_indices = find((t_temp>=0) & (t_temp<1/fc));
            // demodulate for each input y (i.e. each column)
            for j=1:size(y,2)
                // getting the non-zero entry location in the block
                nonzero_indices = y(block_indices,j)==1;

                // get the first non-zero entry in the block
                val = min(block_indices(nonzero_indices));
                x(i,j) = t_temp(val)*fc;
            end
        end
    elseif strcmpi(method, 'qam')==0 then
        t = (0:1/fs:((len-1)/fs))';
        t = t(:,ones(1,size(y,2)));
        x = y.*cos(2*%pi*fc*t);
        x2 = y.*sin(2*%pi*fc*t);

        // performing low-pass filtering using butterworth filter
        hz = iir(5, 'lp', 'butt', [fc/fs 0], [0 0]);

        for i = 1:size(y,2)
            x(:,i) = 2*flts(x(:,i)', hz)';
            x2(:,i) = 2*flts(x2(:,i)', hz)';
        end
        if (r==1) then   // convert x2 from a column to a row if necessary
            x2 = x2.';
        end
    
    else
        error("Incorrect modulation technique");
    end
    

    if (r==1) then   // convert x1 from a column to a row if necessary
        x = x.';
    end
endfunction
