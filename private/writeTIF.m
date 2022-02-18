
clear all;
close all;
core_count =8;



%dir_in = uigetdir('D:\', 'skeleton folder');
dir_in = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonized';

%dir_tif = uigetdir('D:\', 'binarized folder');
dir_tif = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\Binarized';

%dir_out = uigetdir('D:\', 'binarized folder');
dir_out = 'D:\20190221_UC_U318_CN2_WT_FITC-fill_0.1p_10mL_p67_F_optical\skeletonTIF';






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

parfor ii = 2:numberFiles-1
    CropPoint = [0 0 (ii-1).*sizeImage(3)];
    CropRange = [CropPoint(1),CropPoint(1)+sizeImage(1)-1 ;
                 CropPoint(2),CropPoint(2)+sizeImage(2)-1 ;
                 CropPoint(3),CropPoint(3)+sizeImage(3)-1 ];         
    [skelAll] = ReadKim_SK(dir_in,sizeImage,CropRange,sizeImage);    
    im = false(sizeImage);
    im(skelAll) = 1;
    fname = [dir_out  '/skeleton_Z'  num2str(ii,'%04d')  '.tif'];
    imwritestack(im, fname);
    
end

