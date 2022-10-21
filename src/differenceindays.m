function ndays = differenceindays(datestr1,datestr2)

% DIFFERENCEINDAYS  The difference between two date strings, to the nearest
% day.
% 
% Date strings can be of the format dd/mm/yy or dd/mm/yyyy

d1 = datestr1(1:2);
m1 = datestr1(4:5);
switch length(datestr1)
  case 8
    y1 = ['20' datestr1(7:8)];
  case 10
    y1 = datestr1(7:10);
  otherwise
    warning('Invalid date format');
    ndays=-1;
    return;
end

d2 = datestr2(1:2);
m2 = datestr2(4:5);
switch length(datestr2)
  case 8
    y2 = ['20' datestr2(7:8)];
  case 10
    y2 = datestr2(7:10);
  otherwise
    warning('Invalid date format');
    ndays=-1;
    return;    
end
    
ndays = abs(datenum([m1 '/' d1 '/' y1])-datenum([m2 '/' d2 '/' y2]));