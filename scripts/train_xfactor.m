%%%%%%%%%%% Train X-factor %%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xi = settings.train.xfactor.initial_xi;

A_art = A_normal; 
Q_art = Q_normal * xi; 

%% don't inflate noise on environmental measurement channels
environmentalchannels = [indexofobservedchannel(constants.cl.incu_humidity,obschannels) indexofobservedchannel(constants.cl.incu_temp,obschannels)];
if any(environmentalchannels)
  for ienvchannel=environmentalchannels
    envxdims = xdims.obschannels{ienvchannel};
    Q_art(envxdims,envxdims) = Q_normal(envxdims,envxdims);
  end
end

H_art = H_normal; 
R_art = R_normal;
d_art = d_normal; 
mu_art = mu_normal;

Z_art = markovtransitionprobsfromintervals(intervals.Abnormal,settings.train.babies);
%Z_art(:,2) = Z_art + .2; %Z_art(:,2)+.1;
%Z_art = Z_art + .2; %Z_art(:,2)+.1;
%Z_art = Z_art./repmat(sum(Z_art,2),1,size(Z_art,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Combine factor parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phys_xdims = [];
for curr_channel = constants.factors.x.obschannels
  phys_xdims = [phys_xdims xdims.obschannels{indexofobservedchannel(curr_channel,obschannels)}];
end
phys_ydims = [];
for curr_channel = constants.factors.x.obschannels
  phys_ydims = [phys_ydims indexofobservedchannel(curr_channel,obschannels)];
end

sgl_factor = {{A_art} {H_art} {Q_art} {R_art} 1:dim_x 1:dim_y Z_art {d_art} {mu_art}};

