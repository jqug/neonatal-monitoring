tempdrops = getdatabetweenintervals(data.preprocessed,intervals.CoreTempProbeDisconnect,obschannels,settings.train.babies);

% get the mean and diagonal covariance of training data
alltrainingdata =cellconcat(tempdrops);
fhmm_mu = mean(alltrainingdata);
fhmm_cov = diag(cov(alltrainingdata))' + 1e-6;

% to get prior prob of factor, use the fact that training data contains all instances
% in #training babies x 24 hours of monitoring data.
fhmm_prior = length(alltrainingdata)/(length(settings.train.babies)*24*3600);
fhmm_prior = [fhmm_prior 1-fhmm_prior];

% transitions between states - use expected dwell times
fhmm_trans = markovtransitionprobsfromintervals(intervals.CoreTempProbeDisconnect,settings.train.babies);

% FHMM factors are of the form {mean covariance observedchannels priors}
% where mean and cov are made up of row vectors. priors takes 
fhmm_factor = {fhmm_mu fhmm_cov settings.factors.tcdisconnection.ydims fhmm_prior};
