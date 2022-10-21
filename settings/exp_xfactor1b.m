%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%    Experiment settings     %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settings.expid = 'xfactor1b';
settings.shortdesc = 'X-factor 1(b): Blood sample factor is introduced.';
settings.train.babies = 1:5; 
settings.train.xfactor.use_em = 0;
settings.train.xfactor.num_em_updates = 2;
settings.train.xfactor.initial_xi = 1.2;
settings.test.babies = 13;
settings.test.onlyusefirstfewsamples = 1;
settings.test.startindex = 33300;
settings.test.nsamples = 3500;
settings.test.plotinferences = 1;
settings.test.crossvalidate = 0;  % if 1 then train.babies and test.babies are ignored
settings.test.crossvalidationfolds = {[1 2 3 4 5] [6 7 8 9] [10 11 12 13]}; % cross-validation test sets. All other babies used for training
settings.nparticles.high = 550;
settings.nparticles.low = 5;
settings.preprocess.moving_average_window = 11;
settings.preprocess.zero_mean = 0;
settings.preprocess.fixquantisation = 0;
settings.evaluate.draw_roc_curve = 0;
settings.evaluate.use_all_annotations_for_xfactor = 1;
settings.plot.show_true_intervals = 1;
settings.xfactortype = constants.xfactortype.inflatedsystemcov;
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
% Factors to include
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1 bloodsample
%2 handling
%3 tcdisconnection
%4 tcprecal
%5 bradycardia
%6 x 
settings.factors_to_use = [6 1] ;  % x-factor always goes first if present, brady goes before handling

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observed channels for X-factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.factors.x.obschannels = {};    
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.trans_O2});
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.trans_CO2}); 
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.saturation_O2});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.heart_rate});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.systolic_blood_pressure});
constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.diastolic_blood_pressure}); 
%constants.factors.x.obschannels = cellappend(constants.factors.x.obschannels,{constants.cl.core_temp}); 
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
settings.inference.methods_to_use = [constants.inference.adf_constrainedtrans];
%settings.inference.methods_to_use = [constants.inference.fhmm];
