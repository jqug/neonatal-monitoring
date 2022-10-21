function v = reshape2vector(A)

% RESHAPE2VECTOR  Reshape an arbitrary dimensioned multidimensional array
%                 to a dx1 vector.
%
% v = reshape2vector(A)

numelements = prod(size(A));
v = reshape(A,numelements,1);

