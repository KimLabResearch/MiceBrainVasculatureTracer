function [goodLinkTable,Link2One,Link2Two,nodes] = getAllLinks_save_memory(S_skel,CropSize)

[nhi,nh] = get_nh_save_memory(S_skel,CropSize);

selfList = (1:1:length(nh))';

linkListUp = [];
linkListDown = [];

for ii = 1:13
    linkListUpTemp = [selfList S_skel nhi(:,ii+14)];
    linkListUpTemp = linkListUpTemp(nh(:,ii+14),:) ;
    linkListUp = [linkListUp; linkListUpTemp];
    linkListDownTemp = [selfList S_skel nhi(:,ii)];
    linkListDownTemp = linkListDownTemp(nh(:,ii),:) ;
    linkListDown = [linkListDown; linkListDownTemp];
end


linkListDownSort = sortrows(linkListDown,3);
linkListUpSort = sortrows(linkListUp,2);

goodLinkTable = [linkListUpSort(:,1) linkListDownSort(:,1) linkListUpSort(:,2) linkListDownSort(:,2)];
clear linkList*

% # of 26-nb of each skel voxel + 1
sum_nh = sum(logical(nh),2);



Link2One = [selfList(sum_nh==2) S_skel(sum_nh==2)];
Link2Two =[selfList(sum_nh==3) S_skel(sum_nh==3)];
nodes = [selfList(sum_nh>3) S_skel(sum_nh>3)];



