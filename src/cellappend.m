function c = cellappend(a,b)

% CELLAPPEND  Given an Ax1 cell and a Bx1 cell, return
%             and (A+B)x1 cell
%
% c = cellappend(a,b)

if ~iscell(b) 
  b = {b};
end
len_a = length(a);
len_b = length(b);
c = a;
for i_currelement = 1:len_b
  c{i_currelement+len_a} = b{i_currelement};  
end
