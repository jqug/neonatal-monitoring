function p = factoriseposteriors(crossproduct,chains)

% FACTORISEPOSTERIORS  Given the number of internal states
% in each factor, sums the probabilities to give the overall
% probability that each factor is non-normal.
%
% p = factoriseposteriors(crossproduct,chains)
%

nfactors = length(chains);
chains = chains(nfactors:-1:1); % as though it were a number, least significant figure to the right
nsamples = size(crossproduct,1);
p = zeros(nsamples,nfactors);

for i_chain=1:nfactors
  normalindices = [];
  blocksize = prod(chains(i_chain+1:nfactors));
  offset = prod(chains(i_chain+1:nfactors))*(chains(i_chain)-1);
  blockrep = prod(chains(i_chain:nfactors));
  for i_block = 1:prod(chains(1:i_chain-1))
    normalindices = [normalindices ([1:blocksize] + offset + (i_block-1)*blockrep)];
  end
  p(:,nfactors-i_chain+1) = 1 - sum(crossproduct(:,normalindices),2);
end

