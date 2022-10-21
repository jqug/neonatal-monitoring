function n = stateindex2chain(stateindex,chains)

% CHAININDEXFROMSTATE chain index array from integer state number.
%
% Note that chains is 1-indexed. The nth value contains
% the total number of settings for the nth factor.
%
% n = chainindexfromstate(stateindex,chains)  

n = zeros(1,length(chains));

residual = stateindex-1;

for i=length(chains):-1:1
  if residual>0
    divisor = prod(chains(1:i-1));
    ind = min(chains(i)-1,floor(residual/divisor)); 
    n(i) = ind;
    residual = residual - ind*divisor;
  end;  
end;

n = n+1;

