function [apriltime] = april_wspr_csv(data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
apriltime=datevec((cell2mat(data)/86400)+datenum('01-Jan-1970'));

end

