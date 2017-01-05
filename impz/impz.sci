// This code is adapted from the impz function in signal toolbox for octave

// The original code has the following license
// ## Copyright (C) 1999 Paul Kienzle <pkienzle@users.sf.net>
// ##
// ## This program is free software; you can redistribute it and/or modify it under
// ## the terms of the GNU General Public License as published by the Free Software
// ## Foundation; either version 3 of the License, or (at your option) any later
// ## version.
// ##
// ## This program is distributed in the hope that it will be useful, but WITHOUT
// ## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// ## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// ## details.
// ##
// ## You should have received a copy of the GNU General Public License along with
// ## this program; if not, see <http://www.gnu.org/licenses/>.


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
