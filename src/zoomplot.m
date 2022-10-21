function zoomplot(y,posteriors,labels,plotinfo)

% ZOOMPLOT Show a sequence of inferences, compared against raw data
%          and gold standard intervals.
%
% zoomplot(y,posteriors,true_intervals)

if ~exist('plotinfo'); plotinfo={}; end;

if isfield(plotinfo,'drawallnow')
  drawallnow = plotinfo.drawallnow;
else
  drawallnow = 0;
end
handles = animplot_init(y,size(posteriors,2),labels,plotinfo);
for t=handles{4}:handles{4}:size(y,1)
  animplot_update(handles,posteriors,t,drawallnow);
end
