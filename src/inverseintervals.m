function invints = inverseintervals(intervals)

% INVERSEINTERVALS(intervals) given intervals for which
% a system was in a particular state, returns the intervals
% for which the system was not in that state. returns a cell
% array of interval matrices.

if ~iscell(intervals)
  intervals = {intervals}
end

invints = cell(length(intervals),1);

for casenum = 1:length(intervals)
  invints{casenum} = [];
  currlowindex = 1;
  for intnum = 1:size(intervals{casenum},1)
    if intervals{casenum}(intnum,1)>(currlowindex+1)
      invints{casenum} = [invints{casenum}; [currlowindex intervals{casenum}(intnum,1)-1]];
    end
    currlowindex = intervals{casenum}(intnum,2)+1;
  end
end

