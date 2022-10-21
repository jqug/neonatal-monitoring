function out = celladd(in,c)

% CELLADD Add a constant to each numerical element of a cell array
%
% out = celladd(in,c)
%

for i=1:length(in)
  if isnumeric(in{i})
    out{i} = in{i} + c;
  else
    out{i} = in{i}
  end 
end
