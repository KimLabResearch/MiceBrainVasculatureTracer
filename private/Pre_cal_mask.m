function [sphere_mask, cubic_length] = Pre_cal_mask(gap_length)


cubic_size = 2.*gap_length+1;
cubic_ind = ones(cubic_size,cubic_size,cubic_size) ;

cubic_ind(:) = find(cubic_ind);
[cubic_xxx, cubic_yyy, cubic_zzz] = ind2sub(size(cubic_ind),cubic_ind(:));

cubic_length = zeros(cubic_size,cubic_size,cubic_size) ;
cubic_length(:) = sqrt((cubic_xxx-(gap_length+1)).^2+(cubic_yyy-(gap_length+1)).^2+(cubic_zzz-(gap_length+1)).^2);

sphere_mask = (cubic_length <=gap_length);
