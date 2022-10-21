function d = nnchannelsbyname(n,channelnames,standardiselabels)

% NNCHANNELSBYNAME  Array data from a neonate object
%
%  d = nnchannelsbyname(n,channelnames)
%
%  ARGUMENTS
%   n : neonate object
%   channelnames : cell array of channel labels
%  RETURN VALUES
%   d : matrix of data values, where each column is
%       a data channel.
%
%  If no channel with the given name is found, returns
%  a vector of zeros with nsamples elements.

if ~exist('standardiselabels')
  standardiselabels = 1;
end

nchannelnames = length(channelnames);
channelnames = convertchannelnames(channelnames);
[nsamples,nchannels] = size(n.channels);

d = zeros(nsamples,nchannelnames);
if standardiselabels
  n.labels = standardisechannellabels(n.labels);
end
for i=1:nchannelnames
  index = 0;
  for j=1:nchannels
    if strcmp(n.labels{j},channelnames{i})
      index = j;
    end
  end
  if index>0
      d(:,i) = n.channels(:,index);
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
      newobs{i} = 'TP';
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
