function out = minmaxcolumn(in);

%  minmaxcolumn(a), where a is an NxM matrix, returns an Nx2 matrix
%  where the elements at (i,1) and (i,2) are the lowest and highest
%  values in row i of the input matrix respectively.

nrows = size(in,1);
out = zeros(nrows,2);

for i=1:nrows
  out(i,2) = max(in(i,:));
  if out(i,2)~=0
    out(i,1) = min(in(i,find(in(i,:))));
  else
    out(i,1) = 0;
  end
end
