function [useful_end_node,quality_ratio] = find_useful_end_node(S_skel, CropSize, region_size, cut_off_ratio)



check_region_size = ceil(CropSize./region_size);


[sum_nh_full] = get_all_sum_nh_par(S_skel,CropSize);

wierdNode.name = find(sum_nh_full == 2 );


[xxx, yyy, zzz] = ind2sub(CropSize,S_skel);


xxx = ceil(xxx./region_size);
yyy = ceil(yyy./region_size);
zzz = ceil(zzz./region_size);


A = accumarray([xxx, yyy, zzz],1);

clear xxx yyy zzz

node_count = zeros(check_region_size');
node_count(1:size(A,1), 1:size(A,2), 1:size(A,3)) = A;    

[wierdNode.xxx, wierdNode.yyy, wierdNode.zzz] = ind2sub(CropSize,S_skel(wierdNode.name));


wierdNode.xxx = ceil(wierdNode.xxx./region_size);
wierdNode.yyy = ceil(wierdNode.yyy./region_size);
wierdNode.zzz = ceil(wierdNode.zzz./region_size);



A = accumarray([wierdNode.xxx, wierdNode.yyy, wierdNode.zzz],1);
quality_ratio = zeros(check_region_size');
quality_ratio(1:size(A,1), 1:size(A,2), 1:size(A,3)) = A;        
   


quality_ratio = quality_ratio./node_count;

quality_ratio(isnan(quality_ratio)) = 1;

node_ind = sub2ind(size(quality_ratio),wierdNode.xxx, wierdNode.yyy, wierdNode.zzz);
wierdNode.area_quality_ratio = quality_ratio(node_ind  );

useful_end_node.name = wierdNode.name(wierdNode.area_quality_ratio < cut_off_ratio);





