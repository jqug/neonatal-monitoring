function [A,Q,H,R,d,mu] = hiddenar(x,p,verify,obsnoise)

% HIDDEN AR  Learn the parameters of a hidden AR process in state space
% form.
%
%  [A,Q,H,R,d,mu] = hiddenar(x,p,verify,obsnoise)
%  Where p is the model order, x is cell array of training data. If 
%  verify==1, display model fit indicators.
%  obsnoise, if defined, is the variance of the measurement noise.

if nargin<3
  verify=0;
end

if ~iscell(x); x = {x}; end;

calculatemean = 1;

if calculatemean
  mu = ones(p,1) * mean(cellconcat(x));
else
  mu = zeros(p,1);
end

if sum(abs(cellconcat(x)))==0
  A = zeros(p);
  Q = eye(p)*1e-6;
  H = zeros(1,p);
  R = 1e-6;
  d = zeros(p,1);
  %warning('Training data is all zeros');
  return
end

if ~exist('obsnoise')
  s_noisy = cellspectrum(x);
  s_noisy = s_noisy(:,1);
  tmp = sort(s_noisy);
  R_hat = tmp(ceil(length(tmp)/10));
else
  R_hat = obsnoise;
end


%R_hat = mean(s_noisy);
gamma = autocov(x,p);
gamma_norm = gamma/(cellvar(x)-R_hat);
R = toeplitz([1; gamma_norm(1:p-1)]');
a_hat = pinv(R)*gamma_norm;
e_hat = (cellvar(x)-R_hat) - (a_hat' * gamma);
[A,H,Q,R,d,x_0,P_0] = ar2statespace(a_hat,e_hat);
R = R_hat;
%% Better results if R raised significantly - more appropriate signal to noise ratio 
R = R * 200;
%Q = Q+eye(size(Q,1))*1e-6;

if verify
  kfdd(x,A,Q,H,R,d,zeros(size(d)));
end
