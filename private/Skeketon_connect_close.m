function [S_skel,S_radii] = Skeketon_connect_close(S_skel, S_radii,CropSize)


gap_length = 10;
gap_length_big = 40;
[sphere_mask, cubic_path,~] = Pre_cal_length(gap_length);
%load sphr_20.mat
[sphere_mask_big, cubic_length_big] = Pre_cal_mask(gap_length_big);


tic
[sum_nh_full] = get_all_sum_nh_par(S_skel,CropSize);
Endnode.name = find( sum_nh_full == 2 );

[xxx,yyy,zzz] = ind2sub(CropSize,S_skel);

cubic_size = size(sphere_mask);
cubic_center_ind = ceil(length(sphere_mask(:))./2);

cubic_size_big = size(sphere_mask_big);
cubic_center_big_ind = ceil(length(sphere_mask_big(:))./2);

parfor ii = min(zzz):max(zzz)
    filter = zzz == ii;
    xxx_per_z{ii} = xxx(filter);
    yyy_per_z{ii} = yyy(filter);
end



[center_xxx, center_yyy, center_zzz] = ind2sub(CropSize, S_skel(Endnode.name));


dest_skel = zeros(size(Endnode.name));

parfor ii = 1:length(Endnode.name)
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
        [min_length, loc] = min(cubic_length_big(cubic_skel));
        if min_length < gap_length
            [dest_xxx, dest_yyy, dest_zzz] = ind2sub(cubic_size_big, cubic_skel(loc));
            path_ind = cubic_path{sub2ind(cubic_size, dest_xxx-(gap_length_big-gap_length), dest_yyy-(gap_length_big-gap_length), dest_zzz-(gap_length_big-gap_length))};
            %path_ind = cubic_path{cubic_skel(loc)};
            [path_xxx, path_yyy, path_zzz] = ind2sub(cubic_size, path_ind);
            path_xxx = path_xxx + (center_xxx(ii) - gap_length -1);
            path_yyy = path_yyy + (center_yyy(ii) - gap_length -1);
            path_zzz = path_zzz + (center_zzz(ii) - gap_length -1);
            
            skel_to_add_par{ii} = sub2ind(CropSize, path_xxx, path_yyy, path_zzz);
            
            dest_xxx = dest_xxx + (center_xxx(ii) - gap_length_big -1);
            dest_yyy = dest_yyy + (center_yyy(ii) - gap_length_big -1);
            dest_zzz = dest_zzz + (center_zzz(ii) - gap_length_big -1);
            dest_skel(ii) = sub2ind(CropSize, dest_xxx, dest_yyy, dest_zzz);
            %            [~,loc] = ismember( sub2ind(CropSize, dest_xxx, dest_yyy, dest_zzz),S_skel);
            
            %            radii_to_add_par{ii}(1:length(skel_to_add_par{ii})) = mean([S_radii(Endnode.name(ii)), S_radii(loc)]);
        else
            skel_to_add_par{ii} = [];
            %            radii_to_add_par{ii} = [];
            
        end
    else
        skel_to_add_par{ii} = [];
        %        radii_to_add_par{ii} = [];
    end
end

[~,loc] = ismember(dest_skel,S_skel);


ind_loc = find(loc);



for ii = 1:length(ind_loc)
    iii = ind_loc(ii);
    radii_to_add_par{iii}(1:length(skel_to_add_par{iii})) = mean([S_radii(Endnode.name(iii)), S_radii(loc(iii))]);
    
end


skel_to_add = double(cell2mat(skel_to_add_par)');
radii_to_add = cell2mat(radii_to_add_par)';

skel_to_add = [skel_to_add radii_to_add];
skel_to_add = [skel_to_add; double(S_skel), S_radii];

skel_to_add = sortrows(skel_to_add,1);

[~,filter_unq] = unique(skel_to_add(:,1));
skel_to_add = skel_to_add(filter_unq,:);

S_skel = uint64(skel_to_add(:,1));
S_radii = skel_to_add(:,2);
toc