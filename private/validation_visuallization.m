
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

%dir_out = uigetdir('D:\', 'radii folder');
dir_out = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\visual_dump';

labelImageFile = 'half.tif';
regionID = 22; 
%Visp = 385 %SomatoSensory = 453 %PTLp = 22 
%SSp-n = 353  %91 = PIR %703 = CTXsp
% 698 = OLF
size_factor = [10 10 10];
trimThickness = 3;  %% 10 um per integer, trim the volume down to avoid boundary vassels

trimlevel = 20; %% 1um per integer, trim the isolated end branches that is short
z_cut = 100;
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
[S_binarized] = ReadKim_SK(dir_tif,sizeImage,CropRange,CropSize);
S_binarized =S_binarized(imLabelL(S_binarized));
clear imLabelL


S_radii = sqrt(S_radii);

toc



[S_skel, ~] = trimEdges(S_skel, S_radii, CropSize,trimlevel);


tot_Stack = ceil(CropSize(3)./z_cut);

[~,~,zz_skel] = ind2sub(CropSize,S_skel);
[~,~,zz_binarized] = ind2sub(CropSize,S_binarized);



parfor ii = 1:tot_Stack
    S_skel_stack = S_skel(zz_skel>(ii-1).*z_cut & zz_skel<=(ii).*z_cut)-(ii-1).*z_cut.*CropSize(1).*CropSize(2);    
    im = false([CropSize(1) CropSize(2) z_cut]);
    im(S_skel_stack) = 1;
    fname = [dir_out  '/skeleton_Z'  num2str(ii,'%04d')  '.tif'];
    imwritestack(im, fname);

    S_binarized_stack = S_binarized(zz_binarized>(ii-1).*z_cut & zz_binarized<=(ii).*z_cut)-(ii-1).*z_cut.*CropSize(1).*CropSize(2);    
    im = false([CropSize(1) CropSize(2) z_cut]);
    im(S_binarized_stack) = 1;
    fname = [dir_out  '/binarized_Z'  num2str(ii,'%04d')  '.tif'];
    imwritestack(im, fname);
    
end





















