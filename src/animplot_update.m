function animplot_update(handles,probchannels,currindex,drawallnow)

%if min(min(probchannels))<0; error('inconsistent probabilities (<0)');
%end;
%if max(max(probchannels))>1; error('inconsistent probabilities (>1)'); end;

i = currindex;
N = handles{3};
updatefrequency = handles{4};
if ~exist('drawallnow'); drawallnow = 0; end;
if (mod(i,updatefrequency) == 0 || i==N) && (~drawallnow || i==N)
  datachannelfillhandles = handles{1};
  probchannelhandles = handles{2};
  ndatachannels = length(datachannelfillhandles);
  nprobchannels = length(probchannelhandles);
  
  probchannels = 1 - probchannels;
  for i_currplot = 1:ndatachannels
    set(datachannelfillhandles{i_currplot},'Xdata',[i i N N]);
  end
  for i_currplot = 1:nprobchannels
    im = get(probchannelhandles{i_currplot},'CData');
    if ~drawallnow
      im(1,max(1,i-updatefrequency):i,:) = repmat(probchannels(max(1,i-updatefrequency):i,i_currplot),1,3);
      if i<N
        im(1,i,:) = [.9 .2 .2];
      end
    else
      im(1,1:N,:) = repmat(probchannels(1:N,i_currplot),1,3); 
    end
    set(probchannelhandles{i_currplot},'CData',im);
  end
  drawnow;
end
if i==N
  for i_currplot = 1:ndatachannels
    set(datachannelfillhandles{i_currplot},'Visible','off')
  end
end
