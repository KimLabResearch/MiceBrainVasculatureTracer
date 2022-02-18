function [goodLinkTable] = getAllLinks_from_nh(S_skel,nhi,nh)


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
