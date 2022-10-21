function newtime = formattime(time);

% FORMATTIME   Generate standard time format.
%    NEWTIME = FORMATTIME(TIME) checks that TIME is a character array
%    in an available time format, for example 8:45:12 or 09:20, and
%    returns its unified time HH:MM:SS in NEWTIME.
%
%    TIME can be in the following formats: HH:MM:SS, H:MM:SS, HH:MM or
%    H:MM.
%
%    Copyright (C) 2003  Alexander Spengler.

%    This program is free software; you can redistribute it and/or
%    modify it under the terms of the GNU General Public License
%    as published by the Free Software Foundation; either version 2
%    of the License, or (at your option) any later version.
% 
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
% 
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


noerror = 1;
ndigits = size(time,2);
switch ndigits

% HH:MM:SS    
case 8, 
    if ~(isequal(time(3), ':') & isequal(time(6), ':'))
        noerror = 0;
        break;
    end
    
    if ~((str2num(time(4)) >= 0) & (str2num(time(4)) <= 5) & ...
            (str2num(time(7)) >= 0) & (str2num(time(7)) <= 5))
        noerror = 0;
        break;
    end
    
    if isequal(time(1), '0') | isequal(time(1), '1')
    elseif isequal(time(1), '2')
        if ~(((str2num(time(2)) >= 0) & (str2num(time(2)) <= 3)) | ...
                ((str2num(time(2)) == 4) & isequal(time(3:8), ':00:00')))
            noerror = 0;
        end
    else
        noerror = 0;
    end        
    newtime = time;

% H:MM:SS    
case 7,
    if ~(isequal(time(2), ':') & isequal(time(5), ':'))
        noerror = 0;
        break;
    end
    
    if ~((str2num(time(3)) >= 0) & (str2num(time(3)) <= 5) & ...
            (str2num(time(6)) >= 0) & (str2num(time(6)) <= 5))
        noerror = 0;
        break;
    end
    newtime = ['0' time];
    
% HH:MM    
case 5,
    if ~isequal(time(3), ':')
        noerror = 0;
        break;
    end
    
    if ~((str2num(time(4)) >= 0) & (str2num(time(4)) <= 5))
        noerror = 0;
        break;
    end
    
    if isequal(time(1), '0') | isequal(time(1), '1')
    elseif isequal(time(1), '2')
        if ~(((str2num(time(2)) >= 0) & (str2num(time(2)) <= 3)) | ...
                ((str2num(time(2)) == 4) & isequal(time(3:5), ':00')))
            noerror = 0;
        end
    else
        noerror = 0;
    end        
    newtime = [time ':00'];
    
% H:MM    
case 4,
    if ~isequal(time(2), ':')
        noerror = 0;
        break;
    end
    
    if ~((str2num(time(3)) >= 0) & (str2num(time(3)) <= 5))
        noerror = 0;
        break;
    end
    newtime = ['0' time ':00'];
    
% Other time formats are currently not permitted.    
otherwise, 
    noerror = 0;
end

if ~noerror
    error(['Time format incorrect: ' time]);
end
