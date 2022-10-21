function gamma = autocov(x,maxlag)

% AUTOCOV(data,maxlag) returns the autocovariance of data, up to a
%   specified time lag. Assumes all segments have the same mean.
%   data can be a single column vector, or a cell array of column vectors.

if ~iscell(x); x = {x}; end
nsegments = length(x);
gamma = zeros(maxlag,1);
mu = mean(cellconcat(x));
for lag=1:maxlag
  normconst = 0;
  for segment=1:nsegments
    if ~isempty(x{segment})
      reshape(x,prod(size(x)),1);
      N = size(x{segment},1);
      if N>lag
        normconst = normconst + N;  
        gamma(lag) = gamma(lag) + ((x{segment}(lag+1:N)-mu)' * (x{segment}(1:N-lag)-mu));
      end
    end
  end
  gamma(lag) = gamma(lag)/(normconst-1);
end
