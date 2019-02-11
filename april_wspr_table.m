function [aprtime] = april_wspr_table(data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
aprtime=datevec((cell2mat(data)/86400)+datenum('01-Jan-1970'));

end

