function [goodLinkTable] = getAllLinks_v3(S_skel,CropSize)

[nhi,nh] = get_nh_save_memory(S_skel,CropSize);

selfList = (1:1:size(nh,1))';

linkListUp = [];
linkListDown = [];

for ii = 1:13
    linkListUpTemp = [selfList S_skel nhi(:,ii+14) nh(:,ii+14).*ii+14];
    linkListUpTemp = linkListUpTemp(nh(:,ii+14),:) ;
    linkListUp = [linkListUp; linkListUpTemp];
    linkListDownTemp = [selfList S_skel nhi(:,ii)];
    linkListDownTemp = linkListDownTemp(nh(:,ii),:) ;
    linkListDown = [linkListDown; linkListDownTemp];
end
list1 = unique(linkListUp(:,3));
list1 = sort(list1);
list2 = unique(linkListDown(:,2));
list2 = sort(list2);
[~, loc] = ismember(linkListUp(:,3),list1);

linkListUp(:,3) = list2(loc);

[~, loc] = ismember(linkListUp(:,3),linkListDown(:,2));

linkListUp(:,3) = linkListDown(loc,1);


goodLinkTable = [linkListUp(:,1) linkListUp(:,3) linkListUp(:,4)];


