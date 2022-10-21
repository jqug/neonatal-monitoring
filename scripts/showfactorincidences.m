intervals.Abnormal = intervals.Abnormal_NM;

nbabies = length(intervals.BloodSample);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.BloodSample{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['blood sample, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.IncubatorOpen{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['IncubatorOpen, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.CoreTempProbeDisconnect{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['core temp disconnect, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.Bradycardia{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['bradycardia, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.TCP{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['TCP recal, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);

numincidences = 0;
totalduration = 0;
for ibaby=1:nbabies
  currints = intervals.Abnormal{ibaby};
  if ~isempty(currints)
  numincidences = numincidences + length(currints);
  totalduration = totalduration + sum(currints(:,2)-currints(:,1));
end
end
disp(['abnormal, incidences: ' num2str(numincidences) ', duration: ' num2str(totalduration)]);
