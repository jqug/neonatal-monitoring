%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%    Run experiments         %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('settings')
  disp('Run chooseexperiment.m to load settings.');
else

if ~(exist('data')==1)
  load 15dayspreprocessed.mat;
end

rootexpid = settings.expid;

for i_infmethod = settings.inference.methods_to_use
  settings.inference.current_method = i_infmethod;
  settings.expid = rootexpid;
  switch settings.inference.current_method
    case constants.inference.rbpf_nlow   
      settings.expid = [rootexpid 'rbpf'];                 
    case constants.inference.rbpf_nhigh  
      settings.expid = [rootexpid 'rbpf'];                 
    case constants.inference.fhmm 
      settings.expid = [rootexpid 'fhmm'];                 
  end

  % initialise evaluation variables
  all_auc = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
  all_err = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;
  all_eer = zeros(constants.factors.highestfactorid,length(data.preprocessed)) * NaN;

  if isfield(settings.test,'crossvalidate') && settings.test.crossvalidate

    xval_auc = zeros(constants.factors.highestfactorid,length(settings.test.crossvalidationfolds)); % AUC 
    xval_err = zeros(constants.factors.highestfactorid,length(settings.test.crossvalidationfolds)); % Error rate
    xval_eer = zeros(constants.factors.highestfactorid,length(settings.test.crossvalidationfolds)); % Equal error rate

    tic;
    for ixvalfold=1:length(settings.test.crossvalidationfolds) 
      settings.test.babies = settings.test.crossvalidationfolds{ixvalfold};
      % training babies are the whole list minus test set
      settings.train.babies = setdiff(1:length(data.preprocessed),settings.test.babies);
      disp(['Partition ' num2str(ixvalfold)]);
      preprocessing_and_setup;
      training_and_inference;
    end
    elapsed_time = toc;
  else
    tic;
    settings.test.crossvalidate = 0;
    preprocessing_and_setup;
    training_and_inference;
    elapsed_time = toc;
  end
end

for idispfactor=1:length(settings.factors_to_use)
  mean_auc = meannum(all_auc(settings.factors_to_use(idispfactor),:));
  mean_err = meannum(all_err(settings.factors_to_use(idispfactor),:));
  mean_eer = meannum(all_eer(settings.factors_to_use(idispfactor),:));
  [statsline,errmsg] = sprintf('%s: AUC %0.3f, EER %0.3f, Error rate %0.3f',friendlyfactorname(settings.factors_to_use(idispfactor)),mean_auc,mean_eer,mean_err);
  disp(statsline);
end

if settings.evaluate.saveinferences
  eval(['save ' constants.evaluation.outputdir '/summarystats_' settings.expid '.mat elapsed_time all_auc all_err all_eer']); 
end
end

