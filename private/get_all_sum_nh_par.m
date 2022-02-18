function [sum_nh_full] = get_all_sum_nh_par(S_skel,CropSize)

[~, ~, zz] = ind2sub(CropSize,S_skel);

cut_size = 50;
total_cut = ceil(max(zz)./ cut_size);

parfor ii = 1:total_cut
    
    S_skel_par{ii} = S_skel(zz > (ii-1).*cut_size-1 & zz <= ii.*cut_size+1  )- (CropSize(1).*CropSize(2).*((ii-1).*cut_size-1));
    zz_par{ii} = zz(zz > (ii-1).*cut_size-1 & zz <= ii.*cut_size+1 );
    id_par{ii} = find(zz > (ii-1).*cut_size-1 & zz <= ii.*cut_size+1 );
    
end

CropSize_par = [CropSize(1) CropSize(2) (cut_size+2) ];

parfor ii = 1:total_cut
    [~,~,sum_nh_par{ii}] = get_sum_nh(S_skel_par{ii},CropSize_par);
    sum_nh_par{ii} = sum_nh_par{ii}(zz_par{ii}> (ii-1).*cut_size & zz_par{ii}<=ii.*cut_size);
    
end

sum_nh_full = [];
for ii = 1:total_cut
    
    sum_nh_full = [sum_nh_full; sum_nh_par{ii}];
    
end



