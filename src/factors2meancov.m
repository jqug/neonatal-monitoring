function [means,covar,priors,chains] = factors2meancov(factors)

% MEANCOV_FROM_FACTORS Generate arrays of means, covariances and
% priors from a list of individual factor parameters.
%
%   [means,covar,priors] = meancov_from_factors(factors)
%
%   Where factors is formatted as:
%
%   {{[normal mean] [normal variances]}
%
%    {[factor1,state1 mean    [factor1,state1 variance   [channels affected   [priors for
%      factor1,state2 mean]    factor1,state2 variance]        by factor 1]    states 1,2] }
%
%    { same for factor 2, etc }}


normalstate = factors{1};
normalmean = normalstate{1};
normalvar = normalstate{2};
nchannels = length(normalmean);

chains = [];
for i=2:length(factors)
  chains = [chains (1+size(factors{i}{1},1))];    
end

nstates = prod(chains);
covar = zeros(nchannels^2 * nstates,1);
means = zeros(nchannels * nstates,1);
priors = ones(nstates,1);

for i=1:nstates;
  chainindex = stateindex2chain(i,chains);

  % get the mean and variances for this state
  sigma = factors{1}{2};
  mu = factors{1}{1};
  for j=1:length(chains)
    if chainindex(j)<chains(j)
      factorsigma = factors{j+1}{2};
      factormu = factors{j+1}{1};
      sigma(1,factors{j+1}{3}) = factorsigma(chainindex(j),factors{j+1}{3});
      mu(1,factors{j+1}{3}) = factormu(chainindex(j),factors{j+1}{3});    
    end 
  end;

  % get the priors
  for j=1:length(chains)
    factorpi = factors{j+1}{4};
    if sum(factorpi)>1 
      warning(['Priors not normalised for factor ' num2str(j)]);
    end
    priors(i) = priors(i) * factorpi(chainindex(j));
  end
  
  % add them to the output
  Sigma = diag(sigma);
  means(i:nstates:nstates*nchannels) = mu;
  covar(i:nstates:nstates*nchannels^2) = reshape(Sigma,nchannels^2,1);
end;

