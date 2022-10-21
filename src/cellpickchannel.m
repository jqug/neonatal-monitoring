function out = cellpickchannel(c,indices);

% cellpickchannel(c,index), where c is a cell array containing NxM
% matrices and indices is a set of column numbers, is a new cell
% array where only the specified columns are retained.
%

out = cell(length(c),1);
for i=1:length(c);
  out{i} = c{i}(:,indices);
end
