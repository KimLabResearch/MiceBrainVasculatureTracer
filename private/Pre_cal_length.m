function [sphere_mask, cubic_path,cubic_length] = Pre_cal_length(gap_length)


cubic_size = 2.*gap_length+1;
cubic_ind = ones(cubic_size,cubic_size,cubic_size) ;

cubic_ind(:) = find(cubic_ind);
[cubic_xxx, cubic_yyy, cubic_zzz] = ind2sub(size(cubic_ind),cubic_ind(:));

cubic_length = zeros(cubic_size,cubic_size,cubic_size) ;
cubic_length(:) = sqrt((cubic_xxx-(gap_length+1)).^2+(cubic_yyy-(gap_length+1)).^2+(cubic_zzz-(gap_length+1)).^2);

sphere_mask = (cubic_length <=gap_length);

cubic_CropSize = size(cubic_ind);
goodLinkTable = getAllLinks_v3(cubic_ind(:),cubic_CropSize);

distance_table = [3 2 3 2 1 2 3 2 3 2 1 2 1 0 1 2 1 2 3 2 3 2 1 2 3 2 3 ];
distance_table = sqrt(distance_table)';
goodLinkTable(:,3) = distance_table(goodLinkTable(:,3));

cubic_graph = graph(goodLinkTable(:,1),goodLinkTable(:,2),goodLinkTable(:,3));
center_node = ceil(length(cubic_ind(:))./2);

parfor ii = 1:length(cubic_ind(:))
    cubic_path{ii} = shortestpath(cubic_graph,center_node,ii);
    cubic_path{ii} = cubic_path{ii}(cubic_path{ii}~= center_node & cubic_path{ii}~= ii);
end