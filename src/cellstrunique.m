function c = cellstrunique(strs)

% CELLSTRUNIQUE Given a cell of strings, return a new cell without any repretitions.

c = {};

for i_str = 1:length(strs)
  currstr = strs{i_str};
  if isempty(cellstrfind(c,currstr))
    c = cellappend(c,{currstr});
  end
end

