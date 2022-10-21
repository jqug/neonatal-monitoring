function m = meannum(x)

% MEANNUM  Find the mean of a vector, disregarding any NaN values.
%

if any(x)
  nanindices = isnan(x);
  nvalues = length(x)-sum(nanindices);
  x(nanindices)=0;
  m = sum(x)/nvalues;
else
  m = NaN;
end
