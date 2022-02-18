
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
core_count =8;



%dir_in = uigetdir('Z:\', 'skeleton folder');
dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonized';

%dir_tif = uigetdir('Z:\', 'binarized folder');
dir_tif = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';

labelImageFile = 'half.tif';
regionID = 453; 
%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF
size_factor = [10 10 10];
trimThickness = 0;  %% 10 um per integer

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
numberFiles = length(FileTif);

sizeImage = [nImage, mImage, lImage];
CropRange = CropRange+[0, 0; 0, 0; -sizeImage(3), -sizeImage(3)];
tic
[S_skel] = ReadKim_SK(dir_in,sizeImage,CropRange,CropSize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  +[0 0 -sizeImage(3)] only because I skipped 50 um when doing interpolation


toc

tic
imLabelL = logical(imresize3(imLabel,size_factor(1), 'Method','nearest'));
S_skel =S_skel(imLabelL(S_skel));
clear imLabelL

toc
%clear imLabelL


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





