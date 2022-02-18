function [link_table_full] = get_all_link_par(S_skel,CropSize)

[~, ~, zz] = ind2sub(CropSize,S_skel);

cut_size = 50;
total_cut = ceil(max(zz)./ cut_size);

parfor ii = 1:total_cut
    
    S_skel_par{ii} = S_skel(zz > (ii-1).*cut_size & zz <= ii.*cut_size+1  )- CropSize(1).*CropSize(2).*((ii-1).*cut_size);
    zz_par{ii} = zz(zz > (ii-1).*cut_size & zz <= ii.*cut_size+1 );
    id_par{ii} = find(zz > (ii-1).*cut_size & zz <= ii.*cut_size+1 );

end

CropSize_par = [CropSize(1) CropSize(2) (cut_size+2) ];

parfor ii = 1:total_cut
    good_link_table_par{ii} = getAllLinks_v2(S_skel_par{ii},CropSize_par);
    good_link_table_par{ii} = good_link_table_par{ii}(zz_par{ii}(good_link_table_par{ii}(:,1))> (ii-1).*cut_size & zz_par{ii}(good_link_table_par{ii}(:,1))<=ii.*cut_size,:);
    %S_skel_par{ii} = S_skel_par{ii} + CropSize(1).*CropSize(2).*((ii-1).*cut_size-1);
    good_link_table_par{ii}(:,1) = id_par{ii}(good_link_table_par{ii}(:,1));
    good_link_table_par{ii}(:,2) = id_par{ii}(good_link_table_par{ii}(:,2));
    
    

end

link_table_full = [];
for ii = 1:total_cut
    
    link_table_full = [link_table_full; good_link_table_par{ii}];
    
end



