function posteriors = fhmmexact(X,chains,means,covar,priors,...
             transitions,swapchannels,fulltrans,labels,plotinfo,forwardonly);

% FHMM_EXACT_INFERENCE Find exact marginal posteriors for a factorial hmm,
% given neonate input data. 
%
%   X            - input time series data in columns.
%   chains       - row vector containing the number of states in each chain.
%   means        - mean vectors of each state.
%   covar        - covariance of each state.
%   priors       - prior probability of each state.
%   transitions  - the probability of each possible state change
%                  within every chain. 
%   labels       - the names of each of the states, for display.
%   swapchannels - in case input data has a different channel ordering from
%                  means, covar and priors. (optional)
%   postlabels   - the indices and names of posterior channels, for display.
%                  (optional)
%
%   posteriors contains cross-product inference


%% initialisation.

T = size(X,1);
nchannels = size(X,2);
nstates = sum(chains);
pstates = prod(chains);
nchains = size(chains,2);

if exist('swapchannels') && length(swapchannels)>0
  X = X(:,swapchannels);
end

alpha = zeros(T,pstates);
beta = zeros(T,pstates);
gamma = zeros(T,pstates);
gammanorm = zeros(T,nstates);
scale = zeros(T,1);
logscale = zeros(T,1);
priors = reshape(priors,pstates,1);

showprogress=1;
showfactorisedplot = 1;
if ~exist('labels'); labels={}; end;
if ~exist('plotinfo'); plotinfo={}; end;
if isfield(plotinfo,'showinference'); showprogress = plotinfo.showinference; end;
S_factorised = zeros(T+1,length(chains));



indicator = zeros(pstates,nchains);
for i=1:nchains
  for j = 1:pstates
    indicator(j,i) = mod(fix((j-1)/prod(chains(1:i-1))),chains(i)) + 1;
  end
end

stateexpansion = zeros(pstates,nstates);
for i=1:pstates
  for j=1:nchains
    stateexpansion(i,state_index(j,0,chains) + indicator(i,j)) = 1;
  end
end

if exist('fulltrans') && ~isempty(fulltrans)
  pfull = fulltrans;
else
  pfull = ones(pstates,pstates);
  for i=1:pstates
    for j=1:pstates
      for k=1:nchains
        s_ij = transitions(state_index(k,0,chains)+indicator(i,k),...
          state_index(k,0,chains)+indicator(j,k));
        pfull(i,j) = pfull(i,j) * s_ij; 
      end
    end
  end
end

if showprogress
  if showfactorisedplot
    handles = animplot_init(X,length(chains),labels,plotinfo); 
  else
    handles = animplot_init(y,size(s_ij,1));
  end;
end

%% calculate emission probabilities 

bfull = zeros(T,pstates);
psum = zeros(T,1);


for i=1:pstates
    pi = priors(i);
    mu = means(i:pstates:pstates*nchannels);
    sigma = reshape(covar(i:pstates:pstates*nchannels^2),nchannels,nchannels);
    bfull(:,i) = loggauss(mu,sigma,X) + log(pi); 
end

for i=1:T
  logscale(i) = max(bfull(i,:));
  bfull(i,:) = bfull(i,:) - logscale(i);
end

bfull = exp(bfull);

psum = sum(bfull,2);
for i=1:pstates
    bfull(:,i) = bfull(:,i) ./ psum;
end

bfull = log(bfull+1e-10);

%% forward-backward recursions

alpha(1,:) = log(priors') + bfull(1,:);
logscale(1) = -max(alpha(1,:));
alpha(1,:) = alpha(1,:) + logscale(1);
alpha(1,:)=exp(alpha(1,:));
scale(1)=sum(alpha(1,:));
alpha(1,:)=alpha(1,:)/scale(1);
for i=2:T
  alpha(i,:)=log(alpha(i-1,:)*pfull') + bfull(i,:);
  logscale(i) = max(alpha(i,:));
  alpha(i,:) = alpha(i,:) - logscale(i);
  alpha(i,:) = exp(alpha(i,:));
  scale(i)=sum(alpha(i,:));
  alpha(i,:)=alpha(i,:)/scale(i);
  
  if showprogress
    if showfactorisedplot
      S_factorised(i-1,:) = factoriseposteriors(alpha(i-1,:),chains);
      animplot_update(handles,S_factorised,i); 
    else
      animplot_update(handles,alpha,i);
    end;
  end
end;

if forwardonly
%% filtering only - return the alphas
  posteriors = alpha;
else
%% do the backwards pass and calculate gammas
  lscale = log(scale);
  beta(T,:)=ones(1,pstates)/scale(T);
  for i=T-1:-1:1
    beta(i,:)= exp(log(beta(i+1,:))+bfull(i+1,:)-log(scale(i))-logscale(i)) * pfull;
  end;
  
  gamma=(alpha.*beta);
  sumgamma = sum(gamma,2);
  for i=1:pstates
    gamma(:,i) = gamma(:,i) ./ sumgamma;
  end
  
  %% normalise
  
  
  gammanorm = gamma * stateexpansion;
  for i=1:T
    for j=1:nchains
      indices = state_index(j,1,chains):sum(chains(1:j));
      gammanorm(i,indices) = gammanorm(i,indices)/sum(gammanorm(i,indices));
    end
  end
  
  posteriors = gammanorm;
end

function index = state_index(chain, state, chains)
% Get the index for an MK wide array of individual chain states.
index= sum(chains(1:chain-1))+state;
