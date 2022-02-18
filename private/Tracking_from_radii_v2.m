
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
core_count =8;



dir_in = uigetdir('D:\', 'skeleton folder');
%dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonized';

dir_tif = uigetdir('D:\', 'binarized tif folder');
%dir_tif = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';

dir_radii = uigetdir('D:\', 'radii folder');
%dir_radii = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\radii';

%labelImageFile = 'half.tif';
[file1,path1] = uigetfile('D:\*.tif');
labelImageFile = [path1 file1];



regionID = 22;
%Visp = 385 %SomatoSensory = 453 %PTLp = 22
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF  %909 = ENT
% 549 = Thalamus  %375 = Ammon's horn
%485 = Striatum dorsal region


size_factor = [10 10 10];
trimThickness = 3;  %% 10 um per integer, trim the volume down to avoid boundary vassels

trimLevel = 30; %% 1um per integer, trim the isolated end branches that is short

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +[0 0 -sizeImage(3)] only because I skipped
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  50 um when doing interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



if CropRange(3,1) > numberFiles.*lImage
    CropRange(3,1) = numberFiles.*lImage;
end

if CropRange(3,2) > numberFiles.*lImage
    CropRange(3,2) = numberFiles.*lImage;
end
if CropRange(3,1) < 1
    CropRange(3,1) = 1;
end

if CropRange(3,2) < 1
    CropRange(3,2) = 1;
end

[S_skel, S_radii] = ReadKim_Radii(dir_in, dir_radii, sizeImage,CropRange,CropSize);





imLabelL = logical(imresize3(imLabel,size_factor(1), 'Method','nearest'));
S_radii = S_radii(imLabelL(S_skel));
S_skel =S_skel(imLabelL(S_skel));

total_Volume = nnz(imLabelL);

clear imLabelL


S_radii = sqrt(S_radii);




[S_link,  wierdNode, S_new] = trim_v2(S_skel,S_radii,CropSize,trimLevel);

[Slink_g1, Slink_g3] = calculat_length(S_link, S_new, CropSize);

list_link_group = unique(Slink_g1.group);
tic
for ii = 1:length(list_link_group)
    link_group.length(ii) = sum(Slink_g1.length(Slink_g1.group == list_link_group(ii)));
    link_group.length(ii) = link_group.length(ii) + sum(Slink_g3.length(Slink_g3.group == list_link_group(ii)));
    link_group.radii(ii) = sum(Slink_g1.radii(Slink_g1.group == list_link_group(ii)).*Slink_g1.length(Slink_g1.group == list_link_group(ii)));
    link_group.radii(ii) = link_group.radii(ii) + sum(Slink_g3.radii(Slink_g3.group == list_link_group(ii)).*Slink_g3.length(Slink_g3.group == list_link_group(ii)));
    link_group.radii(ii) = link_group.radii(ii)./link_group.length(ii);
    
end
toc
%figure()
%histogram(link_group.radii);
%figure()
%histogram(link_group.length);


%figure()
%scatter(link_group.radii,link_group.length)


total_length = sum(link_group.length);

length_density = total_length./total_Volume

total_R_L = sum(link_group.length.*link_group.radii);

total_R2_L_density = sum(link_group.length.*link_group.radii.*link_group.radii.*3.14159)./total_Volume


average_R = total_R_L./total_length

%node_group = [];
for ii = 1:length(Slink_g3.connected)
    node_group.connected(ii) = length(Slink_g3.connected(ii).name);
    
    
    
end

node_group.connected = node_group.connected(node_group.connected~=2);
%figure();
%histogram(node_group.connected);
node_count = histc(node_group.connected,[1 2 3 4 5 6 7 8])

regionID = num2str(regionID);
save([regionID '.mat'],  '-v7.3');



%{
figure()

[xxx, yyy, zzz] = ind2sub(CropSize, S_new.skel);
color3 = [S_new.radii./5 1-S_new.radii./5 zeros(size(xxx))];
scatter3(xxx,yyy,zzz,S_new.radii.*8.0, color3,'filled');


view(-30,10)
axis equal



figure()
[xxx, yyy, zzz] = ind2sub(CropSize, S_new.skel);
colorR = rand(length(S_skel),3);
colorR = colorR(S_new.group,:);
scatter3(xxx,yyy,zzz,S_new.radii.*8.0, colorR,'filled');
view(-30,10)
axis equal

%}

