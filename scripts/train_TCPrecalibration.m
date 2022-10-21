%%%% Train TCP probe recalibration %%%%%


tcp_xdims = settings.factors.tcprecal.xdims;
tcp_ydims = []; 
for curr_channel = constants.factors.tcprecal.obschannels
  tcp_ydims = [tcp_ydims indexofobservedchannel(curr_channel,obschannels)];
end

ox_index = indexofobservedchannel(constants.cl.trans_O2,obschannels);
co_index = indexofobservedchannel(constants.cl.trans_CO2,obschannels);
ox_factor_index = indexofobservedchannel(constants.cl.trans_O2, constants.factors.tcprecal.obschannels);
co_factor_index = indexofobservedchannel(constants.cl.trans_CO2, constants.factors.tcprecal.obschannels);
ox_x_indices = xdims.obschannels{ox_index};
co_x_indices = xdims.obschannels{co_index}; 

A_1 = A_normal;
Q_1 = Q_normal;
R_1 = R_normal;
mu_1 = mu_normal;


%%%% First stage: high O2, low CO2
A_1 = A_normal;
A_1(tcp_xdims,tcp_xdims) = 0;
mu_1 = mu_normal;
mu_1(tcp_xdims(1)) = 200;
mu_1(tcp_xdims(2)) = 50;
Q_1 = Q_normal + eye(size(Q_normal,1))*1e-6;
R_1 = R_normal*3;
H_1 = zeros(size(H_normal));
H_1(ox_index,tcp_xdims(1)) = 1;
H_1(co_index,tcp_xdims(2)) = 1;


%%%% First stage: high O2, CO2 zero
A_2 = A_normal;
A_2(tcp_xdims,tcp_xdims) = 0;
A_3(tcp_xdims(2),tcp_xdims(2)) = .95;
mu_2 = mu_normal;
mu_2(tcp_xdims(1)) = 200;
mu_2(tcp_xdims(2)) = 0;
Q_2 = Q_normal + eye(size(Q_normal,1))*1e-6;
R_2 = R_normal*3;
H_2 = zeros(size(H_normal));
H_2(ox_index,tcp_xdims(1)) = 1;
H_2(co_index,tcp_xdims(2)) = 1;


%%%% Third stage: decay to normal levels

alpha_ox = .95;
e_ox = 1e-2;
alpha_co = .95;
e_co = 1e-2;
A_3 = A_normal;
%A_3(tcp_xdims,tcp_xdims) = 0;
A_3(tcp_xdims(1),tcp_xdims(1)) = alpha_ox;
A_3(tcp_xdims(2),tcp_xdims(2)) = alpha_co;
mu_3 = mu_normal;
mu_3(tcp_xdims(1)) = mu_normal(ox_x_indices(1));
mu_3(tcp_xdims(2)) = mu_normal(co_x_indices(1));
Q_3 = Q_normal;
Q_3(tcp_xdims(1),tcp_xdims(1)) = e_ox;
Q_3(tcp_xdims(2),tcp_xdims(2)) = e_co;
R_3 = R_normal*3;
H_3 = zeros(size(H_normal));
H_3(ox_index,tcp_xdims(1)) = 1;
H_3(co_index,tcp_xdims(2)) = 1;


Z_art = markovtransitionprobsfromintervals(intervals.CoreTempProbeDisconnect,settings.train.babies);
if 1
Z_art = ones(4)*.001;
Z_art(1,1) = .997;
Z_art(2,2) = .997;
Z_art(3,3) = .997;
Z_art(4,4) = .997;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgl_factor = {{A_1 A_2 A_3} {H_1 H_2 H_3} {Q_1 Q_2 Q_3} {R_1 R_2 R_3} tcp_xdims tcp_ydims Z_art {d_normal d_normal d_normal} {mu_1 mu_2 mu_3}};

%sgl_factor = {{A_1 } {H_1} {Q_1 Q_2 Q_3} {R_1 R_2 R_3} tcp_xdims tcp_ydims Z_art {d_normal d_normal d_normal} {mu_1 mu_2 mu_3}};




