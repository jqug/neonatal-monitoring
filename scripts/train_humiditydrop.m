%%% Train incubator opening dynamics %%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
openincu = getdatabetweenintervals(data.preprocessed,intervals.IncubatorOpen,obschannels,settings.train.babies);
%mu = 45;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Learn artifactual dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
incu_xdims = settings.factors.handling.xdims;
incu_ydims = []; 
for curr_channel = constants.factors.handling.obschannels
  incu_ydims = [incu_ydims indexofobservedchannel(curr_channel,obschannels)];
  incu_xdims = [incu_xdims xdims.obschannels{indexofobservedchannel(curr_channel,obschannels)}];
end

ih_index = indexofobservedchannel(constants.cl.incu_humidity,obschannels);
it_index = indexofobservedchannel(constants.cl.incu_temp,obschannels);
ih_factor_index = indexofobservedchannel(constants.cl.incu_humidity, constants.factors.handling.obschannels);
ih_x_indices = xdims.obschannels{ih_index};
if it_index>0
  it_x_indices = xdims.obschannels{it_index};
else
  it_x_indices = [];
end

%% assuming that the baseline humidity is normally 45% in the NICU, temp 30
%% degrees
mu_art = mu_normal;
mu_art(ih_x_indices) = 45;
mu_art(it_x_indices) = 30;

%[A,Q,H,R,d] = hiddenarima(cellpickchannel(openincu,ih_index),1,0,0);
[A_ih Q_ih] = aryw(celladd(cellpickchannel(openincu,ih_index),-mu_art(ih_index)),1);


%extrazeros = length(ih_x_indices) - size(A,1);
%A = blkdiag(A,zeros(extrazeros));
%Q = blkdiag(Q,zeros(extrazeros));
%H = [H zeros(size(H,1),extrazeros)];

A_art = A_normal;
%A_art(it_x_indices,it_x_indices) = A_ih;
%A_art(incu_xdims,:) = 0;
A_art(ih_x_indices,ih_x_indices) = A_ih;
Q_art = Q_normal* 1.01; %*100;   %*20000
Q_art(ih_x_indices,ih_x_indices) = Q_ih;
H_art = H_normal;
%H_art = zeros(size(H_normal));
d_art = d_normal;
%d_art(it_x_indices(1)) = -1/100;
% d_art(1) = -2/100;
%H_art(ih_index,incu_xdims(1)) = 1;
R_art = R_normal;% - covarscaling;% + 9;
%R_art = R_art - Q_art(ih_x_indices,ih_x_indices) + Q_normal(ih_x_indices,ih_x_indices);
%mu_art = mu_normal;
%R_art(incu_ydims,incu_ydims) = 1;
%mu_art = mu_normal;
Z_art = markovtransitionprobsfromintervals(intervals.IncubatorOpen,settings.train.babies);
%Z_art = Z_art + .1;
Z_art(:,2) = Z_art(:,2)+.5;
Z_art = Z_art./repmat(sum(Z_art,2),1,size(Z_art,1));
%Z_art = ones(2)/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgl_factor = {{A_art} {H_art} {Q_art} {R_art} incu_xdims incu_ydims Z_art {d_art} {mu_art}};

