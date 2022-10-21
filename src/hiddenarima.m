function [A,Q,H,R,d,mu] = hiddenarima(x,p,d_order,verify,obsnoise)

% HIDDEN AR  Learn the parameters of a hidden integrated AR process in
% in state space form.
%
%  [A,Q,H,R,d] = hiddenarima(x,p,d_order,verify,obsnoise)
%  Where p is the model order, x is training data, and
%  d is the order of differencing. If verify==1, display
%  model fitting indicators.

if ~exist('verify')
  verify=0;
end

if ~iscell(x); x = {x}; end;

for i_diff=1:d_order
  x = celldiff(x);
end

if ~exist('obsnoise')
  [A,Q,H,R,d,mu] = hiddenar(x,p,0);
else
  [A,Q,H,R,d,mu] = hiddenar(x,p,0,obsnoise);
end

for i_diff=1:d_order
  arima_coeffs = A(1,:);
  ar_coeffs = arima2ar(arima_coeffs);
  [A,H,Q,R_tmp,d,x_0,P_0] = ar2statespace(ar_coeffs,Q(1,1));
end
mu = repmat(mu(1),p+d_order,1);

if verify
  verify_kf(A,Q,H,R,d,zeros(size(d)),x);
end
