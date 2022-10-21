function b = mavgz(x,window,type)

% b = mavgz(x,window,[type])
%
% Moving average smoothing of data. The window function is
% uniform, triangular, or the expansion of (.5 + .5)^2k. As
% the mavg function, but zeros are treated as breaks in the
% data. Consecutive sequences of non-zero values are
% processed independently.
%
% Multiple columns are treated independently.
%
% INPUTS:
%  x : vector of data
%  window : the width of the window function - should be odd
%   (default: 3)
%  type : shape of the window function -
%           'rect'  : rectangular (default)
%           'tri'   : triangular
%           'smooth': expansion of (.5 + .5)^2k, approximates 
%                     a gaussian for large k

if nargin < 3
  type ='rect';
end

if nargin < 2
  window = 3;
end

b = zeros(size(x));

for i=1:size(x,2)
  b(:,i) = mavgz_singlechannel(x(:,i),window,type);
end



function b = mavgz_singlechannel(x,window,type)

% make sure the window is odd
window = 2*floor(window/2) + 1;
halfwindow = window/2 - .5;

% calculate the moving average coefficients
f = zeros(window,1);

if strcmp(type,'rect')
  f = ones(window,1)/window;
elseif strcmp(type,'tri')
  f = [(1:halfwindow+1)'; (halfwindow:-1:1)'];
  f = f / sum(f);
elseif strcmp(type,'smooth')
  a = toeplitz([.25 .5 .25 zeros(1,window-3)],[.25 zeros(1,window-1)]);
  f = [.25 .5 .25 zeros(1,window-3)]';
  f = a^(halfwindow-1) * f;
else
  error('Unknown window type');
end

% smoothing

nonzeroindices = find(x~=0);
segments = zerodelimitedarraytocell(x);
for j=1:length(segments)
  segments{j} = applywindow(segments{j},halfwindow,f);
end
concatsegments = cellconcat(segments);
x(nonzeroindices) = concatsegments;
b = x;

function b = applywindow(x,halfwindow,f)
b = x;
if find(b)>0
for i=halfwindow+1:length(x)-halfwindow-1
  b(i) = x(i-halfwindow:i+halfwindow)' * f;
end 
end

