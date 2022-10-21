function handles = animplot_init(y,nprobchannels,labels,plotinfo)

%%%%% Figure setup %%%%%%%%%%%%%%%%%%%%%
clf
h_figure = gcf;
set(h_figure,'doublebuffer','on');
set(h_figure,'renderer','painters');
set(h_figure,'KeyPressFcn',@animplot_KeyPressFcn);
set(h_figure,'Toolbar','none');
plotzeros = 0;

[N ndatachannels] = size(y);
if ~exist('plotinfo'); 
  plotinfo.name = 'Anon';
  plotinfo.dayoflife = 0;
  plotinfo.gestation = 0;
  plotinfo.inferencetype = '';
end;
if ~isfield(plotinfo,'goldstandardintervals'); plotinfo.goldstandardintervals={}; end;
if ~isfield(plotinfo,'projectormode'); plotinfo.projectormode=0; end;

if isfield(plotinfo,'inferencetype')
  set(h_figure,'name',[plotinfo.inferencetype ' inference. Press h for navigation controls']);
end

%%%% General chart appearance %%%%%%%%%%
labelsspecified = (nargin>2) && ~isempty(labels);
nupdates = 50;
updatefrequency = ceil(N/nupdates);
prob_incompletecolour = [230 230 255]/255;
gold_standard_colour = [142 107 35]/255;
data_fillcolour = [251 251 255]/255;
data_edgecolour = [1 .5 .5];
data_trendcolour = [.5 0 0];
shadingcolour = [0 0 0];
titlecolour = [.3 .3 .3];
labelshift = .05;
if plotinfo.projectormode
  fontsize = 16;
  titlefontsize = 14;
else
  fontsize = 10;
  titlefontsize = 10;
end
datachannelfillhandles = cell(ndatachannels,1);
datachannelhandles = cell(ndatachannels,1);
probchannelhandles = cell(nprobchannels,1);


%%%%% Channel setup %%%%%%%%%%%%%%%%%%%%
ntrueintervalchannels = length(plotinfo.goldstandardintervals);
nchannels = ndatachannels + nprobchannels + ntrueintervalchannels;
datachannelfillhandles = cell(ndatachannels,1);
probchannelhandles = cell(nprobchannels,1);
background = zeros(1,N,3);
background(1,:,:) = repmat(prob_incompletecolour,N,1);
if ~plotzeros
  y(find(y==0))=NaN;
end


%%%%% Axis position setup %%%%%%%%%%%%%%
postscaleheight = 25/ndatachannels;
if labelsspecified
  left = .22;
else
  left = .05;
end
right = .95;
width = right - left;
top = 0.98;
bottom = 0.11;
height = top - bottom;
separator = 0.04;
labelshift = .05;
separatorheight = separator * (nchannels-1);
totalaxesheight = height - separatorheight;
datachanheight = totalaxesheight / (ndatachannels + ((nprobchannels+ntrueintervalchannels)/postscaleheight));
postchanheight = datachanheight / postscaleheight;
databottom = top - (ndatachannels * (separator+datachanheight));


%%%% Render first frame %%%%%%%%%%%%%%%%
if plotinfo.projectormode
  set(h_figure,'Color',[.7 .7 .7]);
  set(h_figure,'Menubar','none');
end

for i_currplot = 1:ndatachannels
  pos =  top-((i_currplot)*(datachanheight+separator));
  datachannelhandles{i_currplot} = subplot('Position',[left, pos, width, datachanheight]);
  plot(y(:,i_currplot),'color',data_trendcolour);
  hold on;
  yl = ylim;
  datachannelfillhandles{i_currplot} = fill([1 1 N N],[yl(1); yl(2); yl(2); yl(1)],data_fillcolour, 'EraseMode','xor','EdgeColor',data_edgecolour );
  if labelsspecified
    text('String',labels{i_currplot},'rotation',0,'Position',[-left+labelshift .5],'FontSize',fontsize,'HorizontalAlignment','center','VerticalAlignment','middle','Units','normalized');  
  end
  if i_currplot<nchannels
    set(gca,'XLim',[0 N],'XTickLabel','','XGrid','on','YGrid','on','FontSize',fontsize);
  else
    set(gca,'XLim',[0 N],'XGrid','on','YGrid','on','FontSize',fontsize);
  end
  % draw title if first plot
  if i_currplot==1 && isfield(plotinfo,'name')
    geststr = '';
    agestr = '';
    namestr = '';
    if plotinfo.gestation > 0; geststr = [', ' num2str(plotinfo.gestation) ' weeks gestation']; end;
    if plotinfo.dayoflife < 300; agestr = [', day ' num2str(plotinfo.dayoflife) ' of life']; end;
    
    if plotinfo.projectormode
      namestr = ['Baby (' plotinfo.id ')'];
    else
      namestr = ['Baby ' plotinfo.name ' (' plotinfo.id ')'];
    end
    title([namestr geststr agestr],'FontAngle','normal','FontSize',titlefontsize,'Color',titlecolour);
  end
  linkedaxes(i_currplot) = gca;
