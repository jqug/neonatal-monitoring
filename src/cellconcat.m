function out = cellconcat(in)

% CELLCONCAT  Concatenate numerical cell elements and return an array
%
% Elements of cell should have the same number of columns.
%

out = [];

for i=1:length(in)
  if isnumeric(in{i})
    out = [out; in{i}];
  end
end 
