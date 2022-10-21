if ~(exist('data')==1)
  disp('Loading raw data...');
  load 15days.mat
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if settings.steps.preprocess
  data.preprocessed = data.raw;
  allbabies = unique([settings.train.babies settings.test.babies]);
  for i_currentbaby = 1:length(allbabies)
    if isfield(intervals,'analysistimes') && length(intervals.analysistimes)>=i_currentbaby && length(intervals.analysistimes{allbabies(i_currentbaby)})==2
      tmp_analysistimes = (intervals.analysistimes{allbabies(i_currentbaby)}(1):intervals.analysistimes{allbabies(i_currentbaby)}(2));
    else
      tmp_analysistimes = 1:data.raw{allbabies(i_currentbaby)}.nsamples;
    end
    tmp_channels = data.raw{allbabies(i_currentbaby)}.channels(tmp_analysistimes,:);
    if settings.preprocess.zero_mean
      tmp_channels = tmp_channels - repmat(mean(tmp_channels),size(tmp_channels,1),1);
    end
    if settings.preprocess.fixquantisation
      % get the indices of channels which need quantisation correction
      quantchannels = nnindexofchannel(data.raw{allbabies(i_currentbaby)},...
        {constants.cl.incu_humidity});
      tmp_channels(:,quantchannels) = convertdiscontinuities(tmp_channels(:,quantchannels));
    end
    if settings.preprocess.moving_average_window > 0 
      tmp_channels = mavgz(tmp_channels,settings.preprocess.moving_average_window);
    end
    data.preprocessed{allbabies(i_currentbaby)}.channels(tmp_analysistimes,:) = tmp_channels;
  end
elseif ~isfield(data,'preprocessed')
  data.preprocessed = data.raw;  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up hidden and observed dimensions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if settings.steps.allocatedimensions

  % establish which channels are observed
  obschannels = {};
  for i_currfact = settings.factors_to_use
    switch i_currfact
      case constants.factors.bloodsample.id
        obschannels = cellappend(obschannels,constants.factors.bloodsample.obschannels);
      case constants.factors.handling.id
        obschannels = cellappend(obschannels,constants.factors.handling.obschannels);
      case constants.factors.tcdisconnection.id
        obschannels = cellappend(obschannels,constants.factors.tcdisconnection.obschannels);
      case constants.factors.tcprecal.id
        obschannels = cellappend(obschannels,constants.factors.tcprecal.obschannels);
      case constants.factors.bradycardia.id
        obschannels = cellappend(obschannels,constants.factors.bradycardia.obschannels);
      case constants.factors.x.id
        obschannels = cellappend(obschannels,constants.factors.x.obschannels);
    end
  end
  obschannels = cellstrunique(obschannels);

  % allocate hidden state dimensions for each observed channel
  curr_high_x_dim = 1;
  for i_currchannel = 1:length(obschannels)
  nhiddendims = 0;
  model = getfield(constants.normaldynamics,obschannels{i_currchannel});
  switch model{1}
      case constants.models.arima
        nhiddendims = model{2}+model{3};
      case constants.models.relativear
        nsigdims = model{2}+model{3};
        nbasdims = model{4}+model{5};
        nhiddendims = nsigdims + max(nsigdims,nbasdims);
    end   
    xdims.obschannels{i_currchannel} = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
    curr_high_x_dim = curr_high_x_dim + nhiddendims;
  end
  
  % allocate hidden state dimensions for each factor
  for i_facttouse=settings.factors_to_use
    switch i_facttouse
      case constants.factors.bloodsample.id
        settings.factors.bloodsample.ydims = [];
        settings.factors.bloodsample.xdims = [];
        for i_currchannel = constants.factors.bloodsample.obschannels
          settings.factors.bloodsample.ydims = [settings.factors.bloodsample.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.bloodsample.nhiddendims;
        settings.factors.bloodsample.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      case constants.factors.handling.id
        settings.factors.handling.ydims = [];
        settings.factors.handling.xdims = [];
        for i_currchannel = constants.factors.handling.obschannels
          settings.factors.handling.ydims = [settings.factors.handling.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.handling.nhiddendims;
        settings.factors.handling.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      case constants.factors.tcdisconnection.id
        settings.factors.tcdisconnection.ydims = [];
        settings.factors.tcdisconnection.xdims = [];
        for i_currchannel = constants.factors.tcdisconnection.obschannels
          settings.factors.tcdisconnection.ydims = [settings.factors.tcdisconnection.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.tcdisconnection.nhiddendims;
        settings.factors.tcdisconnection.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      case constants.factors.tcprecal.id
        settings.factors.tcprecal.ydims = [];
        settings.factors.tcprecal.xdims = [];
        for i_currchannel = constants.factors.tcprecal.obschannels
          settings.factors.tcprecal.ydims = [settings.factors.tcprecal.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.tcprecal.nhiddendims;
        settings.factors.tcprecal.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      case constants.factors.bradycardia.id
        settings.factors.bradycardia.ydims = [];
        settings.factors.bradycardia.xdims = [];
        for i_currchannel = constants.factors.bradycardia.obschannels
          settings.factors.bradycardia.ydims = [settings.factors.bradycardia.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.bradycardia.nhiddendims;
        settings.factors.bradycardia.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      case constants.factors.x.id
        settings.factors.x.ydims = [];
        settings.factors.x.xdims = [];
        for i_currchannel = constants.factors.x.obschannels
          settings.factors.x.ydims = [settings.factors.x.ydims cellstrfind(obschannels,i_currchannel)];
        end;
        nhiddendims = constants.factors.x.nhiddendims;
        settings.factors.x.xdims = curr_high_x_dim:curr_high_x_dim+nhiddendims-1;
      otherwise warning(['Unknown factor identifier: ' i_facttouse]);
    end
    curr_high_x_dim = curr_high_x_dim + nhiddendims;
  end 
  dim_x = curr_high_x_dim-1;
  dim_y = length(obschannels);    
end

