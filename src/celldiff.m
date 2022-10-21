function d = celldiff(c)

% CELLDIFF  Difference each element of a cell array
%

for i = 1:length(c)
    d{i} = diff(c{i});    
end
