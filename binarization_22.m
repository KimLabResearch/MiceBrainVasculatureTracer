
clear

%%% Parallel control
% This part is only for HPC to distribute the parallel profiles
% coreCount :: number of cores per node



coreCount =22;
aa = parcluster
temp_folder = ['./matlab_cluster_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF')];
mkdir(temp_folder);
aa.JobStorageLocation = temp_folder;

parpool(aa,coreCount ,'IdleTimeout',inf)


%%% Settings for background removal
% channel_1_ratio :: the constant for channel-1 deduction. image_out =
%                    image_ch_2 - channel_1_ratio*image_ch_1
%
% 'local ranking background removal' is done by substracting
%  a background image. The background image was created by
%  disk local ranking filter at 50% downsizing
%
% percentile :: percentage disk local ranking filter
% background_size :: disk size for local ranking filter
%
% cut_off_strength :: threshhold for binarization using image after 'local ranking background removal'
% cut_off_strength_2 :: threshhold for binarization using image before
%                       'local ranking background removal' to capture over-debackgrtound
%

channel_1_ratio = 0.8;
percentile = 0.35;
background_size = 8; %  x2 to get real radius
se = strel('disk',background_size);
domain = se.Neighborhood;

cut_off_strength = 500;
cut_off_strength_2 = 2000;


%% General setting
% dir_in :: input folder
% dir_out :: output folder
% DirTif :: sample image file name for the system to capture the size
% CropPoint :: discard images before this cordinate
% InterpolationLevel :: 5.0 means the result of intepolation will be 5
%                       times more dense
% IO-functions:
% ReadKimImage1(input_folder, reading_range, reding channel) 
%              :: function to read tifs from the lab file structure
%                 reading_range formate [x_lower, x_upper; y_lower, y_upper; z_lower, z_upper]
% imwritestack(image_data, file_name) 
%              :: function to write tif stack. 

dir_in = pwd;
dir_out = [pwd, '/binarized'];

DirTif = dir([dir_in '/ch1/*.tif']);
CropPoint = [1,1,10];
InterpolationLevel = 5.0;


mkdir(dir_out);
numberFiles = length(DirTif);
FileTif=[DirTif(1).folder '/' DirTif(1).name];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
lImage= length(InfoImage);
numImage = length(DirTif);
dir_in = strcat(dir_in, '/');




CropSize = [nImage mImage lImage.*numImage-20];
if mod(CropSize(1),2) == 1
    CropSize(1) = CropSize(1) - 1;
end

if mod(CropSize(2),2) == 1
    CropSize(2) = CropSize(2) - 1;
end

looping_size = floor(CropSize(3)./10);



z = InterpolationLevel:InterpolationLevel:InterpolationLevel.*13;
zz = 10:1:59;


for jj =1:looping_size
    
    
    tic
    loopCropPoint =  CropPoint + [0 0 10].*(jj-1) +[0 0 -1];
    loopCropSize = [CropSize(1) CropSize(2) 13];
    loopCropRange = [loopCropPoint(1),loopCropPoint(1)+loopCropSize(1)-1 ;
        loopCropPoint(2),loopCropPoint(2)+loopCropSize(2)-1 ;
        loopCropPoint(3),loopCropPoint(3)+loopCropSize(3)-1 ];
    tic
    [B_16int_1] = ReadKimImage1(dir_in, loopCropRange, 1);
    [B_16int_2] = ReadKimImage1(dir_in, loopCropRange, 2);
    
    B_16int_2_1 = single(B_16int_2)-single(B_16int_1).*channel_1_ratio;
    
    B_intp_2_1 = single(zeros(length(zz),loopCropSize(1),loopCropSize(2)));
    
    B_16int_2_1 = permute(B_16int_2_1,[3 1 2]);
    
    parfor ii=1:CropSize(2)
        B_intp_2_1(:,:,ii) = loopspline(B_16int_2_1(:,:,ii),z,zz);
    end
    
    B_intp_2_1 = permute(B_intp_2_1,[2 3 1]);
    B_intp_2_1(B_intp_2_1(:)<0) = 0;
    
    J = imresize(B_intp_2_1,0.5);
    
    background = single(zeros(size(J)));
    
    
    
    percentile_num = round(percentile*numel(find(domain)));
    parfor ii=1:size(J,3)
        background(:,:,ii)  = ordfilt2(J(:,:,ii),percentile_num,domain);
    end
    
    background2 = imresize(background,2);
    B_intp_3 = B_intp_2_1 - background2;
    BinM = false(size(background2));
    BinM(B_intp_3(:)>cut_off_strength)=1;
    BinM(B_intp_2_1(:)>cut_off_strength_2)=1;
    imwritestack(BinM,[dir_out '/binary_Z' num2str(jj) '.tif']);
    toc
end

