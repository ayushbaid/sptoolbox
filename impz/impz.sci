function [h, t] = impz(b, a, n, fs)

	numOutArgs,numInArgs] = argn(0);
    
    // ** Checking number of arguments
    
    if numInArgs<1 | numInArgs>4 then
        msg = "impz: Wrong number of input argument; 2-4 expected";
        error(77,msg);
    end
    
    if numOutArgs~=2 then
        msg = "impz: Wrong number of output argument; 2 expected";
        error(78,msg);
    end


    if isempty(n) && length(a)>1 then
    	n = impzlength(b,a);
	elseif isempty(n)
    	n =	length(b);
  	end

  	if length(a) == 1 then
	    h = fftfilt(b/a, [1, zeros(1,n-1)]);
  	else
	    h = filter(b, a, [1, zeros(1,n-1)]);
  	end

  	t = [0:n-1]/fs;

endfunction
