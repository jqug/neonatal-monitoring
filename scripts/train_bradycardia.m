%%%%%%%%% Train bradycardia %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Possible dynamical models for artifact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mt_constant_drift = 1;
mt_constant_mean = 2;
mt_locallinear = 3;
mt_ar = 4;
mt_diff_random_walk = 5;
mt_random_walk = 6;

modeltype = 4;
use_em = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare training data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
brady_all = {};
brady_all = getdatabetweenintervals(data.preprocessed,intervals.Bradycardia,obschannels,settings.train.babies);
brady_all = cellpickchannel(brady_all,settings.factors.bradycardia.ydims);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Train artifact model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch modeltype
  case mt_ar 
    brady_xdims = [];
    for curr_channel = constants.factors.bradycardia.obschannels
      brady_xdims = [brady_xdims xdims.obschannels{indexofobservedchannel(curr_channel,obschannels)}];
    end
    
    %[a e] = aryw(brady_all,3);
    %[A,H,Q,R,d,x_0,P_0] = ar2statespace(a,e);    

    %[A,H,Q,R,tmpx,tmpv,ll] = learn_kalman(celltranspose(bradycomplete), A,H,Q,R,[0 0 0]',eye(3));

    %brady_xdims = brady_xdims(1:3);
    brady_ydim = settings.factors.bradycardia.ydims(1);
    
    % add the slope on to training examples
    d_brady = -2;
    for ibrady=1:length(brady_all)
      brady_all{ibrady} = brady_all{ibrady} - (1:length(brady_all{ibrady}))'*d_brady;
    end
    %[A,Q,H,R,d,mu_art] = hiddenrelativear(brady_all,2,0,1,1,10);
    [A,Q,H,R,d,mu] = hiddenarima(brady_all,2,0,0);
    extrazeros = length(brady_xdims) - size(A,1);
    if extrazeros>0
      %A = blkdiag(A,[ones(extrazeros,1) zeros(extrazeros,extrazeros-1)]);
      A = blkdiag(A,[zeros(extrazeros,extrazeros)]);
      Q = blkdiag(Q,zeros(extrazeros));
      H = [H zeros(size(H,1),extrazeros)];
      mu = [mu; zeros(extrazeros,1)];
      %Q = Q+eye(3)*1e-6;
    end

    [Ahr,Q_tmp,H_tmp] = relativear2statespace(A_normal(brady_xdims(1),brady_xdims(1:2)),A_normal(brady_xdims(3),brady_xdims(3:4)),1,1);
    Qhr = Q_normal(brady_xdims,brady_xdims);
    Qhr(1,1) = Q(1,1);
    Rhr = R_normal(brady_ydim,brady_ydim);
    [A_arttmp,Htmp,Qhr,Rhr,initx,initv,ll] = learn_kalman(celladd(celltranspose(brady_all),-mu_normal(brady_xdims(1))),Ahr,H,Qhr,Rhr,xinit,Q,1,1,1);

    A_art = A_normal;
    A_art(brady_xdims,brady_xdims) = Ahr;
    Q_art = Q_normal;
    Q_art(brady_xdims,brady_xdims) = Qhr;
    R_art = R_normal;
    R_art(brady_ydim,brady_ydim) = Rhr;

    %A_art = A; %A_normal; %*.9;
    %[A_art,Q_tmp,H_tmp] = relativear2statespace(A(1,1:2),A_normal(3,3:4),1,1);
    %Q_art = Q_normal; %*settings.train.xfactor.initial_xi;
    %Q_art(brady_xdims,brady_xdims) = Q;
    %Q_art(brady_xdims(1),brady_xdims(1)) = Q(1,1); %*.01;
    H_art = H_normal; % assume observation distribution is the same as for normality
    %R_art = R_normal;
    d_art = d_normal;
    mu_art = mu_normal;

    %xinit = zeros(size(A,1),1);
    %[A_arttmp,Htmp,Q_art,R_art,initx,initv,ll] = learn_kalman(celladd(celltranspose(brady_all),-mu_art(1)),A_art,H,Q_art,R_art,xinit,Q,1,1,1);
    %Q_art(1,1) = Q_art(1,1)*.1;
 
    %Z_art = [.99 .01;.1 .9]; %% can use this transition matrix for visualisation - doesn't significantly change summary stats (degrades a little)
    Z_art = markovtransitionprobsfromintervals(intervals.Bradycardia,settings.train.babies);
    %Z_art = ones(2)/2;
  case mt_constant_drift;
  case mt_constant_mean;
  case mt_random_walk;
  case mt_diff_random_walk;
end

if use_em
  %tmpbradys = cell(length(bradycomplete),1);
  %for currbrady = 1:length(bradycomplete)
  % tmpbradys{currbrady} = bradycomplete{i}';
  %end
  nhiddenartdims = size(A,1);
  [A_art, H_art, Q_art, R_art, tmpx, tmpv, ll] = learn_kalman(celltranspose(brady_all),A_art, H_art, Q_art, R_art, zeros(3+nhiddenartdims,1),eye(3+nhiddenartdims),10,1,1,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine factor parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgl_factor = {{A_art} {H_art} {Q_art} {R_art} brady_xdims settings.factors.bradycardia.ydims Z_art {d_art} {mu_art}};

