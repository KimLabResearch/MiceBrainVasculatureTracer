
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
core_count =8;



%dir_in = uigetdir('D:\', 'skeleton folder');
dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonized';

%dir_tif = uigetdir('D:\', 'binarized folder');
dir_tif = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';

%dir_radii = uigetdir('D:\', 'radii folder');
dir_radii = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\radii';

labelImageFile = 'half.tif';
regionID = 22; 
%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF
size_factor = [10 10 10];
trimThickness = 3;  %% 10 um per integer, trim the volume down to avoid boundary vassels

trimlevel = 20; %% 1um per integer, trim the isolated end branches that is short

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('making mask \n')

tic

imLabel = extractRegionFromLabel(labelImageFile, regionID, 1);
imLabel = logical(imLabel);
toc

fprintf('making croped mask \n')

tic
[imLabel, CropPoint_downsize, CropRange_downsize] = makingCropMask (imLabel,size_factor,trimThickness);
CropPoint = CropPoint_downsize .* size_factor;

CropSize = size(imLabel).*size_factor;

CropRange = [CropPoint(1),CropPoint(1)+CropSize(1)-1 ;
             CropPoint(2),CropPoint(2)+CropSize(2)-1 ;
             CropPoint(3),CropPoint(3)+CropSize(3)-1 ];       



toc             
%%


fprintf('Reading image \n');
DirTif = dir([dir_tif '/*.tif']);


FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage = length(InfoImage);
numberFiles = length(DirTif);

sizeImage = [nImage, mImage, lImage];
CropRange = CropRange+[0, 0; 0, 0; -sizeImage(3), -sizeImage(3)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +[0 0 -sizeImage(3)] only because I skipped 50 um when doing interpolation

tic
[S_skel, S_radii] = ReadKim_Radii(dir_in, dir_radii, sizeImage,CropRange,CropSize);


toc

tic
imLabelL = logical(imresize3(imLabel,size_factor(1), 'Method','nearest'));
S_radii = S_radii(imLabelL(S_skel));
S_skel =S_skel(imLabelL(S_skel));
clear imLabelL


S_radii = sqrt(S_radii);

toc



[S_skel, S_radii] = trimEdges(S_skel, S_radii, CropSize,trimlevel);

[S_link_giantTable, S_node_Table, NodeList] = getAllLinks_super_calculator2(S_skel,S_radii,CropSize);


averageRadii = sum(S_link_giantTable(:,3).*S_link_giantTable(:,9))./sum(S_link_giantTable(:,9)); 

[link_list, ia, ic] = unique(S_link_giantTable(:,4));


segment_Length = zeros(length(link_list),1);
segment_Radii = zeros(length(link_list),1);
parfor ii = 1:length(link_list)
    
    flagS = S_link_giantTable(:,4)==link_list(ii);
    segment_Length(ii) = sum(S_link_giantTable(flagS,9));
    segment_Radii(ii) = sum(S_link_giantTable(flagS,3).*S_link_giantTable(flagS,9))./sum(S_link_giantTable(flagS,9)); 
    
end



figure()
[xxx, yyy, zzz] = ind2sub(CropSize, S_link_giantTable(:,2));
color3 = [segment_Length(ic)./10 1-segment_Length(ic)./10 zeros(size(xxx))];
scatter3(xxx,yyy,zzz,S_link_giantTable(:,3).*3, color3,'filled');
hold

[xxx, yyy, zzz] = ind2sub(CropSize, S_node_Table(:,2));
color3 = [0 0 1];
scatter3(xxx,yyy,zzz,S_node_Table(:,3).*3, color3,'filled');

[xxx, yyy, zzz] = ind2sub(CropSize, NodeList.Link2One(:,2));
color3 = [1 0 1];
scatter3(xxx,yyy,zzz,10, color3,'filled');

hold
view(-30,10)
axis equal	
%{
figure()
[xxx, yyy, zzz] = ind2sub(CropSize, S_link_giantTable(:,2));
color3 = [segment_Radii(ic)./5 1-segment_Radii(ic)./5 zeros(size(xxx))];
scatter3(xxx,yyy,zzz,S_link_giantTable(:,3).*1.5, color3,'filled');
view(-30,10)
axis equal	




figure()
[xxx, yyy, zzz] = ind2sub(CropSize, S_skel);
color3 = [S_radii./5 1-S_radii./5 zeros(size(xxx))];
scatter3(xxx,yyy,zzz,S_radii.*1.5, color3,'filled');
view(-30,10)
axis equal	




figure()
[xxx, yyy, zzz] = ind2sub(CropSize, S_link_giantTable(:,2));
%color3 = [S_radii./5 1-S_radii./5 zeros(size(xxx))];
colorR = rand(length(xxx),3);
colorR = colorR(ic,:);
scatter3(xxx,yyy,zzz,S_link_giantTable(:,3).*2, colorR,'filled');
view(-30,10)
axis equal	

%}

