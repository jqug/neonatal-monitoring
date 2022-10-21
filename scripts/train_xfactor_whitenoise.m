%%%%%%%%%%% Train X-factor %%%%%%%%%%%%%

%% use white noise process, i.e. there is just a mean and an observation variance.
 
% dynamics have the same dimensions as normal model
A_art = A_normal*0; 
Q_art = Q_normal*0; 
H_art = H_normal*0; 
R_art = R_normal*0;
d_art = d_normal*0; 
mu_art = mu_normal*0;

% x-factor training is based on the normal model for current baby
normaldata = getdatabetweenintervals(data.preprocessed,intervals.Normal,obschannels,i_baby);
alltrainingdata = cellconcat(normaldata);

for i_currchannel = 1:length(obschannels)
  % mean of this observed channel
  mu_art(xdims.obschannels{i_currchannel}(1)) = mean(alltrainingdata(:,i_currchannel));

  % find the covariance
  R_art(i_currchannel,i_currchannel) = var(alltrainingdata(:,i_currchannel));

  % X-factor has inflated covariance
  R_art = R_art * settings.train.xfactor.initial_xi;
end

% make Q non-singular for numerical stability
Q_art = eye(size(Q_art,1))*1e-6;

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

