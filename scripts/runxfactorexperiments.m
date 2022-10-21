globalconstants;
globalsettings;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%    Experiment settings     %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settings.expid = 'xfactor';
settings.shortdesc = 'X-factor experiments for chapter 7';
settings.train.babies = [1];
settings.train.xfactor.use_em = 0;
settings.train.xfactor.num_em_updates = 2;
settings.train.xfactor.initial_xi = 1.2;
settings.train.restrictnormaldata = 1; % never use more than 30mins of normal training data
settings.test.babies = 3;
settings.test.onlyusefirstfewsamples = 0;
settings.test.startindex = 83500;
settings.test.nsamples = 2000;
settings.test.crossvalidate = 1;  % if 1 then train.babies and test.babies are ignored
settings.test.crossvalidationfolds = {[1:5] [6:10] [11:15]}; % cross-validation test sets. All other babies used for training
settings.test.plotinferences = 0;
settings.nparticles.high = 550;
settings.nparticles.low = 5;
settings.preprocess.moving_average_window = 11;
settings.preprocess.zero_mean = 0;
settings.preprocess.fixquantisation = 0;
settings.evaluate.draw_roc_curve = 0;
settings.evaluate.use_all_annotations_for_xfactor = 1;
settings.evaluate.saveinferences = 1;
settings.plot.show_true_intervals = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steps to run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settings.steps.preprocess         = 0;
settings.steps.allocatedimensions = 1;
settings.steps.learnfactors       = 1;
settings.steps.combinefactors     = 1;
settings.steps.inference          = 1;
settings.steps.evaluation         = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observed channels for X-factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.factors.x.obschannels = {};    
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.trans_O2});
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.trans_CO2}); 
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.saturation_O2});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.heart_rate});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.systolic_blood_pressure});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.diastolic_blood_pressure}); 
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.core_temp}); 
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.incu_temp});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inference methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%adf          
%rbpf_nlow    
%rbpf_nhigh     
%adf_drops    
%adf_drops_constrainedtrans
%fhmm     
settings.inference.current_method = [constants.inference.adf_constrainedtrans];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Factors to include
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1 bloodsample
%2 handling
%3 tcdisconnection
%4 tcprecal
%5 bradycardia
%6 x

if ~(exist('data')==1)
  load 15dayspreprocessed.mat
end

all_auc = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
all_err = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
all_eer = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
elapsed_time = 0;
% try the normal X-factor model, then repeat all experiments with the two alternative dynamical constructions
for currxfactortype = [constants.xfactortype.inflatedsystemcov constants.xfactortype.inflatedobscov constants.xfactortype.whitenoise]
  settings.xfactortype = currxfactortype;
  % insert this label in the filename of all stored results
  xfactormodeltypelabel = [];
  switch settings.xfactortype
    case constants.xfactortype.inflatedobscov
      xfactormodeltypelabel = '_inflobs';
    case constants.xfactortype.whitenoise
      xfactormodeltypelabel = '_wnoise';
  end

  factorstoinclude = {[6] [6 2] [6 2 3] [6 2 3 1] [6 5 2 3 1]}; % added in order [2 3 1 5];
  
  xval_auc = zeros(constants.factors.highestfactorid,length(data.preprocessed),length(factorstoinclude)); % AUC for each fold, second index is fold number, third is number of factor combinations tried,   
  xval_err = zeros(constants.factors.highestfactorid,length(data.preprocessed),length(factorstoinclude)); % Error rate
  xval_eer = zeros(constants.factors.highestfactorid,length(data.preprocessed),length(factorstoinclude)); % Equal error rate
   
  tic;
  for use_em = [0]
    settings.train.xfactor.use_em = use_em;
    % don't use EM if a non-standard X-factor model is used
    if (settings.xfactortype==constants.xfactortype.inflatedsystemcov) || (use_em==0)
      % add the accompanying factors one by one
      for ifactorsincluded=1:length(factorstoinclude)

        all_auc = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
        all_err = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
        all_eer = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;

        settings.factors_to_use = factorstoinclude{ifactorsincluded}; 
              % [6 factorstoinclude(1:ifactorsincluded)];
        % do the test for each cross validation test partition
        for ixvalfold=1:length(settings.test.crossvalidationfolds) 
          settings.expid = ['xfactor_em' num2str(use_em) xfactormodeltypelabel '_factorsincl' num2str(ifactorsincluded-1)];
          settings.test.babies = settings.test.crossvalidationfolds{ixvalfold};
          % training babies are the whole list minus test set
          settings.train.babies = setdiff(1:length(data.preprocessed),settings.test.babies);
          disp(['Partition ' num2str(ixvalfold)]);
          fskf_preprocessing_and_setup;
          fskf_training_and_inference;
          
          xval_auc(:,:,ifactorsincluded) = all_auc;
          xval_err(:,:,ifactorsincluded) = all_err;
          xval_eer(:,:,ifactorsincluded) = all_eer;
        end
        % show some stats on the console
        for idispfactor=1:length(settings.factors_to_use)
          mean_auc = meannum(all_auc(settings.factors_to_use(idispfactor),:));
          mean_err = meannum(all_err(settings.factors_to_use(idispfactor),:));
          mean_eer = meannum(all_eer(settings.factors_to_use(idispfactor),:));
          disp([friendlyfactorname(settings.factors_to_use(idispfactor)) ': ' num2str(mean_auc) ' / ' num2str(mean_err) ' / ' num2str(mean_eer)]);
        end

        xval_auc(:,:,ifactorsincluded) = all_auc;
        xval_err(:,:,ifactorsincluded) = all_err;
        xval_eer(:,:,ifactorsincluded) = all_eer;

        % save the summary statistics
        if settings.evaluate.saveinferences
          eval(['save ' constants.evaluation.outputdir '/summarystats_xfactor' xfactormodeltypelabel '.mat xval_auc xval_err xval_eer elapsed_time all_auc all_err all_eer']); 
        end

      end % for ifactorsincluded
    end % if norm model or no EM
  end % using EM or not
  elapsed_time = toc;

  %save the summary statistics
  if settings.evaluate.saveinferences
    eval(['save ' constants.evaluation.outputdir '/summarystats_xfactor' xfactormodeltypelabel '.mat xval_auc xval_err xval_eer elapsed_time all_auc all_err all_eer']); 
  end

end % different x-factor types

