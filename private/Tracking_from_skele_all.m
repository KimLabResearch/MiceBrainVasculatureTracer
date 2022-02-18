
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
core_count =8;



%dir_in = uigetdir('Z:\', 'skeleton folder');
dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonized';

%dir_tif = uigetdir('Z:\', 'binarized folder');
dir_tif = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';



fprintf('Reading image \n');
DirTif = dir([dir_tif '/*.tif']);


FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage = length(InfoImage);
numberFiles = length(FileTif);

sizeImage = [nImage, mImage, lImage];

CropSize = sizeImage.* [1 1 numberFiles];
CropPoint = [1 1 1];

CropRange = [CropPoint(1),CropPoint(1)+CropSize(1)-1 ;
             CropPoint(2),CropPoint(2)+CropSize(2)-1 ;
             CropPoint(3),CropPoint(3)+CropSize(3)-1 ];       

tic
[S_skel] = ReadKim_SK(dir_in,sizeImage,CropRange,CropSize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +[0 0 -sizeImage(3)] only because I skipped 50 um when doing interpolation
toc

tic    
[goodLinkTable] = getAllLinks(S_skel,CropSize);
toc


C = unique(goodLinkTable(:,1:2));
S_skel = S_skel(C);


tic    
[goodLinkTable,nodes,endPoint,linksMidPoint] = getAllLinks(S_skel,CropSize);
toc


C = unique(goodLinkTable(:,1:2));
%S_skel = S_skel(C);





