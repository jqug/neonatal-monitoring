function indices = cellstrfind(c,str)

% indices = cellstrfind(c,str)

indices = [];
for i_cell = 1:length(c)
    if strcmp(c{i_cell},str)
        indices = [indices i_cell];
    end
end