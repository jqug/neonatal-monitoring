function [a,e] = aryw(x,p)

% [a,e] = ARYW(x,p)
%
% Fits an autoregressive process of order p to single or multiple
% training examples, using the Yule-Walker equations. The values
% returned for a given p are the optimal fit to the equation:
%
% x_t = a_1.x_{t-1} + ... + a_p.x{t-p} + epsilon_t
%
% where Var(epsilon) = e.
%
% ARGUMENTS
%  x : vector containing univariate data sequence, 
%      or cell array of training segments
%  p : order of fitted AR process
% RETURN VALUES
%  a : AR coefficients
%  e : noise variance

% Author: John Quinn 2005

if ~iscell(x); x = {x}; end
nsegments = length(x);
gamma = zeros(p,1); % autocorrelation, gamma_1 ... gamma_p
gamma_zero = 0;
mu = 0; % assume zero mean

% find the sample autocovariances 

for i=1:p
  for j=1:nsegments
    if ~isempty(x{j})

      %x{j} = x{j} - mean(x{j});

      for k=1:length(x{j})-i;
        gamma(i) = gamma(i) + (x{j}(k)-mu)*(x{j}(k+i)-mu);
      end
    end
  end
end

for i=1:nsegments
  if ~isempty(x{i})
    gamma_zero = gamma_zero + (x{i}-mu)'*(x{i}-mu);
  end
end
gamma = gamma/gamma_zero;

% solve Yule-Walker equations

R = toeplitz([1; gamma(1:p-1)]');
a = pinv(R)*gamma;

% calculate noise variance

residuals = [];

for i=1:nsegments
  if ~isempty(x{i})
    pred = zeros(length(x{i}),1);
    for j=p+1:length(x{i})
      pred(j) = a' * x{i}(j-1:-1:j-p);
    end
    residuals = [residuals; x{i}(p+1:end) - pred(p+1:end)];
  end
end

e = var(residuals);

