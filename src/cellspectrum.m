function s = cellspectrum(x,windowsize)

% CELLSPECTRUM(x,windowsize) returns the estimated power spectrum of the
% combined elements of the cell array x. The spectrum of each segment is
% calculated, then the spectra are combined with a weighted average.
%
% If windowsize is not specified, it defaults to 256 or the largest power
% of two which is less than the size of the smallest segment, whichever is
% the least.

nsegments = length(x);
defaultwindowsize = 256;
segmentlengths = zeros(nsegments,1);
for segment = 1:nsegments
   segmentlengths(segment) = length(x{segment});
end 
if nargin<2
  minsize = min(segmentlengths);
  if minsize>defaultwindowsize
    windowsize = defaultwindowsize;
  else
    windowsize = 2^floor(log2(minsize));
  end
end
spectra = zeros((windowsize/2)+1,nsegments);
for segment=1:nsegments
  tmpspec = spectrum(x{segment},windowsize);
  spectra(:,segment) = tmpspec(:,1) * segmentlengths(segment);
end
s = sum(spectra,2)/sum(segmentlengths);
