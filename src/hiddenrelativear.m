function [A,Q,H,R,d,mu] = hiddenrelativear(x,p_base,d_base,p_sig,d_sig,mavgwin)

% HIDDENRELATIVEAR  Learn parameters of a model which has an AR/ARIMA
%                   baseline and AR/ARIMA signal component.
%
% [A,Q,H,R,d,mu] = hiddenrelativear(x,p_base,d_base,p_sig,d_sig,mavgwin)
% 


damping_coeff = .9999;
signal_noise_amplification = 1;
baseline_noise_amplification = 1;
removemean = 1;
dstate = p_base + d_base + p_sig + d_sig; % dimension of state
mu = zeros(dstate,1);

if ~iscell(x)
  x = {x};
end

if sum(abs(cellconcat(x)))==0
  statedim = p_base + d_base + p_sig + d_sig;
  A = zeros(statedim);
  Q = eye(statedim)*1e-6;
  H = zeros(1,statedim);
  R = 1e-6;
  d = zeros(statedim,1);
  mu = zeros(statedim,1);
  %warning('Training data is all zeros');
  return
end

if removemean
  meansignal = mean(cellconcat(x));
  mu(1:(p_sig+d_sig+p_base+d_base)) = meansignal;
  x = celladd(x,-meansignal);
end

baseline = cell(size(x));
signal = cell(size(x));

% split each training instance into a low frequency baseline and high frequency residuals
for i_instance=1:length(x)
  tmp_smoothed = mavg(x{i_instance},mavgwin);
  tmp_smoothed = tmp_smoothed(round(mavgwin/2):end-round(mavgwin/2));
  baseline{i_instance} = tmp_smoothed;
  signal{i_instance} = x{i_instance}(round(mavgwin/2):end-round(mavgwin/2)) - tmp_smoothed;
end

% learn the mean of the training data
x_concat = cellconcat(x);
mu_alldata = sum(x_concat)/length(x_concat);

% learn the baseline model
[A1,Q1,H1,R1,d1] = hiddenarima(baseline,p_base,d_base,0,0); % no observation noise for baseline
a1 = A1(1,:);
if d_base>0
  a1 = a1 * damping_coeff;
end
e1 = Q1(1,1) * baseline_noise_amplification;

% learn the signal model
if d_sig==0
  sig_concat = cellconcat(signal);
  sig_mean = sum(sig_concat)/length(sig_concat);
  signal = celladd(signal,-sig_mean);
end
[A2,Q2,H2,R2,d2] = hiddenarima(signal,p_sig,d_sig,0);
a2 = A2(1,:);
if d_sig>0
  a2 = a2 * damping_coeff;
end
e2 = Q2(1,1) * signal_noise_amplification;

% combine the two models
[A,Q,H] = relativear2statespace(a2,a1,e2,e1);
R = R2; % observation noise was learnt from high freq residuals
d = zeros(size(A,1),1);
if size(mu,1)~=size(A,1)
  mu = repmat(mu(1),size(A,1),1);  
end

%mu = ones(size(A,1),1)*mu_alldata;


