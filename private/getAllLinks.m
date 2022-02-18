function [goodLinkTable,nodes,endPoint,linksMidPoint] = getAllLinks(S_skel,CropSize)

[xskel, yskel, zskel] = ind2sub(CropSize,S_skel);
xskel = xskel + 1;
yskel = yskel + 1;
zskel = zskel + 1;
CropSize2 = CropSize + [2 2 2];


S_skel_pad=sub2ind(CropSize2,xskel,yskel,zskel);
skel = false(CropSize2);
skel(S_skel_pad) = 1;


% 26-nh of all canal voxels
%nh = logical(pk_get_nh(skel,list_canal));

[x,y,z]=ind2sub(CropSize2,S_skel_pad);

nh = false(length(S_skel_pad),27);
nhi = zeros(length(S_skel_pad),27);
for zz=1:3
    for yy=1:3
        for xx=1:3
            ww=sub2ind([3 3 3],xx,yy,zz);
            nhi(:,ww) = sub2ind(CropSize2,x+xx-2,y+yy-2,z+zz-2);
            nh(:,ww)=skel(nhi(:,ww));
        end
    end
end


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

% all canal voxels with >2 nb are nodes
nodes = [selfList(sum_nh>3) S_skel(sum_nh>3)];

% all canal voxels with exactly one nb are end nodes
endPoint = [selfList(sum_nh==2) S_skel(sum_nh==2)];

% all canal voxels with exactly 2 nb
linksMidPoint =[selfList(sum_nh==3) S_skel(sum_nh==3)];