end
for i_currplot = 1:nprobchannels
  pos = databottom - ((i_currplot)*(postchanheight+separator));
  subplot('Position',[left,pos,width,postchanheight]);
  probchannelhandles{i_currplot} = image('CData',background,'YData',[0 1],'EraseMode','normal');
  if i_currplot<(nprobchannels+ntrueintervalchannels)
    set(gca,'XTickLabel',''); 
  end
  set(gca,'XGrid','on','XLim',[0 N],'YGrid','on','FontSize',fontsize,'YTick',[],'YLim',[0 1],'Layer','top');
  if labelsspecified
    text('String',labels{ndatachannels+i_currplot},'rotation',0,'Position',[-left+labelshift .5],'FontSize',fontsize,'HorizontalAlignment','center','VerticalAlignment','middle','Units','normalized');
  end
  linkedaxes(i_currplot+ndatachannels) = gca;
end

for i_currplot = 1:ndatachannels
  axes(datachannelhandles{i_currplot});
  yl = ylim;
  set(datachannelfillhandles{i_currplot},'YData',[yl(1); yl(2); yl(2); yl(1)]);
end
for i_currplot = 1:ntrueintervalchannels
  truint = zeros(N,1);
  for i_interval = 1:size(plotinfo.goldstandardintervals{i_currplot}{2},1)
    currentintervals = plotinfo.goldstandardintervals{i_currplot}{2}(i_interval,:);
    if (currentintervals(2)>=1 && currentintervals(1)<=N)
      lowint = max(currentintervals(1),1);
      highint = min(currentintervals(2),N);
      truint(lowint:highint) = 1;
    end
  end
  trueintcolormap = zeros(1,N,3);
  trueintcolormap(1,:,:) = truint * (1-gold_standard_colour);
  trueintcolormap(1,:,:) = 1 - trueintcolormap(1,:,:);
  pos = databottom - ((i_currplot+nprobchannels)*(postchanheight+separator));
  subplot('Position',[left,pos,width,postchanheight]);
  image('CData',trueintcolormap,'YData',[0 1],'EraseMode','normal');
  if i_currplot<ntrueintervalchannels
    set(gca,'XTickLabel','');
  else
    xlabel('Time (s)','Fontsize',fontsize); 
  end
  set(gca,'XGrid','on','XLim',[0 N],'YGrid','on','FontSize',fontsize,'YTick',[],'YLim',[0 1],'Layer','top');
  if labelsspecified
    text('String',plotinfo.goldstandardintervals{i_currplot}{1},'rotation',0,'Position',[-left+labelshift .5],'FontSize',fontsize,'HorizontalAlignment','center','VerticalAlignment','middle','Units','normalized','Color',gold_standard_colour);
  end 
  linkedaxes(i_currplot+ndatachannels+nprobchannels) = gca; 
end
drawnow;
guidata(gcf,linkedaxes);
handles = {datachannelfillhandles probchannelhandles N updatefrequency};

  %% Can make it pause here for demonstration purposes.
  %pause

%%%%%%%%%%%% Callback %%%%%%%%%%%%%%%%%%
function varargout = animplot_KeyPressFcn(src,evnt)
  h = gcbo;
  figdata = guidata(h);
  key = get(h,'CurrentCharacter');
  oldrange = get(figdata(1),'xlim');
  newrange = oldrange;
  switch(key)
      case 'i'
        % zoom in
        newrange = round((oldrange-mean(oldrange))*.65 + mean(oldrange));     
      case 'k'
        % zoom out
        newrange = round((oldrange-mean(oldrange))*1.35 + mean(oldrange));
      case 'j'
        % pan left
        newrange = round(oldrange - .35*diff(oldrange));
      case 'l' 
        % pan right
        newrange = round(oldrange + .35*diff(oldrange));
      case 'h'
        % display help info
        msgbox({'Use keys to navigate while plot in focus.' '  I : zoom in' '  K : zoom out' '  J : pan left' '  L : pan right' '  R : reset view'},'Inference plot controls','help');
      case 'r'
        % reset view
        b = get(h,'children');
        c = get(b,'children');
        newrange = get(c{1}(2),'xdata');
  end
  for i_axes = 1:length(figdata)
      set(figdata(i_axes),'xlim',newrange);
  end
  

