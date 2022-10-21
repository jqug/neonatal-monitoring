%%%%%%%%% Train blood sample %%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bloodsamples = getdatabetweenintervals(data.preprocessed,intervals.BloodSample,obschannels,settings.train.babies);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Learn artifactual dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phys_xdims = [];
for curr_channel = constants.factors.bloodsample.obschannels
  phys_xdims = [phys_xdims xdims.obschannels{indexofobservedchannel(curr_channel,obschannels)}];
end
phys_ydims = [];
for curr_channel = constants.factors.bloodsample.obschannels
  phys_ydims = [phys_ydims indexofobservedchannel(curr_channel,obschannels)];
end

bs_index = indexofobservedchannel(constants.cl.systolic_blood_pressure,obschannels);
bd_index = indexofobservedchannel(constants.cl.diastolic_blood_pressure,obschannels);
bs_hidden_index = xdims.obschannels(bs_index);
concat_bloodsamples = cellconcat(bloodsamples);
art_drift = mean(diff(concat_bloodsamples(:,bs_index)));
art_drift_var = var(diff(concat_bloodsamples(:,bs_index)));
bs_factor_index = indexofobservedchannel(constants.cl.systolic_blood_pressure,constants.factors.bloodsample.obschannels);
bd_factor_index = indexofobservedchannel(constants.cl.diastolic_blood_pressure,constants.factors.bloodsample.obschannels);

A_art = A_normal;
A_art(settings.factors.bloodsample.xdims,:) = 0;
Q_art = Q_normal;
H_art = H_normal;
H_art(phys_ydims,phys_xdims) = 0;
H_art(settings.factors.bloodsample.ydims(bs_factor_index),settings.factors.bloodsample.xdims(1)) = 1;
H_art(settings.factors.bloodsample.ydims(bd_factor_index),settings.factors.bloodsample.xdims(1)) = 1;
d_art = d_normal;
mu_art = mu_normal;
R_art = R_normal;

if 0
A_art(settings.factors.bloodsample.xdims(1),settings.factors.bloodsample.xdims(1)) = 1;
Q_art(settings.factors.bloodsample.xdims(1),settings.factors.bloodsample.xdims(1)) = art_drift_var;
d_art(settings.factors.bloodsample.xdims(1)) = art_drift;

%H_art(settings.factors.bloodsample.ydims(bs_factor_index),settings.factors.bloodsample.xdims(1)) = 1;
%H_art(settings.factors.bloodsample.ydims(bd_factor_index),settings.factors.bloodsample.xdims(1)) = 1;
% observation noise models the discrepancy in BS and BD during artifactual ramp
%R_art(bs_index,bs_index) = var(concat_bloodsamples(:,bs_index)-concat_bloodsamples(:,bd_index));
else
A_art(settings.factors.bloodsample.xdims(1:2),settings.factors.bloodsample.xdims(1:2)) = [1 1;0 1];
Q_art(settings.factors.bloodsample.xdims(1:2),settings.factors.bloodsample.xdims(1:2)) = diag([10e-6 4e-6]);
%Q_art(settings.factors.bloodsample.xdims(1:2),settings.factors.bloodsample.xdims(1:2)) = diag([art_drift_var 4e-6]);

%H_art(settings.factors.bloodsample.ydims(bd_factor_index),settings.factors.bloodsample.xdims(1)) = 1;
%H_art(settings.factors.bloodsample.ydims(bs_factor_index),settings.factors.bloodsample.xdims(1)) = 1;

d_art(settings.factors.bloodsample.xdims(1)) = art_drift;
mu_art(settings.factors.bloodsample.xdims(1)) = mu_normal(bs_hidden_index{1}(1));
%mu_art(settings.factors.bloodsample.xdims(1:2)) = [30 0]'; % hand-picked starting point for blood samples
%R_art(bs_index,bs_index) = var(concat_bloodsamples(:,bs_index)-concat_bloodsamples(:,bd_index));
end


Z_art = markovtransitionprobsfromintervals(intervals.BloodSample,settings.train.babies);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgl_factor = {{A_art} {H_art} {Q_art} {R_art} settings.factors.bloodsample.xdims phys_ydims Z_art {d_art} {mu_art}};
