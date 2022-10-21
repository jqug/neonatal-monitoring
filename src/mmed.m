function b = mmed(x,window,resolution)

% b = mmed(x,window)
%
% x : vector of data
% resolution : calculate a median for this number of data
%   points at a time, and allocate the same result to each
%   point. increases execution time but a value > 1 is not
%   suitable if the result is to be differenced. [default: 1]
% window size should be even [default: 250]


if nargin == 1
    window = 250;
end

if nargin < 3
  resolution =1;
end

% make sure it's even
window = 2*round(window/2);


b = zeros(length(x),1);
overallmedian = median(x(find(x)));

if isempty(overallmedian)
    overallmedian = 0;
end
if (size(x,1)>window) && (size(x,1)>resolution)
  x(find(x==0)) = overallmedian;
  
  b(1:window/2) = median(x(1:window));
  b(end-window:end) = median(x(end-window:end));
  
  for t=(window/2)+1:resolution:length(x)-window/2-resolution
        b(t:t+resolution) = median(x(t-window/2:t+window/2+resolution)) ;   
  end
else
  b = ones(size(x))*overallmedian;  
end
