function newlabels = standardisechannellabels(oldlabels)

for label=1:length(oldlabels)
  if strcmp(oldlabels{label},'TcPCO_2')
    oldlabels{label} = 'CO';
  end
  if strcmp(oldlabels{label},'TcPO_2')
    oldlabels{label} = 'OX';
  end
  if strcmp(oldlabels{label},'SpO_2')
    oldlabels{label} = 'SO';
  end
  if strcmp(oldlabels{label},'code 4101')
    oldlabels{label} = 'Incu.Air Humidity';
  end
  if strcmp(oldlabels{label},'code 4102')
    oldlabels{label} = 'Incu.Air Temp';
  end
end
newlabels = oldlabels;
