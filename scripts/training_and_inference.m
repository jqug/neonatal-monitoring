if settings.steps.inference
  labels = cell(size(obschannels));
  for i_currentchannel = 1:length(labels)
    labels{i_currentchannel} = friendlychannelname(obschannels{i_currentchannel});  
  end
  for i_currentfactor = settings.factors_to_use;
    labels = cellappend(labels,{friendlyfactorname(i_currentfactor)});
  end

  % initialise structures to hold concatenated inference results
  posteriors_concat = [];
  S_concat = [];
  true_intervals = {};
  true_intervals = cell(length(settings.factors_to_use),1);
  true_intervals_concat = {};
  true_intervals_concat = cell(length(settings.factors_to_use),1);
  xi = 0;

  for i_baby=settings.test.babies
    if length(settings.test.babies)>1  
      disp([num2str(find(settings.test.babies==i_baby)) '/' num2str(length(settings.test.babies))])
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up test data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y = nnchannelsbyname(data.preprocessed{i_baby},obschannels);
    if settings.test.onlyusefirstfewsamples
      y = y(settings.test.startindex:settings.test.startindex+settings.test.nsamples,:);
    end

    x_0 = zeros(dim_x,1);
    for i_obschannel = 1:length(obschannels)
      x_0(xdims.obschannels{i_obschannel}) = y(1,i_obschannel);  
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Train individual factors
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if settings.steps.learnfactors
      if settings.inference.current_method==constants.inference.fhmm
        %% FHMM training
        merged_fhmm_factors = {};
        merged_fhmm_trans = [];
        trainfhmm_normal;
        merged_fhmm_factors{1} = {fhmm_normal_mu fhmm_normal_cov};
        for i_facttouse=1:length(settings.factors_to_use)
          switch settings.factors_to_use(i_facttouse)
            case constants.factors.bloodsample.id
              trainfhmm_bloodsample;
            case constants.factors.handling.id
              trainfhmm_humiditydrop;
            case constants.factors.tcdisconnection.id
              trainfhmm_coretemperaturedrop;
            case constants.factors.tcprecal.id
              error('TCP recal not implemented for FHMM');
            case constants.factors.bradycardia.id
              trainfhmm_bradycardia;
            case constants.factors.x.id
              fhmm_factor = 'X-factor not set';
            end
            merged_fhmm_trans = blkdiag(merged_fhmm_trans,fhmm_trans);
            merged_fhmm_factors{i_facttouse+1} = fhmm_factor;
          end   
          i_xfactor = find(settings.factors_to_use==constants.factors.x.id);
          if i_xfactor>0
            trainfhmm_xfactor;
            merged_fhmm_factors{i_xfactor+1} = fhmm_factor;
          end
          [fhmm_means,fhmm_covar,fhmm_priors,fhmm_chains] = factors2meancov(merged_fhmm_factors);
      else
        %%% FSKF training
        merged_factors = {};
        train_normal;
        merged_factors{1} = {A_normal H_normal Q_normal R_normal mu_normal};        
        for i_facttouse=1:length(settings.factors_to_use)
          switch settings.factors_to_use(i_facttouse)
            case constants.factors.bloodsample.id
              train_bloodsample;
            case constants.factors.handling.id
              train_humiditydrop;
            case constants.factors.tcdisconnection.id
              train_coretemperaturedrop;
            case constants.factors.tcprecal.id
              train_TCPrecalibration;
            case constants.factors.bradycardia.id
              train_bradycardia;
            case constants.factors.x.id
              sgl_factor = 'x-factor not set';
            end
            merged_factors{i_facttouse+1} = sgl_factor;
          end   
          i_xfactor = find(settings.factors_to_use==constants.factors.x.id);
          if i_xfactor>0
            switch settings.xfactortype
              case constants.xfactortype.inflatedsystemcov
                train_xfactor;
              case constants.xfactortype.inflatedobscov 
                train_xfactor_inflatedobs;
              case constants.xfactortype.whitenoise
                train_xfactor_whitenoise;
            end
            merged_factors{i_xfactor+1} = sgl_factor;
          end
          [A,H,Q,R,Z,d,mu,prior,chains,activefactordims] = factors2statespace(merged_factors);
        % can update X-factor with EM here. Learn which channels observed by which factors in last line
        if settings.train.xfactor.use_em
          % reestimate X-factor parameters
          disp(['Initial xi setting ' num2str(settings.train.xfactor.initial_xi)]);
          for i_update=1:settings.train.xfactor.num_em_updates
            xi = learnxf(y,A,Q,H,R,d,mu,pi,chains,x_0,Z,activefactordims);
            % insert the new X-factor covariance matrix into list of factors
            disp(['New xi setting: ' num2str(xi)]);
            merged_factors{i_xfactor+1}{3}{1} = merged_factors{1}{3}*xi;
            % reconstruct the full joint model with new X-factor dynamics
              [A,H,Q,R,Z,d,mu,prior,chains,activefactordims] = factors2statespace(merged_factors);
          end
        end
      end % if fhmm
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform inference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    plotinfointervals = {};
    if settings.plot.show_true_intervals
      for i_facttouse = settings.factors_to_use
        switch i_facttouse
          case constants.factors.bloodsample.id
            tmpints = intervals.BloodSample;
          case constants.factors.handling.id    
            tmpints = intervals.IncubatorOpen;
          case constants.factors.tcdisconnection.id
            tmpints = intervals.CoreTempProbeDisconnect;
          case constants.factors.tcprecal.id         
            tmpints = intervals.TCP;
          case constants.factors.bradycardia.id  
            tmpints = intervals.Bradycardia;
          case constants.factors.x.id  
            tmpints = intervals.Abnormal;
        end
        if settings.test.onlyusefirstfewsamples
          plotinfointervals{length(plotinfointervals)+1} = ...
            {['True ' friendlyfactorname(i_facttouse)] tmpints{i_baby}-settings.test.startindex};
        else        
          plotinfointervals{length(plotinfointervals)+1} = {['True ' friendlyfactorname(i_facttouse)] tmpints{i_baby}};
        end
      end
    end
    if settings.test.plotinferences==0
      plotinfointervals = -1;
    end
    plotinfo.projectormode = settings.projectormode;
    plotinfo.goldstandardintervals = plotinfointervals;
    plotinfo.id = num2str(i_baby);
    plotinfo.name = data.preprocessed{i_baby}.forename;
    plotinfo.dayoflife = data.preprocessed{i_baby}.dayoflife;
    plotinfo.gestation = data.preprocessed{i_baby}.gestation;
    plotinfo.showinference = settings.test.plotinferences;

    %%% Temperature dropouts go to 20. change these values to 0 so that dropout
    %%% handling applies to them automatically.
    temperaturechannels = [indexofobservedchannel(constants.cl.core_temp,obschannels) ...
      indexofobservedchannel(constants.cl.peripheral_temp,obschannels) ...
      indexofobservedchannel(constants.cl.incu_temp,obschannels)];  
    if ~isempty(temperaturechannels)
      for i_temperaturechannel = temperaturechannels
        tcdrops = find(y(:,i_temperaturechannel)==20);
        y(tcdrops,i_temperaturechannel) = 0;
      end
    end

    % Do the inference, according to specified method
    switch settings.inference.current_method
      case constants.inference.adf
        plotinfo.inferencetype = 'FSKF (Gaussian sum approx)';
        S = skf_adf(y,A,H,Q,R,x_0,Z,d,mu,[],labels,chains,plotinfo,0);
      case constants.inference.adf_constrainedtrans
        plotinfo.inferencetype = 'FSKF (Gaussian sum approx)';
        [S,x,P_out] = skf_adf(y,A,H,Q,R,x_0,Z,d,mu,[],labels,chains,plotinfo,1);
      case constants.inference.rbpf_nlow
        plotinfo.inferencetype = 'FSKF (Rao-Blackwellised particle filtering)';
        S = skf_rbpf(y,A,H,Q,R,x_0,Z,d,mu,settings.nparticles.low,[],labels,chains,plotinfo,1);
      case constants.inference.rbpf_nhigh
        plotinfo.inferencetype = 'FSKF (Rao-Blackwellised particle filtering)';
        S = skf_rbpf(y,A,H,Q,R,x_0,Z,d,mu,settings.nparticles.high,[],labels,chains,plotinfo,1);
      case constants.inference.fhmm
        plotinfo.inferencetype = 'FHMM';
        S = fhmmexact(y,fhmm_chains,fhmm_means,fhmm_covar,fhmm_priors,merged_fhmm_trans,[],[],labels,plotinfo,1);
        chains = fhmm_chains-1;
    end  
    
    if settings.steps.evaluation
        for i_facttouse=settings.factors_to_use
          switch i_facttouse
            case constants.factors.bloodsample.id
              tmpints = intervals.BloodSample;
            case constants.factors.handling.id    
              tmpints = intervals.IncubatorOpen;
            case constants.factors.tcdisconnection.id
              tmpints = intervals.CoreTempProbeDisconnect;
            case constants.factors.tcprecal.id         
              tmpints = intervals.TCP;
            case constants.factors.bradycardia.id  
              tmpints = intervals.Bradycardia;
            case constants.factors.x.id  
              tmpints = intervals.Abnormal;
              if settings.evaluate.use_all_annotations_for_xfactor
                % look at each unused factor. If it is observed then use annotation for X-factor
                unusedfactors = setdiff([1:constants.factors.highestfactorid],settings.factors_to_use);
                factorsforXannotation = [];
                if ismember(constants.factors.bloodsample.id,unusedfactors)...
                  && sum(ismember(constants.factors.bloodsample.obschannels,obschannels))
                  factorsforXannotation = [factorsforXannotation constants.factors.bloodsample.id];
                  tmpints{i_baby} = [tmpints{i_baby}; intervals.BloodSample{i_baby}];
                end

                if ismember(constants.factors.handling.id,unusedfactors)...
                  && sum(ismember(constants.factors.handling.obschannels,obschannels))
                  factorsforXannotation = [factorsforXannotation constants.factors.handling.id];
                  tmpints{i_baby} = [tmpints{i_baby}; intervals.IncubatorOpen{i_baby}];
                end

                if ismember(constants.factors.tcdisconnection.id,unusedfactors)...
                  && sum(ismember(constants.factors.tcdisconnection.obschannels,obschannels))
                  factorsforXannotation = [factorsforXannotation constants.factors.tcdisconnection.id];
                  tmpints{i_baby} = [tmpints{i_baby}; intervals.CoreTempProbeDisconnect{i_baby}];
                end

                if ismember(constants.factors.tcprecal.id,unusedfactors)...
                  && sum(ismember(constants.factors.tcprecal.obschannels,obschannels))
                  factorsforXannotation = [factorsforXannotation constants.factors.tcprecal.id];
                  tmpints{i_baby} = [tmpints{i_baby}; intervals.TCP{i_baby}];
                end

                if ismember(constants.factors.bradycardia.id,unusedfactors)...
                  && sum(ismember(constants.factors.bradycardia.obschannels,obschannels))
                  factorsforXannotation = [factorsforXannotation constants.factors.bradycardia.id];
                  tmpints{i_baby} = [tmpints{i_baby}; intervals.Bradycardia{i_baby}];
                end
              end % if
          end % switch

          % only need the intervals for this baby
          true_intervals{i_facttouse} = tmpints{i_baby};

          % correct the intervals if a nonzero start time has been used 
          if settings.test.onlyusefirstfewsamples
            true_intervals{i_facttouse} = true_intervals{i_facttouse} - settings.test.startindex; 
          end 

          % make sure that the intervals don't go outside the extent of the data
          true_intervals{i_facttouse}(find(true_intervals{i_facttouse}<1)) = 1;
          true_intervals{i_facttouse}(find(true_intervals{i_facttouse}>size(y,1))) = size(y,1);
          tmp_intervals = [];
          for i_currint = 1:size(true_intervals{i_facttouse},1)
            if true_intervals{i_facttouse}(i_currint,2)>true_intervals{i_facttouse}(i_currint,1)
              % only include intervals of positive duration
              tmp_intervals = [tmp_intervals; true_intervals{i_facttouse}(i_currint,:)];
            end
          end
          true_intervals{i_facttouse} = tmp_intervals;

          % initialise list of concatenated intervals if it doesn't already exist
          if length(true_intervals_concat)<i_facttouse
            true_intervals_concat{i_facttouse} = [];
          end

          % add the currently relevant intervals to the concatenated interval list
          curr_offset = size(S_concat,1);
          true_intervals_concat{i_facttouse} = [true_intervals_concat{i_facttouse}; (true_intervals{i_facttouse}+curr_offset)]; 

        end % for i_facttouse
    end % if 

    posteriors = factoriseposteriors(S,chains+1);

    %% take posteriors and true intervals. Calculate AUC and EER for this baby
    for i_facttouse =1:length(settings.factors_to_use)
      [auc,err,eer] = rocintervals(posteriors(:,i_facttouse ),true_intervals{settings.factors_to_use(i_facttouse)},settings.evaluate.draw_roc_curve);
      eer = eer(1); % sometimes get multiple solutions
      all_auc(settings.factors_to_use(i_facttouse),i_baby) = auc;
      all_err(settings.factors_to_use(i_facttouse),i_baby) = err;
      all_eer(settings.factors_to_use(i_facttouse),i_baby) = eer; 
    end

    % save inferences if required
    % create label of the form '<expid>_<babyid>.mat'
    % save posterior, true intervals, data, labels, obschannels, settings
    if settings.evaluate.saveinferences
      if settings.test.crossvalidate
        xvalfilename = ['_part' num2str(ixvalfold)];
      else
        xvalfilename = [];
      end
      inf_filename = [settings.expid xvalfilename '_baby' num2str(i_baby) '.mat'];
      eval(['save ' constants.evaluation.outputdir '/' inf_filename ' posteriors obschannels labels true_intervals settings xi plotinfo all_auc all_eer all_err']); 
    end

  end % for i_baby
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
if settings.steps.evaluation
  auc_by_factor = zeros(constants.factors.highestfactorid,1);
  err_by_factor = zeros(constants.factors.highestfactorid,1);
  eer_by_factor = zeros(constants.factors.highestfactorid,1);

  for i_facttouse =1:length(settings.factors_to_use)
    tmpintervals = minmaxcolumn(true_intervals_concat{settings.factors_to_use(i_facttouse)});
    if ~isempty(true_intervals_concat{settings.factors_to_use(i_facttouse)}) && (min(min(tmpintervals))<size(posteriors_concat,1))
      [auc,err,eer] = rocintervals(posteriors_concat(:,i_facttouse ),tmpintervals,settings.evaluate.draw_roc_curve);
      eer = eer(1); % sometime get multiple solutions
      auc_by_factor(settings.factors_to_use(i_facttouse)) = auc;
      err_by_factor(settings.factors_to_use(i_facttouse)) = err;
      eer_by_factor(settings.factors_to_use(i_facttouse)) = eer;
      if ~settings.test.crossvalidate  % don't display results here if doing cross validation
        if settings.factors_to_use(i_facttouse)==constants.factors.x.id...
          && exist('factorsforXannotation') && length(factorsforXannotation)>0
            unusedfactorstring = '';
            for i_unusedfactor=1:length(factorsforXannotation)
              unusedfactorstring = [unusedfactorstring friendlyfactorname(factorsforXannotation(i_unusedfactor))];
              if i_unusedfactor<length(factorsforXannotation)
                unusedfactorstring = [unusedfactorstring ', '];
              end
            end
            disp(['Factor: X, evaluated using ' unusedfactorstring]);
        else
          disp(['Factor: ' friendlyfactorname(settings.factors_to_use(i_facttouse))]);
        end
        disp(['AUC=' num2str(auc) ', error=' num2str(err) ', EER=' num2str(eer)]);
      end
    else
      disp(['No occurrences of ' friendlyfactorname(settings.factors_to_use(i_facttouse))]);
    end
    disp('');
  end
end
end
