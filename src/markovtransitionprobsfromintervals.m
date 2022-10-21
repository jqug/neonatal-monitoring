function t = markovtransitionprobsfromintervals(intervals,trainindices)

% MARKOVTRANSITIONPROBSFROMINTERVALS(intervals,trainindices) returns the
% ML estimator of the probability transition matrix between the states
% represented in 'intervals'. 
%
% The intervals parameter is a cell array of interval matrices.The
% trainindices parameter specifies which of these to use in training. If
% left blank then all interval data is used.

if ~exist('trainindices')
  trainindices = 1:length(intervals);
end

nstates = 2;
%nstates = size(intervals{trainindices(1)},2);
%assert(nstates==2,'Not implemented for more than two states yet.')
t = zeros(nstates);

avgdurations = zeros(nstates,1);

% dwell times for 'on' state
allintervals = [];
for casenum = trainindices
  allintervals = [allintervals; intervals{casenum}];
end
durations = allintervals(:,2) - allintervals(:,1);
avgdurations(1) = mean(durations,1);

% dwell times for 'off' state
allintervals = [];
invints = inverseintervals(intervals);
for casenum = trainindices
  allintervals = [allintervals; invints{casenum}];
end
durations = allintervals(:,2) - allintervals(:,1);
avgdurations(2) = mean(durations,1);

% transition probabilities
for statenum = 1:nstates
  dwellprob = 1- (1/avgdurations(statenum));
  t(statenum,:) = (1-dwellprob)/(nstates-1);
  t(statenum,statenum) = dwellprob;
end

