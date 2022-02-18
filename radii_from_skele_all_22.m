
clear;

%%% Parallel control
% This part is only for HPC to distribute the parallel profiles
% coreCount :: number of cores per node

coreCount =22;
aa = parcluster
temp_folder = ['./matlab_cluster_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF')];
mkdir(temp_folder);
aa.JobStorageLocation = temp_folder;

parpool(aa,coreCount ,'IdleTimeout',inf)

%% General setting
% dir_in :: input folder
% dir_tif :: referencing folder for image size (from tif files)
% dir_out :: output folder
% PaddingRange :: maximum radii will be tried 

dir_in = [pwd '/skeletonized'];
dir_tif = [pwd '/binarized'];
dir_out = [pwd '/radii'];

mkdir(dir_out);
fprintf('Reading image \n');
DirTif = dir([dir_tif '/*.tif']);


FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage = length(InfoImage);
numberFiles = length(DirTif);

sizeImage = [nImage, mImage, lImage];


CropSize = sizeImage;

PaddingRange = 20;


% ReadKim_SK(dir_in,sizeImage,CropRange,CropSize)
%           :: read binarized file form 50 cut binaries
%              CropRange  = [x_lower, x_upper; y_lower, y_upper; z_lower, z_upper]
%              CropSize = [x, y, z]
% computeRdii(Size,S_skel,PaddingRange,S_all)
%           :: S_skel = skeleton
%              S_all = binarized image

parfor ii =1:numberFiles




CropPoint = [1 1 (ii-1).*lImage+1];

CropRange = [CropPoint(1),CropPoint(1)+CropSize(1)-1 ;
             CropPoint(2),CropPoint(2)+CropSize(2)-1 ;
             CropPoint(3),CropPoint(3)+CropSize(3)-1 ];       

tic
[S_skel] = ReadKim_SK(dir_in,sizeImage,CropRange,CropSize);



[S_all] = ReadKim_SK(dir_tif,sizeImage,CropRange,CropSize);



B_sk_rr = computeRdii(CropSize,S_skel,PaddingRange,S_all);

fileIndicator = [dir_out '/radii' num2str(ii,'%04d') '.bin' ];
fileID = fopen(fileIndicator,'w');
fwrite(fileID, uint64(B_sk_rr),'uint64');
fclose(fileID);
toc
end
