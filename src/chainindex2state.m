function n = stateindexfromchain(longstateindex,chains)

% STATEINDEXFROMCHAIN Integer state index from a chain reference array.
%
% n = stateindexfromchain(longstateindex,chains)  

ind = longstateindex - 1;
chain = chains;

n = 1;
for i=1:length(chain)
  n = n + ind(i)*prod(chain(1:i-1));
end
