function [outcell, outindices] = zerodelimitedarraytocell(x)

% ZERODELIMITEDARRAYTOCELL
%
% splits a vector into a cell array, where each cell contains a
% contiguous sequence of non zero numbers from the input vector.
%
% eg. [1 2 0 0 0 3 4 0] --> {[1 2] [3 4]}
%
% if the array has more than one dimension, i.e. size(a,2)>1,
% then the cell segments will be the times when all channels
% have consecutive non-zero values.
%
% outcell = zerodelimitedarraytocell(x), where a is made up of 
% adjacent column vectors.
%

outcell = {};
ndims = size(x,2);
tempcells = {};
outindices = {};

if length(x) > size(x,1)
  warning('Expecting the input to be arranged in columns');
end

notallzeros = length(find(sum(x,1)==0))==0;

if notallzeros
  if ndims == 1 
    [outcell, outindices] = singlechanneltocell(x);
  else
    indicator = prod(x,2);
    indicator(find(indicator~=0)) = 1;
    x = x .* repmat(indicator,1,ndims); 
    for i=1:ndims
      [tempcells{i}, tempindices{i}] = singlechanneltocell(x(:,i));
    end
    for i=1:length(tempcells{1})
      outcell{i} = [];
      outindices{i} = [];
      for j=1:ndims
        outcell{i} = [outcell{i} tempcells{j}{i}];
        outindices{i} = [outindices{i} tempindices{j}{i}];
      end
    end
  end
end


function [c,indices] = singlechanneltocell(a)

a = reshape(a,length(a),1);
nonzero = find(a~=0);
diffed = diff(nonzero);
diffsmorethan1 = find(diffed>1);
segboundaries = [0; diffsmorethan1; length(nonzero)];
segmentindices = [segboundaries(1:end-1)+1 segboundaries(2:end)];

for i=1:size(segmentindices,1)
    c{i} = a(nonzero(segmentindices(i,1)):nonzero(segmentindices(i,2)));
    indices{i} = (nonzero(segmentindices(i,1)):nonzero(segmentindices(i,2)))';
end
