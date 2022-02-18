function [S_link_giantTable, S_node_Table, NodeList] = getAllLinks_super_calculator2(S_skel,S_radii,CropSize)
tic
%{
[xskel, yskel, zskel] = ind2sub(CropSize,S_skel);
xskel = xskel + 1;
yskel = yskel + 1;
zskel = zskel + 1;
CropSize2 = CropSize + [2 2 2];


S_skel_pad=sub2ind(CropSize2,xskel,yskel,zskel);
%skel = false(CropSize2);
%skel(S_skel_pad) = 1;


% 26-nh of all canal voxels
%nh = logical(pk_get_nh(skel,list_canal));

[x,y,z]=ind2sub(CropSize2,S_skel_pad);

nh = false(length(S_skel_pad),27);
nhi = zeros(length(S_skel_pad),27);



parfor zzz = 2:max(z)
    selectByZzz = z == zzz;
    selectByZzzPad = (z >= zzz-1) & (z <= zzz+1);
    skel = false(CropSize2(1),CropSize2(2),3);
    skel(S_skel_pad(selectByZzzPad)-CropSize2(1).*CropSize2(2).*(zzz-2)) = 1;
    nhZZZ{zzz} = false(size(S_skel_pad(selectByZzz),1),27);
    nhiZZZ{zzz} = zeros(size(S_skel_pad(selectByZzz),1),27);
for zz=1:3
    for yy=1:3
        for xx=1:3
            ww=sub2ind([3 3 3],xx,yy,zz);
            nhiZZZ{zzz}(:,ww) = sub2ind(CropSize2,x(selectByZzz)+xx-2,y(selectByZzz)+yy-2,z(selectByZzz)+zz-2);
            nhZZZ{zzz}(:,ww) = skel(nhiZZZ{zzz}(:,ww)-CropSize2(1).*CropSize2(2).*(zzz-2));
            
        end
    end
end

end

ii = 1;
for zzz = 2:max(z)
    if size(nhiZZZ{zzz},1) ~=0
    nhi(ii:ii+size(nhiZZZ{zzz},1)-1,:) = nhiZZZ{zzz};
    nh(ii:ii+size(nhiZZZ{zzz},1)-1,:) = nhZZZ{zzz};
    ii = ii+size(nhiZZZ{zzz},1);
    end
end

%}
[nhi,nh] = get_nh_save_memory(S_skel,CropSize);

selfList = (1:1:length(nh))';

%linkListUp = [];
%linkListDown = [];

%for ii = 1:13
%    linkListUpTemp = [selfList S_skel];
%    linkListUpTemp = linkListUpTemp(nh(:,ii+14),:);
%    linkListUp = [linkListUp; linkListUpTemp];
%    
%    linkListDownTemp = [selfList S_skel nhi(:,ii) distNh(:,ii)];
%    linkListDownTemp = linkListDownTemp(nh(:,ii),:);
%    linkListDown = [linkListDown; linkListDownTemp];
%end


%linkListDownSort = sortrows(linkListDown,3);
%linkListUpSort = sortrows(linkListUp,2);

%goodLinkTable = [linkListUpSort(:,1) linkListDownSort(:,1) linkListUpSort(:,2) linkListDownSort(:,2) linkListDownSort(:,4)];
clear linkList*

% # of 26-nb of each skel voxel + 1
sum_nh = sum(logical(nh),2);



NodeList.Link2One = [selfList(sum_nh==2) S_skel(sum_nh==2)];
NodeList.Link2Two =[selfList(sum_nh==3) S_skel(sum_nh==3)];
NodeList.Link2Three = [selfList(sum_nh==4) S_skel(sum_nh==4)];
NodeList.Link2Four = [selfList(sum_nh==5) S_skel(sum_nh==5)];
NodeList.Link2FiveAndMore = [selfList(sum_nh>5) S_skel(sum_nh>5)];
NodeList.nodes = [selfList(sum_nh>3) S_skel(sum_nh>3)];



flagS = false(length(S_skel),1);
flagS(NodeList.nodes(:,1)) = 1;

S_name_node = find(flagS);
S_skel_node = S_skel(flagS);
S_radii_node = S_radii(flagS);
S_sum_nh_node = sum_nh(flagS);



flagS = false(length(S_skel),1);
flagS(NodeList.Link2Two(:,1)) = 1;

S_name_Link = find(flagS);
S_skel_Link = S_skel(flagS);
S_radii_Link = S_radii(flagS);


[goodLinkTable_Link] = getAllLinks_save_memory(S_skel_Link,CropSize);
S_group_link = grouping(S_skel_Link, goodLinkTable_Link);

S_group_link = S_name_Link(S_group_link);



nh_link = zeros(length(S_skel_Link),2);
S_link = zeros(length(S_skel_Link),8);

nh = [nh(:,1:13) nh(:,15:27)];
nhi = [nhi(:,1:13) nhi(:,15:27)];
ww = 1:1:27;
ww = [ww(:,1:13) ww(:,15:27)];


for ii = 1:length(S_skel_Link)
    nh_link(ii,:) = find(nh(S_name_Link(ii),:));
    S_link(ii,1) = nhi(S_name_Link(ii),nh_link(ii,1));
    S_link(ii,2) = nhi(S_name_Link(ii),nh_link(ii,2));
    S_link(ii,3) = ww(nh_link(ii,1));
    S_link(ii,4) = ww(nh_link(ii,2));
    
end


[xx1, yy1, zz1] = ind2sub([3 3 3], S_link(:,3));
[xx2, yy2, zz2] = ind2sub([3 3 3], S_link(:,4));

S_link(:,5) = sqrt((xx1-xx2).*(xx1-xx2) + (yy1-yy2).*(yy1-yy2) + (zz1-zz2).*(zz1-zz2))./2;
vector = [(xx1-xx2) (yy1-yy2) (zz1-zz2)];
vector(vector(:,1)<0,:) = -vector(vector(:,1)<0,:);
vector = vector./sqrt(vector(:,1).*vector(:,1)+vector(:,2).*vector(:,2)+vector(:,3).*vector(:,3));
S_link(:,6:8) = vector;


[link_list, ia, ic] = unique(S_group_link);



S_link2.radii = zeros(length(link_list),1);

for ii = 1:length(link_list)
    S_link2.radii(ii) = mean(S_radii_Link(S_group_link == link_list(ii)));
    S_link2.length(ii) = sum(S_group_link == link_list(ii));

end




S_link_giantTable = [S_name_Link S_skel_Link S_radii_Link S_group_link S_link];
S_node_Table = [S_name_node S_skel_node S_radii_node S_sum_nh_node];









toc