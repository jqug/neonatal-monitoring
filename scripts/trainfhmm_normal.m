normaldata = getdatabetweenintervals(data.preprocessed,intervals.Normal,obschannels,i_baby);

% get the mean and diagonal covariance of training data
alltrainingdata =cellconcat(normaldata);
fhmm_normal_mu = mean(alltrainingdata);
fhmm_normal_cov = diag(cov(alltrainingdata))' + 1e-6;
