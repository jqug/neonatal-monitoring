function out = celltranspose(in)

% CELLTRANSPOSE  Transpose every numerical element in a cell array.
%

out = cell(length(in),1);
for i = 1:length(in)
  if isnumeric(in{i})
    out{i} = in{i}';
  else
    out{i} = in{i};
  end
end

