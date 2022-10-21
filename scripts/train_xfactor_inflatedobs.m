%%%%%%%%%%% Train X-factor %%%%%%%%%%%%%

%% train by inflating the observation noise covariance rather than system noise.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xi = settings.train.xfactor.initial_xi;

A_art = A_normal; 
Q_art = Q_normal; 
H_art = H_normal; 
R_art = R_normal * xi;
d_art = d_normal; 
mu_art = mu_normal;

Z_art = markovtransitionprobsfromintervals(intervals.Abnormal,settings.train.babies);

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

