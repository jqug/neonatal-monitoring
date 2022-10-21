function d = nnchannelsbyname(n,channelnames,standardiselabels)

% NNINDEXOFCHANNEL  Numerical index of a channel, specified
%                   by channel label.
%
%  d = nnindexofchannel(n,channelname)


if ~exist('standardiselabels')
  standardiselabels = 1;
end

nchannelnames = length(channelnames);
channelnames = convertchannelnames(channelnames);
d = [];
if standardiselabels
  n.labels = standardisechannellabels(n.labels);
end
for i=1:nchannelnames
  index = 0;
  for j=1:length(n.labels)
    if strcmp(n.labels{j},channelnames{i})
      d = [d j];
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

