function p = pacf(x,maxlag)

% p = PACF(x,order)
%
% Calculates the partial autocorrelation function of
% univariate input data x, up to a given maximum order.

% Author: John Quinn, 2005

p = zeros(maxlag,1);

for i=1:1:maxlag
  [a e] = aryw(x,i);
  p(i) = a(end);
end

