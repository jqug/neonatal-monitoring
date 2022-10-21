function out = convertdiscontinuities(in,specialzeros)

% CONVERTDISCONTINUITIES
%
%   Convert a univariate time series which has
%   discontinuities caused by quantisation. The
%   new time series is comprised of linear segments
%   which join at the centre of each discontinuity.
%
%   If size(y,2)>1 then each column will be processed
%   individually.
%
%   out = convertdiscontinuities(in,[specialzeros=1])
%
%   if specialzeros==1, then consecutive sequences of
%   non-zero values will be processed independently 
%   for each column. 
%

if nargin<2
  specialzeros = 1;
end

ndims = size(in,2);
out = zeros(size(in));
for i=1:ndims
  out(:,i) = splitandconvertsinglechannel(in(:,i),specialzeros);
end

function x2 = splitandconvertsinglechannel(y2,spz)

if spz
  nonzeroindices = find(y2~=0);
  segments = zerodelimitedarraytocell(y2);
  for ind_segment=1:length(segments)
    convertedsegments{ind_segment} = convertsinglechannel(segments{ind_segment});
    if (length(convertedsegments{ind_segment})~=length(segments{ind_segment}))
      keyboard
    end
  end
  concatsegments = cellconcat(convertedsegments);
  y2(nonzeroindices) = concatsegments;
  x2 = y2;
else
  x2 = convertsinglechannel(y2);
end

function x = convertsinglechannel(y)

if size(y,1)>1
  discs = find(diff(y));
  discs = [discs+1; length(y)];
  x = [y(1)];
  
  for i = 1:length(discs)
    segment_length = discs(i) - length(x) - 1;
    segment = [1:segment_length]' / segment_length;
    segment = segment * ((y(discs(i))+y(max(1,discs(i)-1)))/2-x(end)) + x(end);
    x = [x; segment];
  end
  x = [x;x(end)];
else
  x = y;
end

