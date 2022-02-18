function [out_pair] = Skeketon_connect_far(S_skel, S_radii, CropSize ,useful_end_node,gap_length_big)



[sphere_mask_big, cubic_length_big] = Pre_cal_mask(gap_length_big);


[xxx,yyy,zzz] = ind2sub(CropSize,S_skel(useful_end_node.name));

cubic_size_big = size(sphere_mask_big);
cubic_center_big_ind = ceil(length(sphere_mask_big(:))./2);

parfor ii = min(zzz):max(zzz)
    filter = zzz == ii;
    xxx_per_z{ii} = xxx(filter);
    yyy_per_z{ii} = yyy(filter);
end

[center_xxx, center_yyy, center_zzz] = ind2sub(CropSize, S_skel(useful_end_node.name));

dest_skel = zeros(size(useful_end_node.name));

parfor ii = 1:length(useful_end_node.name)
    cubic_skel = [];
    for zz = center_zzz(ii)-gap_length_big:center_zzz(ii)+gap_length_big
        if zz>=1 && zz<=length(yyy_per_z)
            filter = xxx_per_z{zz} >= center_xxx(ii) - gap_length_big & xxx_per_z{zz} <= center_xxx(ii) + gap_length_big & ...
                yyy_per_z{zz} >= center_yyy(ii) - gap_length_big & yyy_per_z{zz} <= center_yyy(ii) + gap_length_big;
            xxx_in = xxx_per_z{zz}(filter) - (center_xxx(ii) - gap_length_big -1);
            yyy_in = yyy_per_z{zz}(filter) - (center_yyy(ii) - gap_length_big -1);
            
            cubic_skel = [cubic_skel; sub2ind(cubic_size_big, xxx_in, yyy_in, (zz-center_zzz(ii)+gap_length_big+1).*ones(size(yyy_in)))];
        end
    end
    
    cubic_skel = cubic_skel(sphere_mask_big(cubic_skel));
    cubic_link = getAllLinks_v2(cubic_skel,cubic_size_big);
    cubic_group = grouping_remake(length(cubic_skel), cubic_link);
    cubic_skel = cubic_skel(cubic_group ~= cubic_group(cubic_skel == cubic_center_big_ind));
    if ~isempty(cubic_skel)
        [~, loc] = min(cubic_length_big(cubic_skel));
        [dest_xxx, dest_yyy, dest_zzz] = ind2sub(cubic_size_big, cubic_skel(loc));
        
        
        dest_xxx = dest_xxx + (center_xxx(ii) - gap_length_big -1);
        dest_yyy = dest_yyy + (center_yyy(ii) - gap_length_big -1);
        dest_zzz = dest_zzz + (center_zzz(ii) - gap_length_big -1);
        dest_skel(ii) = sub2ind(CropSize, dest_xxx, dest_yyy, dest_zzz);
        
        
        
    end
end

[~,dest_name] = ismember(dest_skel,S_skel);


out_pair.one = useful_end_node.name(dest_name ~= 0);
out_pair.two = dest_name;
