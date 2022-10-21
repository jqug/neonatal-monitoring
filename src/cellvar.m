function v = cellvar(x)

% CELLVAR(x) returns the variance of the combined elements 
% of cell array x.

v = var(cellconcat(x));
