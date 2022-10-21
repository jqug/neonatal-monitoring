function t = intervaltime(intervals)
% INTERVALTIME(intervals) calculate the total time represented by
% a set of start and end points. Input is an N x 2 matrix.

if size(intervals,2) ~= 2 
    error('Input must be an array of pairs of numerical values.');
end

lengths = intervals(:,2) - intervals(:,1);
t = sum(lengths);
