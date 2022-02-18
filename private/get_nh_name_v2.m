function [nh_name,goodLinkTable] = get_nh_name_v2(S_skel,CropSize,name,filter_name)

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


nh_name = zeros(length(S_skel),26);

goodLinkTable2 = [goodLinkTable(:,2) goodLinkTable(:,1)];
goodLinkTable2 = sortrows(goodLinkTable2);

list13 = false(length(goodLinkTable),13);
selfLink = (1:1:length(goodLinkTable))';
for ii = 1:1:13
    list13(mod(selfLink,13)==ii-1,ii) = 1;
end


for ii =1:1:13
    nh_name(goodLinkTable(list13(:,ii),1),ii) = goodLinkTable(list13(:,ii),2);
    nh_name(goodLinkTable2(list13(:,ii),1),ii+13) = goodLinkTable2(list13(:,ii),2);
end

nh_name(logical(nh_name(:))) = name(nh_name(logical(nh_name(:))));


nh_name = sort(nh_name,2,'descend');
nh_name = nh_name(:,1:13);

nh_name = nh_name(ismember(name,filter_name),:);

goodLinkTable(:,1) = name(goodLinkTable(:,1));
goodLinkTable(:,2) = name(goodLinkTable(:,2));    
%{
for ii = 1:size(nh_name,1)
    
    nh_name2{ii} = nh_name(ii,nh_name(ii,:)~=0);
end
%}