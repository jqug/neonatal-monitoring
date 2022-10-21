function [auc,errorrate,eer] = rocintervals(predicted,true_intervals,drawchart);

% [auc,errorrate,eer] = 
% rocintervals(predicted,true_intervals,drawchart)
%


if nargin<3
  drawchart = 0;
end

if (isempty(true_intervals))
  auc = NaN;
  errorrate = NaN;
  eer = NaN;
  return;
end

errthreshold = 0.5;

nsamples = size(predicted,1);
t = zeros(nsamples,1);

for i=1:size(true_intervals,1)
  if true_intervals(i,1)<=nsamples && true_intervals(i,2)>=1
    t(true_intervals(i,1):true_intervals(i,2)) = 1;
  end
end
t = t([1:nsamples],1);
[tp fp] = roc(t,predicted);

indices = find(predicted>errthreshold);
thresholded = zeros(nsamples,1);
thresholded(indices) = 1;

added = thresholded + t;
errorrate = numel(find(added==1))/nsamples;

auc = auroc(tp,fp);
eer = roceer(fp,tp);

if drawchart
  figure
  plot(fp,tp);
end
