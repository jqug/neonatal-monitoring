function d = getdatabetweenintervals(data,intervals,obschannels,indices, intervalcols)

% GETDATABETWEENINTERVALS  Given a cell array of neonate objects, a cell
%   array of intervals and a set of observation channels, return the
%   relevant data as a new cell array of neonate objects.
%
%   GETDATABETWEENINTERVALS(data,intervals,obschannels)
%
%   GETDATABETWEENINTERVALS(data,intervals,obschannels,indices) returns
%   a similar cell array, but only for intervals within the elements of
%   'data' contained in 'indices'.
%
%   GETDATABETWEENINTERVALS(data,intervals,obschannels,indice, intervalcols) is
%   used for interval channels with more than two columns, representing an
%   event with multiple stages. intervalcols is a 2-element array specifying
%   which interval points to use.

if ~exist('indices') || isempty(indices)
  indices = 1:length(data);
end

if ~exist('intervalcols')
  intervalcols = [1 2];
end

d = {};
%obschannels = convertchannelnames(obschannels);
for i_nn = indices
  [nsamples,nchannels] = size(data{i_nn}.channels);
  for i_interval = 1:size(intervals{i_nn},1)
    currinterval = intervals{i_nn}(i_interval,:);
    currstart = max(1,currinterval(intervalcols(1)));
    currend = min(nsamples,currinterval(intervalcols(2)));
    if currstart<currend
      nnseg = data{i_nn};
      nnseg.channels = nnseg.channels(currstart:currend,:);
      currsegment = nnchannelsbyname(nnseg,obschannels);
      d = cellappend(d,{currsegment});
    end
  end
end

function newobs = convertchannelnames(oldobs)
newobs = oldobs;
for i = 1:length(oldobs)
  switch oldobs{i}
    case 'heart_rate'
      newobs{i} = 'HR';
    case 'systolic_blood_pressure'
      newobs{i} = 'BS';
    case 'diastolic_blood_pressure'
      newobs{i} = 'BD';
    case 'mean_blood_pressure'
      newobs{i} = 'BM';
    case 'saturation_O2'
      newobs{i} = 'SO';
    case 'pulse_rate'
      newobs{i} = 'HR';
    case 'core_temp'
      newobs{i} = 'TC';
    case 'peripheral_temp'
      newobs{i} = 'TC';
    case 'incu_humidity'
      newobs{i} = 'Incu.Air Humidity';
    case 'incu_temp'
      newobs{i} = 'Incu.Air Temp';
    case 'trans_O2'
      newobs{i} = 'OX';
    case 'trans_CO2'
      newobs{i} = 'CO';
  end
end
