%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Train normal model 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_normal = zeros(dim_x);
Q_normal = zeros(dim_x);
R_normal = zeros(dim_y);
H_normal = zeros(dim_y,dim_x);
mu_normal = zeros(dim_x,1);
d_normal = zeros(dim_x,1);

normaldata = getdatabetweenintervals(data.preprocessed,intervals.Normal,obschannels,i_baby);

for i_currchannel = 1:length(obschannels)
  modeltype = getfield(constants.normaldynamics,obschannels{i_currchannel});  
  channel_xdims = xdims.obschannels{i_currchannel};
  switch modeltype{1}
    case constants.models.arima
      p = modeltype{2};
      d_order = modeltype{3};             
  end
    switch modeltype{1}
    case constants.models.relativear % learn as relative AR
      p_sig = modeltype{2};
      d_sig = modeltype{3};
      p_base = modeltype{4};
      d_base = modeltype{5};
      mavgwin = modeltype{6};
      [A,Q,H,R,d,mu] = hiddenrelativear(cellpickchannel(normaldata,i_currchannel),p_base,d_base,p_sig,d_sig,mavgwin);
      
    case constants.models.arima % learn as hidden ARIMA
      if strcmp(obschannels{i_currchannel},constants.cl.saturation_O2)
        p = modeltype{2};
        d_order = modeltype{3};
        spo2mean = median(cellconcat(cellpickchannel(normaldata,i_currchannel)));
        spo2traindata = celladd(cellpickchannel(normaldata,i_currchannel),-spo2mean);
        [A,Q,H,R,d,mu] = hiddenarima(cellpickchannel(normaldata,i_currchannel),p,d_order,0);
        mu = ones(size(mu))*spo2mean;
        A = .975;
      else
        p = modeltype{2};
        d_order = modeltype{3};
        [A,Q,H,R,d,mu] = hiddenarima(cellpickchannel(normaldata,i_currchannel),p,d_order,0);
      end
    end
    
    %% manually adjust some channels to give suitable signal to noise ratio
    %% these are then refined with EM updates below
    if strcmp(obschannels{i_currchannel},constants.cl.systolic_blood_pressure)...
     || strcmp(obschannels{i_currchannel},constants.cl.diastolic_blood_pressure) 
      A = A*.998;
      Q = Q*1.5;
    end
    if strcmp(obschannels{i_currchannel},constants.cl.heart_rate)
      A = A*.998;
    end

    %% make sure the noise covariances are non-singular
    Q = Q*2;
    Q = Q + eye(size(Q,1))*1e-6;
    R = R + eye(size(R,1))*1e-6;

    if strcmp(obschannels{i_currchannel},constants.cl.incu_humidity)
    %% set the previously learnt best AR(1) parameters for normal humidity
    %% dynamics
      Q = 1e-4;
      R = 1e-5; 
      A = .988;
    elseif strcmp(obschannels{i_currchannel},constants.cl.core_temp)
    % Leave core temp params the same
    else
    %% EM updates for the relative AR type model
      if modeltype{1} == constants.models.relativear
        sglchannel_normaldata = cellpickchannel(normaldata,i_currchannel);
        if any(sglchannel_normaldata{1}) % don't do anything if empty training data
          zeroentries = find(A==0);
          xinit = repmat(sglchannel_normaldata{1}(1),size(A,1),1);  
          [Atmp,H,Q,R,initx,initv,ll] = learn_kalman(celltranspose(sglchannel_normaldata),A,H,Q,R,xinit,Q,1,1,3);
          A(zeroentries) = 0;
        end
      end
    end
    
    %% Normal training data for the following observation channels is typically very constant, so obs noise
    %% is learnt too low - increase to better level.
    if strcmp(obschannels{i_currchannel},constants.cl.core_temp) || strcmp(obschannels{i_currchannel},constants.cl.peripheral_temp)
      R = R+.5;
    end
    if strcmp(obschannels{i_currchannel},constants.cl.trans_O2) || strcmp(obschannels{i_currchannel},constants.cl.trans_CO2)
      R = R*200;
    end    

    if strcmp(obschannels{i_currchannel},constants.cl.systolic_blood_pressure)...
     || strcmp(obschannels{i_currchannel},constants.cl.diastolic_blood_pressure)
      Q(1,1) = Q(1,1)*.5;
    end

    A_normal(channel_xdims,channel_xdims) = A;
    Q_normal(channel_xdims,channel_xdims) = Q;
    H_normal(i_currchannel,channel_xdims(1)) = 1;
    R_normal(i_currchannel,i_currchannel) = R;
    mu_normal(channel_xdims) = mu;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set normal dynamics for factors 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i_factor = settings.factors_to_use
  switch i_factor
    case constants.factors.bloodsample.id
      bs_channels = xdims.obschannels{indexofobservedchannel(constants.cl.systolic_blood_pressure,obschannels)};
      mu_normal(settings.factors.bloodsample.xdims(1)) = mu_normal(bs_channels(1));
      A_normal(settings.factors.bloodsample.xdims(1), bs_channels(1)) = 1;
    case constants.factors.handling.id
      ih_channels =  xdims.obschannels{indexofobservedchannel(constants.cl.incu_humidity,obschannels)};
      A_normal(settings.factors.handling.xdims,ih_channels(1)) = 1;
    case constants.factors.tcdisconnection.id
      tc_channels = xdims.obschannels{indexofobservedchannel(constants.cl.core_temp,obschannels)};
      A_normal(settings.factors.tcdisconnection.xdims(1), tc_channels(1)) = 1;
      mu_normal(settings.factors.tcdisconnection.xdims(1)) = mu_normal(tc_channels(1));
    case constants.factors.tcprecal.id;
    case constants.factors.bradycardia.id;
    case constants.factors.x.id;
  end
end


