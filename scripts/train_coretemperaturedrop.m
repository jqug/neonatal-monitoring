%%%% Train temp probe disconnection %%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tcdisconnects = getdatabetweenintervals(data.preprocessed,intervals.CoreTempProbeDisconnect,constants.factors.tcdisconnection.obschannels,settings.train.babies);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Learn artifactual dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_d = A_normal;
H_d = zeros(size(H_normal));
Q_d = Q_normal;
R_d = R_normal;
mu_d = mu_normal; 

tc_xdims = settings.factors.tcdisconnection.xdims;
tc_ydims = []; 
for curr_channel = constants.factors.tcdisconnection.obschannels
  tc_ydims = [tc_ydims indexofobservedchannel(curr_channel,obschannels)];
end
tc_index = indexofobservedchannel(constants.cl.core_temp,obschannels);
it_index = indexofobservedchannel(constants.cl.incu_temp,obschannels);
tc_factor_index = indexofobservedchannel(constants.cl.core_temp, constants.factors.tcdisconnection.obschannels);
it_factor_index = indexofobservedchannel(constants.cl.incu_temp, constants.factors.tcdisconnection.obschannels);
tc_x_indices = xdims.obschannels{tc_index};
it_x_indices = xdims.obschannels{it_index}; 

% disconnection
for i_sample=1:length(tcdisconnects)
  tcdisconnect_zeromean{i_sample} = tcdisconnects{i_sample}(:,tc_factor_index) - tcdisconnects{i_sample}(:,it_factor_index);
end;
[tc_a tc_e] = aryw(tcdisconnect_zeromean,1);

%% train with incubator temp as baseline
A_d = A_normal;
A_d(tc_xdims,tc_xdims) = 0;
A_d(tc_xdims(1),:) = A_normal(it_x_indices(1),:);
A_d(tc_xdims(1),tc_xdims(1)) = tc_a;
A_d(tc_xdims(1),it_x_indices(1)) = A_d(tc_xdims(1),it_x_indices(1)) - tc_a;

Q_d = Q_normal;
Q_d(tc_xdims(1),tc_xdims(1)) = tc_e;
H_d = zeros(size(H_normal));
H_d(tc_index,tc_xdims(1)) = 1;
H_d(it_index,it_x_indices(1)) = 1;

Z_art = markovtransitionprobsfromintervals(intervals.CoreTempProbeDisconnect,settings.train.babies);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgl_factor = {{A_d} {H_d} {Q_d} {R_d} tc_xdims tc_ydims Z_art {d_normal} {mu_normal}};
