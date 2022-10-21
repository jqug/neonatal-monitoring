function a = arima2ar(b)

% a = arima2ar(b)
%
% Convert the coefficients of an ARIMA(p,1,0) model to a
% nonstationary AR(p+1) model.

p = length(b);

switch p
  case 1
    a = [b(1)+1 -b(1)];
  case 2
    a = [b(1)+1 b(2)-b(1) -b(2)]; 
  otherwise
    a = [b(1)+1 ([b(2:end) 0] - b(1:end))];     
end;
